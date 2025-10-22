//
//  NextMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// MARK: - Pantalla Próximos Partidos
struct NextMatchesView: View {
    var onBack: (() -> Void)?
    let proximos: [PartidoProximo] = PartidoProximo.mock

    var body: some View {
        ZStack {
            // Fondo blanco total
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // HEADER
                ZStack {
                    // Título centrado
                    VStack(spacing: -6) {
                        Text("PRÓXIMOS")
                        Text("PARTIDOS")
                    }
                    .font(.custom("FWC2026-NormalBlack", size: 20))
                    .foregroundColor(.black)
                    .kerning(1.5)
                    .multilineTextAlignment(.center)

                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

                // SCROLL con las cards
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(proximos) { prox in
                            if let localEquipo = equipo(forCode: prox.localCode),
                               let visitanteEquipo = equipo(forCode: prox.visitanteCode) {

                                let partido = Partido(local: localEquipo, visitante: visitanteEquipo)

                                // CARD estilo glass blur, usando tu componente CardProximo
                                CardProximo(
                                    partido: partido,
                                    grupo: prox.torneo,
                                    fecha: prox.fecha,   // Ej: "16 JUL 2026"
                                    hora: prox.hora      // Ej: "19:00"
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // Helper para obtener equipo según código
    private func equipo(forCode code: String) -> Equipos? {
        let upper = code.uppercased()
        return equiposDetails.first { $0.name.uppercased() == upper }
    }
}

// MARK: - Modelo temporal para próximos
struct PartidoProximo: Identifiable, Hashable {
    let id = UUID()
    let localCode: String
    let visitanteCode: String
    let torneo: String    // Ej: "Grupo A"
    let fecha: String     // Ej: "16 JUL 2026"
    let hora: String      // Ej: "19:00"

    static let mock: [PartidoProximo] = [
        .init(localCode: "MEX", visitanteCode: "CAN", torneo: "Grupo A", fecha: "16 JUN 2026", hora: "19:00"),
        .init(localCode: "USA", visitanteCode: "BRA", torneo: "Grupo B", fecha: "18 JUN 2026", hora: "20:30"),
        .init(localCode: "ARG", visitanteCode: "FRA", torneo: "Grupo C", fecha: "21 JUN 2026", hora: "18:00"),
        .init(localCode: "ESP", visitanteCode: "GER", torneo: "Grupo D", fecha: "23 JUN 2026", hora: "21:00"),
        .init(localCode: "ENG", visitanteCode: "POR", torneo: "Grupo E", fecha: "25 JUN 2026", hora: "16:00"),
        .init(localCode: "NED", visitanteCode: "ITA", torneo: "Grupo F", fecha: "27 JUN 2026", hora: "19:45")
    ]
}

// MARK: - Preview
struct NextMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        NextMatchesView()
            .previewDisplayName("Próximos Partidos")
    }
}
