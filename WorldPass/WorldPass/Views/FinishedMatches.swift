//
//  FinishedMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// MARK: - Pantalla Partidos Finalizados
struct FinalizadosView: View {
    var onBack: (() -> Void)?
    let partidos: [PartidoFinalizado] = PartidoFinalizado.mock

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
                        Text("PARTIDOS")
                        Text("FINALIZADOS")
                    }
                    .font(.custom("FWC2026-NormalBlack", size: 20))
                    .foregroundColor(.black)
                    .kerning(1.5)
                    .multilineTextAlignment(.center)

                    // Botón atrás circular
                    HStack {
                        Button {
                            onBack?()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                                )
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

                // SCROLL con las cards
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(partidos) { pfin in
                            if let localEquipo = equipo(forCode: pfin.localCode),
                               let visitanteEquipo = equipo(forCode: pfin.visitanteCode) {

                                let partido = Partido(local: localEquipo, visitante: visitanteEquipo)

                                // CARD estilo glass blur
                                CardFinalizado(
                                    partido: partido,
                                    grupo: pfin.torneo,
                                    marcadorLocal: pfin.golesLocal,
                                    marcadorVisitante: pfin.golesVisitante
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

// MARK: - Modelo temporal
struct PartidoFinalizado: Identifiable, Hashable {
    let id = UUID()
    let localCode: String
    let visitanteCode: String
    let golesLocal: Int
    let golesVisitante: Int
    let torneo: String

    static let mock: [PartidoFinalizado] = [
        .init(localCode: "QAT", visitanteCode: "ECU", golesLocal: 0, golesVisitante: 2, torneo: "Grupo A"),
        .init(localCode: "FRA", visitanteCode: "AUS", golesLocal: 4, golesVisitante: 1, torneo: "Grupo D"),
        .init(localCode: "BRA", visitanteCode: "SRB", golesLocal: 2, golesVisitante: 0, torneo: "Grupo G"),
        .init(localCode: "QAT", visitanteCode: "ECU", golesLocal: 0, golesVisitante: 2, torneo: "Grupo A"),
        .init(localCode: "FRA", visitanteCode: "AUS", golesLocal: 4, golesVisitante: 1, torneo: "Grupo D"),
        .init(localCode: "BRA", visitanteCode: "SRB", golesLocal: 2, golesVisitante: 0, torneo: "Grupo G")
    ]
}

// MARK: - Preview
struct FinalizadosView_Previews: PreviewProvider {
    static var previews: some View {
        FinalizadosView()
            .previewDisplayName("Partidos Finalizados")
    }
}
