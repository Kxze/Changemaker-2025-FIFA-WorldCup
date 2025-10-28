//
//  StatsView.swift
//  WorldPass
//
//  Created by Kxze on 23/10/25.
//

import SwiftUI

struct StatsView: View {
    // Índice inicial del partido a mostrar (si viene desde la lista)
    var initialIndex: Int? = nil

    // Usamos los mismos ítems compartidos que en FinishedMatches (partido, grupo, stats)
    @State private var items: [(partido: Partido, grupo: String, stats: MatchStats)] = []
    @State private var selectedIndex: Int = 0

    // Sección visible: estadísticas o alineación
    enum DetailSection {
        case stats
        case lineup
    }
    @State private var section: DetailSection = .stats

    // Namespace para “desdoblar” el fondo del botón hacia el panel de contenido
    @Namespace private var unfoldNS

    // Frames para calcular el punto de anclaje de la transición (si quisieras usar anchor dinámico)
    @State private var buttonFrame: CGRect = .zero
    @State private var contentFrame: CGRect = .zero

    // Punto de anclaje (0...1) relativo al contenedor de la sección, basado en la posición del botón
    // (No lo usamos en el flip, pero lo dejamos por si lo quieres activar luego)
    private var anchorPoint: UnitPoint {
        let x: CGFloat
        let y: CGFloat

        if contentFrame.width > 0 {
            x = (buttonFrame.midX - contentFrame.minX) / max(contentFrame.width, 1)
        } else {
            x = 0.5
        }
        if contentFrame.height > 0 {
            y = (buttonFrame.maxY - contentFrame.minY) / max(contentFrame.height, 1)
        } else {
            y = 0.0
        }

        return UnitPoint(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
    }

    // Transición “flip down” (gira de arriba hacia abajo). Solo la aplicamos a la inserción.
    private var flipDownInsertion: AnyTransition {
        .modifier(
            active: Flip3D(angle: 90, anchor: .top),
            identity: Flip3D(angle: 0, anchor: .top)
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        "Sin partidos finalizados",
                        systemImage: "soccerball.inverse",
                        description: Text("Aún no hay resultados simulados.")
                    )
                } else {
                    let item = items[selectedIndex]
                    let match = item.stats
                    let localTeam = match.partido.local
                    let visitTeam = match.partido.visitante

                    // Alineaciones base
                    let baseLocalLineup = LineupBuilder.defaultLineup(for: localTeam)
                    let baseVisitLineup = LineupBuilder.defaultLineup(for: visitTeam)

                    // Normalizamos para no tener más de 4 mediocampistas (mantiene consistencia visual)
                    let localLineup = normalizedLineup(baseLocalLineup)
                    let visitLineup = normalizedLineup(baseVisitLineup)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            // Card con diseño idéntico a CardEnVivo (grupo + marcador)
                            CardStats(
                                partido: item.partido,
                                grupo: item.grupo,
                                marcadorLocal: match.local.goals,
                                marcadorVisitante: match.visitante.goals
                            )
                            .frame(maxWidth: .infinity, alignment: .center)

                            // Botón para alternar entre secciones (medimos su frame en el espacio compartido)
                            toggleSectionButton()
                                .padding(.horizontal, 20)
                                .background(
                                    GeometryReader { proxy in
                                        Color.clear
                                            .preference(
                                                key: ButtonFramePreferenceKey.self,
                                                value: proxy.frame(in: .named("StatsViewSpace"))
                                            )
                                    }
                                    .allowsHitTesting(false) // evita interceptar el toque del botón
                                )
                                .zIndex(2) // asegurar que quede por encima de lo que viene después

                            // Panel “desplegable” que nace del botón gracias al matchedGeometryEffect
                            ZStack(alignment: .top) {
                                // Fondo que se empareja con el botón y “crece” a panel
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .matchedGeometryEffect(id: "UNFOLD_BG", in: unfoldNS)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 8)
                                    .padding(.top, 0)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                                // Contenido de la sección
                                VStack(spacing: 0) {
                                    // Separación superior dentro del panel
                                    Color.clear.frame(height: 10)

                                    Group {
                                        if section == .stats {
                                            MatchStatsSectionView(
                                                match: match,
                                                localLineup: localLineup,
                                                visitLineup: visitLineup
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                            // Solo animamos la entrada con flip down; la salida será un fade
                                            .transition(.asymmetric(insertion: flipDownInsertion, removal: .opacity))
                                        }

                                        if section == .lineup {
                                            LineupSectionView(
                                                localTeam: localTeam,
                                                visitTeam: visitTeam,
                                                localLineup: localLineup,
                                                visitLineup: visitLineup
                                            )
                                            .padding(.horizontal, 8)
                                            .padding(.bottom, 12)
                                            // Solo animamos la entrada con flip down; la salida será un fade
                                            .transition(.asymmetric(insertion: flipDownInsertion, removal: .opacity))
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                            // Medimos el frame del contenedor de secciones en el mismo espacio de coordenadas
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            contentFrame = proxy.frame(in: .named("StatsViewSpace"))
                                        }
                                        .onChange(of: section) { _ in
                                            contentFrame = proxy.frame(in: .named("StatsViewSpace"))
                                        }
                                }
                                .allowsHitTesting(false)
                            )
                            .padding(.top, 2)
                            .zIndex(1)
                            .animation(.spring(response: 0.6, dampingFraction: 0.9), value: section)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    // Espacio de coordenadas compartido para medir botón y contenedor
                    .coordinateSpace(name: "StatsViewSpace")
                    // Recibimos el frame del botón
                    .onPreferenceChange(ButtonFramePreferenceKey.self) { frame in
                        self.buttonFrame = frame
                    }
                }
            }
            .navigationTitle(section == .stats ? "ESTADÍSTICAS" : "ALINEACIONES")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Usar exactamente los mismos partidos finalizados que en FinishedMatches
            items = FinishedMatchesCache.items

            // Si recibimos un índice, lo respetamos; si no, el actual.
            let target = initialIndex ?? selectedIndex
            selectedIndex = clamp(target, 0, max(0, items.count - 1))
        }
    }

    // MARK: - Botón de alternancia de sección

    @ViewBuilder
    private func toggleSectionButton() -> some View {
        Button {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.9)) {
                section = (section == .stats) ? .lineup : .stats
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: section == .stats ? "soccerball.inverse" : "tshirt.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text(section == .stats ? "Ver Alineación" : "Ver Estadísticas")
                    .font(.custom("FWC2026-NormalBlack", size: 14))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // asegura buena zona de toque
            .background(
                // Píldora con matchedGeometryEffect para el “desdoble”
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .matchedGeometryEffect(id: "UNFOLD_BG", in: unfoldNS)
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section == .stats ? "Ver Alineación" : "Ver Estadísticas")
    }

    // MARK: - Normalización de alineaciones (máximo 4 mediocampistas)

    private func normalizedLineup(_ lineup: Lineup) -> Lineup {
        let defenders = lineup.players.filter { $0.position == .DF }
        let midfielders = lineup.players.filter { $0.position == .MF }
        let forwards = lineup.players.filter { $0.position == .FW }
        let goalkeepers = lineup.players.filter { $0.position == .GK }

        var dCount = defenders.count
        var mCount = midfielders.count
        var fCount = forwards.count

        // Si hay más de 4 mediocampistas, movemos 1 MF hacia adelante si faltan delanteros,
        // si ya hay 3 delanteros, movemos 1 MF hacia la defensa.
        var newPlayers: [Player] = []
        if mCount > 4 {
            if fCount < 3 {
                // Promover un MF a FW
                if let mfToPromote = midfielders.first {
                    let promoted = Player(name: mfToPromote.name, number: mfToPromote.number, position: .FW)
                    newPlayers.append(contentsOf: goalkeepers)
                    newPlayers.append(contentsOf: defenders)
                    newPlayers.append(contentsOf: midfielders.dropFirst())
                    newPlayers.append(promoted)
                    mCount -= 1
                    fCount += 1
                }
            } else {
                // Retroceder un MF a DF
                if let mfToMoveBack = midfielders.first {
                    let moved = Player(name: mfToMoveBack.name, number: mfToMoveBack.number, position: .DF)
                    newPlayers.append(contentsOf: goalkeepers)
                    newPlayers.append(contentsOf: defenders)
                    newPlayers.append(moved)
                    newPlayers.append(contentsOf: midfielders.dropFirst())
                    newPlayers.append(contentsOf: forwards)
                    mCount -= 1
                    dCount += 1
                }
            }
        }

        if newPlayers.isEmpty {
            newPlayers = lineup.players
        } else {
            let gk = newPlayers.filter { $0.position == .GK }
            let df = newPlayers.filter { $0.position == .DF }
            let mf = newPlayers.filter { $0.position == .MF }
            let fw = newPlayers.filter { $0.position == .FW }
            newPlayers = gk + df + mf + fw
        }

        let cappedM = min(mCount, 4)
        let newFormation = "\(max(3, dCount))-\(cappedM)-\(max(1, fCount))"

        return Lineup(team: lineup.team, formation: newFormation, players: newPlayers)
    }

    // MARK: - Helpers

    private func clamp<T: Comparable>(_ value: T, _ minV: T, _ maxV: T) -> T {
        max(minV, min(value, maxV))
    }
}

// PreferenceKey para pasar el frame del botón a través de la vista
private struct ButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// ViewModifier para el flip 3D
private struct Flip3D: ViewModifier {
    let angle: Double
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 1, y: 0, z: 0),
                anchor: anchor,
                perspective: 0.7
            )
            .opacity(angle == 0 ? 1 : 0.0)
    }
}

#Preview {
    StatsView()
}
