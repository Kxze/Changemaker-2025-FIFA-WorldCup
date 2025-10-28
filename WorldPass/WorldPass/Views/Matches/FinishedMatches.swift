//
//  FinishedMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// MARK: - Pantalla Partidos Finalizados usando MatchSimulator
struct FinalizadosView: View {
    // Usamos la lista compartida del cache
    private let simulados: [(partido: Partido, grupo: String, stats: MatchStats)] = FinishedMatchesCache.items

    var body: some View {
        // SCROLL con las cards
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(Array(simulados.enumerated()), id: \.element.partido.id) { idx, item in
                    NavigationLink {
                        // Navega a StatsView con el índice seleccionado
                        StatsView(initialIndex: idx)
                    } label: {
                        CardFinalizado(
                            partido: item.partido,
                            grupo: item.grupo,
                            marcadorLocal: item.stats.local.goals,
                            marcadorVisitante: item.stats.visitante.goals
                        )
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain) // mantiene el estilo visual de la card
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .toolbar{
            ToolbarItem(placement: .title) {
                VStack(spacing: -5){
                    Text("PARTIDOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("FINALIZADOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
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
