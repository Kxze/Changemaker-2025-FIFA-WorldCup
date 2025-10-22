//
//  NextMatches.swift
//  WorldPass
//
//  Created by Gillian Arce Cardenas on 21/10/25.
//

import SwiftUI

// MARK: - Pantalla Próximos Partidos usando UpcomingMatchesBuilder
struct NextMatchesView: View {
    // 1) Simulamos una lista de partidos finalizados (igual que en FinalizadosView)
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

    // 2) Generamos los próximos partidos excluyendo los finalizados anteriores
    private var proximos: [UpcomingFixture] {
        let finishedStats = simulados.map { $0.stats }
        return UpcomingMatchesBuilder.generate(excluding: finishedStats, count: 10)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(proximos, id: \.partido.id) { item in
                    // No añadir padding ni frames externos para no alterar el diseño interno
                    CardProximo(
                        partido: item.partido,
                        grupo: item.grupo,
                        fecha: item.fecha,
                        hora: item.hora
                    )
                    // Centrar la tarjeta respetando su ancho interno (350)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            // Evita márgenes horizontales que afecten al ancho percibido de la tarjeta
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

// MARK: - Preview
struct NextMatchesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NextMatchesView()
        }
        .previewDisplayName("Próximos Partidos")
    }
}
