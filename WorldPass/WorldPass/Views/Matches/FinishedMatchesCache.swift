//
//  FinishedMatchesCache.swift
//  WorldPass
//
//  Created by Assistant on 23/10/25.
//

import Foundation

/// Cache compartida de partidos finalizados simulados, para que todas las vistas
/// utilicen la MISMA lista durante la ejecución.
enum FinishedMatchesCache {
    /// Lista de (partido, grupo, stats) simulados. Se calcula una única vez.
    static let items: [(partido: Partido, grupo: String, stats: MatchStats)] = {
        // 1) Fuente: todos los partidos con su grupo asociado
        var lista: [(partido: Partido, grupo: String)] = []
        for grupo in gruposMundial2026 {
            for p in grupo.partidos {
                lista.append((partido: p, grupo: grupo.nombre))
            }
        }
        // 2) Elegimos 10 aleatorios (una sola vez por ejecución)
        let seleccion = Array(lista.shuffled().prefix(10))
        // 3) Simulamos cada partido
        return seleccion.map { item in
            let stats = MatchSimulator.simulate(partido: item.partido)
            return (partido: item.partido, grupo: item.grupo, stats: stats)
        }
    }()

    /// Solo las estadísticas de los partidos finalizados.
    static var stats: [MatchStats] {
        items.map { $0.stats }
    }
}
