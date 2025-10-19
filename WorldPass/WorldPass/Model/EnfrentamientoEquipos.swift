//
//  EnfrentamientoEquipos.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import Foundation

// Representa un enfrentamiento entre dos equipos
struct Partido: Identifiable, Hashable {
    let id = UUID()
    let local: Equipos
    let visitante: Equipos
}

// Representa un grupo de 4 equipos y sus partidos internos (round-robin)
struct Grupo: Identifiable, Hashable {
    let id = UUID()
    let nombre: String        // "Grupo A", "Grupo B", etc.
    let equipos: [Equipos]    // Deben ser 4
    let partidos: [Partido]   // 6 partidos (todas las combinaciones únicas)
}

// MARK: - Generación de grupos y partidos

/// Genera todas las combinaciones únicas (i < j) de enfrentamientos entre los equipos.
/// No hay auto-enfrentamientos ni repeticiones.
/// Para 4 equipos produce 6 partidos.
func generarPartidosRoundRobin(para equipos: [Equipos]) -> [Partido] {
    var partidos: [Partido] = []
    let n = equipos.count
    guard n >= 2 else { return partidos }
    
    for i in 0..<(n - 1) {
        for j in (i + 1)..<n {
            let local = equipos[i]
            let visitante = equipos[j]
            partidos.append(Partido(local: local, visitante: visitante))
        }
    }
    return partidos
}

/// Divide la lista en bloques consecutivos de 4 equipos y crea grupos "Grupo A", "Grupo B", ...
/// - Parameters:
///   - equipos: Lista total de equipos (esperados 48 para el formato 2026).
///   - mezclar: Si es true, baraja los equipos antes de agrupar (simula sorteo).
/// - Returns: Lista de grupos completos de 4 (para 48 equipos, 12 grupos A...L).
func generarGruposDesdeEquipos(_ equipos: [Equipos], mezclar: Bool = false) -> [Grupo] {
    guard !equipos.isEmpty else { return [] }
    
    let letras = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let chunkSize = 4
    
    // Opcional: barajar para simular sorteo
    let fuente = mezclar ? equipos.shuffled() : equipos
    
    // Solo tomamos múltiplos de 4 para grupos completos
    let totalTomado = (fuente.count / chunkSize) * chunkSize
    let lista = Array(fuente.prefix(totalTomado))
    
    var grupos: [Grupo] = []
    var indexGrupo = 0
    
    for i in stride(from: 0, to: lista.count, by: chunkSize) {
        let slice = Array(lista[i..<i + chunkSize])
        guard slice.count == 4 else { continue }
        
        // Nombre del grupo (A, B, C, ...)
        let letra = letras[min(indexGrupo, letras.count - 1)]
        let nombre = "Grupo \(letra)"
        indexGrupo += 1
        
        let partidos = generarPartidosRoundRobin(para: slice)
        let grupo = Grupo(nombre: nombre, equipos: slice, partidos: partidos)
        grupos.append(grupo)
    }
    
    return grupos
}

// MARK: - Fuente principal usando equiposDetails global (Formato Mundial 2026)

/// Genera los 12 grupos (A...L) con 4 equipos cada uno a partir de `equiposDetails`,
/// con sus 6 partidos por grupo (round-robin), SIN barajar para que sean fijos.
var gruposMundial2026: [Grupo] {
    // Desactivamos el sorteo aleatorio
    let grupos = generarGruposDesdeEquipos(equiposDetails, mezclar: false)
    
    // Para 48 equipos deben ser 12 grupos exactos; si hay más/menos, devolvemos los completos formados.
    if grupos.count >= 12 {
        return Array(grupos.prefix(12))
    } else {
        return grupos
    }
}
