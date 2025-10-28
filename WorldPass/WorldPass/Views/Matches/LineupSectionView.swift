//
//  LineupSectionView.swift
//  WorldPass
//
//  Created by Assistant on 24/10/25.
//

import SwiftUI

struct LineupSectionView: View {
    let localTeam: Equipos
    let visitTeam: Equipos
    let localLineup: Lineup
    let visitLineup: Lineup

    @State private var showLocal: Bool = true
    @Namespace private var lineupNS
    @Namespace private var toggleNS

    var body: some View {
        let currentLineup = showLocal ? localLineup : visitLineup

        // Usamos los colores del catálogo de Assets
        let currentTint: Color = Color(showLocal ? "Verde" : "Azul")      // color de camiseta
        let currentNumberTint: Color = Color(showLocal ? "Azul" : "Verde") // color del dorsal (opuesto)

        VStack(alignment: .center, spacing: 10) {
            Text("ALINEACIÓN")
                .font(.custom("FWC2026-NormalBlack", size: 16))
                .padding(.leading, 2)

            // Selector con interpolación deslizante y .glassEffect solo en el seleccionado
            HStack(spacing: 12) {
                teamToggleButton(team: localTeam, isSelected: showLocal, ns: toggleNS) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        showLocal = true
                    }
                }
                teamToggleButton(team: visitTeam, isSelected: !showLocal, ns: toggleNS) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        showLocal = false
                    }
                }
            }
            .padding(.horizontal, 8)

            // "CODIGO FORMACIÓN" arriba de la cancha
            Text(currentLineup.formation)
                .font(.custom("FWC2026-NormalRegular", size: 14))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            formationPitch(
                for: currentLineup,
                tint: currentTint,
                numberTint: currentNumberTint,
                ns: lineupNS
            )
            .padding(.horizontal, 8)
            .id(showLocal ? "LOCAL" : "VISITANTE")
            .transition(.opacity.combined(with: .scale))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: showLocal)
        }
        .padding(.top, 6)
    }

    // MARK: - Botón de selección de equipo con .glassEffect y animación deslizante

    private func teamToggleButton(team: Equipos, isSelected: Bool, ns: Namespace.ID, action: @escaping () -> Void) -> some View {
        let scale: CGFloat = isSelected ? 1.02 : 1.0
        let foreground: Color = isSelected ? .black : .secondary
        let strokeColor: Color = isSelected ? .black.opacity(0.25) : .secondary.opacity(0.2)
        let lineWidth: CGFloat = isSelected ? 1.2 : 1.0

        return Button(action: action) {
            ZStack {
                // Píldora de selección: solo aparece en el seleccionado y se desliza entre botones
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                        .glassEffect()
                        .matchedGeometryEffect(id: "SELECTION_PILL", in: ns)
                }

                HStack(spacing: 10) {
                    Image(team.flag)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

                    Text(team.name)
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(foreground)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(scale)
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ver alineación de \(team.name)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Formación en “cancha” con íconos de camiseta y apellidos

    private func formationPitch(for lineup: Lineup, tint: Color, numberTint: Color, ns: Namespace.ID) -> some View {
        // Filtramos por posición en el orden requerido
        let gk = players(lineup, .GK)
        let df = players(lineup, .DF)
        let mf = players(lineup, .MF)
        let fw = players(lineup, .FW)

        return VStack(spacing: 1) {
            // Delanteros
            formationRow(players: fw, tint: tint, numberTint: numberTint, rowKey: "FW", ns: ns)

            // Mediocampistas
            formationRow(players: mf, tint: tint, numberTint: numberTint, rowKey: "MF", ns: ns)

            // Defensas
            formationRow(players: df, tint: tint, numberTint: numberTint, rowKey: "DF", ns: ns)

            // Portero
            formationRow(players: gk, tint: tint, numberTint: numberTint, rowKey: "GK", ns: ns)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            Image("cancha")
                .resizable()
                .scaledToFill()
                .frame(width: 400, height: 300)
        )
    }

    private func formationRow(
        players: [Player],
        tint: Color,
        numberTint: Color,
        rowKey: String,
        ns: Namespace.ID
    ) -> some View {
        HStack(spacing: -8) {
            Spacer(minLength: 0)
            ForEach(players.indices, id: \.self) { i in
                let p = players[i]
                let isMF = (p.position == .MF)
                let liftCenterMF = (isMF && players.count == 5 && i == 2)

                playerBadge(for: p, tint: tint, numberTint: numberTint)
                    .matchedGeometryEffect(id: "\(rowKey)-\(i)", in: ns, properties: .position)
                    .offset(y: liftCenterMF ? -12 : 0)
            }
            Spacer(minLength: 0)
        }
    }

    private func playerBadge(for player: Player, tint: Color, numberTint: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(tint)
                    .symbolRenderingMode(.monochrome)

                Text("\(player.number)")
                    .font(.custom("FWC2026-NormalBlack", size: 12))
                    .foregroundStyle(numberTint)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
            }

            Text(surname(from: player.name))
                .font(.custom("FWC2026-NormalRegular", size: 12))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .glassEffect()
        }
        .frame(width: 80)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(player.number). \(player.name)")
    }

    // MARK: - Helpers

    private func players(_ lineup: Lineup, _ pos: PlayerPosition) -> [Player] {
        lineup.players.filter { $0.position == pos }
    }

    private func surname(from fullName: String) -> String {
        let parts = fullName.split(separator: " ").map(String.init)
        return parts.last ?? fullName
    }
}
