//
//  NextMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// Proximos partidos

struct NextMatchesView: View {
    
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


    private var proximos: [UpcomingFixture] {
        let finishedStats = simulados.map { $0.stats }
        return UpcomingMatchesBuilder.generate(excluding: finishedStats, count: 10)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(proximos, id: \.partido.id) { item in
                    
                    
                    CardProximo(
                        partido: item.partido,
                        grupo: item.grupo,
                        fecha: item.fecha,
                        hora: item.hora
                    )
                   
                    
                    //
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            // 
            .frame(maxWidth: .infinity)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .toolbar {
            ToolbarItem(placement: .title) {
                VStack(spacing: -5) {
                    Text("PRÓXIMOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("PARTIDOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                }
            }
        }
    }
}


struct NextMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NextMatchesView()
        }
        .previewDisplayName("Próximos Partidos")
    }
}
