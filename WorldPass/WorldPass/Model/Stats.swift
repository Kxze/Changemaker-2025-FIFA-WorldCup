//
//  Stats.swift
//  WorldPass
//
//  Created by Kxze on 23/10/25.
//

import Foundation

// MARK: - Modelos de alineación

enum PlayerPosition: String, Codable, Hashable {
    case GK  // Portero
    case DF  // Defensor
    case MF  // Mediocampista
    case FW  // Delantero
}

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let number: Int
    let position: PlayerPosition

    init(id: UUID = UUID(), name: String, number: Int, position: PlayerPosition) {
        self.id = id
        self.name = name
        self.number = number
        self.position = position
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, number, position
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int.self, forKey: .number)
        self.position = try container.decode(PlayerPosition.self, forKey: .position)
    }
}

struct Lineup: Identifiable, Hashable {
    var id = UUID()
    let team: Equipos
    let formation: String // Ej. "4-3-3"
    let players: [Player]
}

// Codable personalizado para Lineup (Equipos no es Codable)
extension Lineup: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case teamCode     // serializamos solo el código del equipo (Equipos.name)
        case formation
        case players
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(team.name, forKey: .teamCode)
        try container.encode(formation, forKey: .formation)
        try container.encode(players, forKey: .players)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let teamCode = try container.decode(String.self, forKey: .teamCode)
        let formation = try container.decode(String.self, forKey: .formation)
        let players = try container.decode([Player].self, forKey: .players)

        // Reconstruimos el Equipos a partir de equiposDetails (si existe)
        if let found = equiposDetails.first(where: { $0.name == teamCode }) {
            self.team = found
        } else {
            // Fallback: crear un Equipos mínimo con flag vacío
            self.team = Equipos(name: teamCode, flag: "")
        }
        self.id = id
        self.formation = formation
        self.players = players
    }
}

// MARK: - Generador de alineaciones “típicas”

enum LineupBuilder {
    /// Genera una alineación para un equipo dado.
    /// - Si existe un roster y formación en PlayersDatabase, lo usa.
    /// - Si no, genera una alineación determinista (4-3-3) como fallback.
    static func defaultLineup(for team: Equipos) -> Lineup {
        if let lineup = PlayersDatabase.buildLineup(for: team) {
            return lineup
        }

        // Fallback determinista (nombres genéricos estables por equipo)
        let formation = "4-3-3"

        let gkNumbers   = [1]
        let dfNumbers   = [2, 3, 4, 5]
        let mfNumbers   = [6, 7, 8]
        let fwNumbers   = [9, 10, 11]

        func playerName(_ number: Int) -> String {
            var hasher = Hasher()
            hasher.combine(team.name)
            hasher.combine(number)
            let hash = abs(hasher.finalize())
            let suffix = (hash % 90) + 10 // 10...99
            return "Jugador \(suffix) (\(team.name))"
        }

        let gk = gkNumbers.map { n in
            Player(name: playerName(n), number: n, position: .GK)
        }
        let df = dfNumbers.map { n in
            Player(name: playerName(n), number: n, position: .DF)
        }
        let mf = mfNumbers.map { n in
            Player(name: playerName(n), number: n, position: .MF)
        }
        let fw = fwNumbers.map { n in
            Player(name: playerName(n), number: n, position: .FW)
        }

        return Lineup(team: team, formation: formation, players: gk + df + mf + fw)
    }
}

// MARK: - Servicio para “partidos finalizados” y alineaciones asociadas

enum FinishedMatchesService {
    static func randomFinishedMatches(count: Int = 10, seed: Int? = nil) -> [MatchStats] {
        var lista: [Partido] = []
        for grupo in gruposMundial2026 {
            lista.append(contentsOf: grupo.partidos)
        }

        let fuente: [Partido]
        if let seed {
            var rng = Seed(seed: seed)
            fuente = lista.shuffled(using: &rng)
        } else {
            fuente = lista.shuffled()
        }

        let seleccion = Array(fuente.prefix(max(0, count)))
        return MatchSimulator.simulateMany(seleccion, seed: seed)
    }

    static func uniqueTeams(in finished: [MatchStats]) -> [Equipos] {
        var set: Set<Equipos> = []
        for m in finished {
            set.insert(m.partido.local)
            set.insert(m.partido.visitante)
        }
        return Array(set)
    }

    static func lineupsForFinishedTeams(from finished: [MatchStats]) -> [Equipos: Lineup] {
        let teams = uniqueTeams(in: finished)
        var dict: [Equipos: Lineup] = [:]
        for t in teams {
            dict[t] = LineupBuilder.defaultLineup(for: t)
        }
        return dict
    }

    static func playersForFinishedTeams(from finished: [MatchStats]) -> [Equipos: [Player]] {
        let lineups = lineupsForFinishedTeams(from: finished)
        var dict: [Equipos: [Player]] = [:]
        for (team, lineup) in lineups {
            dict[team] = lineup.players
        }
        return dict
    }

    static func playersByTeamCode(for finished: [MatchStats]) -> [String: [Player]] {
        let byTeam = playersForFinishedTeams(from: finished)
        var dict: [String: [Player]] = [:]
        for (team, players) in byTeam {
            dict[team.name] = players
        }
        return dict
    }

    static func allPlayers(from finished: [MatchStats]) -> [Player] {
        let byTeam = playersForFinishedTeams(from: finished)
        return byTeam.values.flatMap { $0 }
    }
}

// MARK: - RNG utilitario para barajado determinista (opcional)

private struct Seed: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        var x = UInt64(bitPattern: Int64(seed))
        x ^= 0x9E3779B97F4A7C15
        x = x &* 0xBF58476D1CE4E5B9
        x ^= x >> 30
        self.state = x
    }

    mutating func next() -> UInt64 {
        var x = state
        x ^= x >> 12
        x ^= x << 25
        x ^= x >> 27
        state = x
        return x &* 2685821657736338717
    }
}
