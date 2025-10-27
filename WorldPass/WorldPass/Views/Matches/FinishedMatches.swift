//
//  FinishedMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//



import SwiftUI

//
struct FinalizadosView: View {
    // Precomputamos 10 partidos simulados (partido, grupo y sus stats)
    private let simulados: [(partido: Partido, grupo: String, stats: MatchStats)] = {
        var lista: [(partido: Partido, grupo: String)] = []
        for grupo in gruposMundial2026 {
            for p in grupo.partidos {
                lista.append((partido: p, grupo: grupo.nombre))
            }
        }
       
        let seleccion = Array(lista.shuffled().prefix(10))
     
        return seleccion.map { item in
            let stats = MatchSimulator.simulate(partido: item.partido)
            return (partido: item.partido, grupo: item.grupo, stats: stats)
        }
    }()

    var body: some View {
      

        

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


struct FinalizadosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FinalizadosView()
        }
        .previewDisplayName("Partidos Finalizados (Simulados)")
    }
}
