//
//  FinishedMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// MARK: - Pantalla Partidos Finalizados usando MatchSimulator
struct FinalizadosView: View {
    // Precomputamos 10 partidos simulados (partido, grupo y sus stats)
    private let simulados: [(partido: Partido, grupo: String, stats: MatchStats)] = {
        // 1) Fuente: todos los partidos con su grupo asociado
        var lista: [(partido: Partido, grupo: String)] = []
        for grupo in gruposMundial2026 {
            for p in grupo.partidos {
                lista.append((partido: p, grupo: grupo.nombre))
            }
        }
        // 2) Elegimos 10 aleatorios
        let seleccion = Array(lista.shuffled().prefix(10))
        // 3) Simulamos cada partido
        return seleccion.map { item in
            let stats = MatchSimulator.simulate(partido: item.partido)
            return (partido: item.partido, grupo: item.grupo, stats: stats)
        }
    }()

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
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

                // SCROLL con las cards
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(simulados, id: \.partido.id) { item in
                            CardFinalizado(
                                partido: item.partido,
                                grupo: item.grupo,
                                marcadorLocal: item.stats.local.goals,
                                marcadorVisitante: item.stats.visitante.goals
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

// MARK: - Preview
struct FinalizadosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FinalizadosView()
        }
        .previewDisplayName("Partidos Finalizados (Simulados)")
    }
}
