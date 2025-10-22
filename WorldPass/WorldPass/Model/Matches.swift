//
//  Matches.swift
//  WorldPass
//
//  Created by Kxze on 21/10/25.
//

import Foundation

// MARK: - Tipos de apoyo

enum MatchSide: String, Codable, Hashable {
    case local
    case visitante
}

enum CardType: String, Codable, Hashable {
    case yellow
    case red
}

struct GoalEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let minute: Int
    let side: MatchSide
    let scorerName: String
    let assistName: String?

    init(id: UUID = UUID(), minute: Int, side: MatchSide, scorerName: String, assistName: String?) {
        self.id = id
        self.minute = minute
        self.side = side
        self.scorerName = scorerName
        self.assistName = assistName
    }
}

struct CardEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let minute: Int
    let side: MatchSide
    let type: CardType
    let playerName: String

    init(id: UUID = UUID(), minute: Int, side: MatchSide, type: CardType, playerName: String) {
        self.id = id
        self.minute = minute
        self.side = side
        self.type = type
        self.playerName = playerName
    }
}

// Estadísticas por equipo
struct TeamMatchStats: Codable, Hashable {
    // Marcador
    let goals: Int
    let goalEvents: [GoalEvent]

    // Disparos/xG
    let shots: Int
    let shotsOnTarget: Int
    let expectedGoals: Double

    // Posesión
    let possession: Double // 0...100 (se asegura que local + visitante = 100)

    // Otras estadísticas
    let corners: Int
    let offsides: Int
    let foulsCommitted: Int
    let yellowCards: Int
    let redCards: Int
    let cardEvents: [CardEvent]

    // Pase
    let passes: Int
    let passAccuracy: Double // 0...100
}

// Resultado y estadísticas completas del partido
// Nota: No declaramos Codable aquí porque `Partido`/`Equipos` no son Codable.
struct MatchStats: Identifiable, Hashable {
    let id = UUID()
    let partido: Partido

    // Resultado final
    let local: TeamMatchStats
    let visitante: TeamMatchStats

    var marcadorFinal: (local: Int, visitante: Int) {
        (local.goals, visitante.goals)
    }
}

// MARK: - Simulador

enum MatchSimulator {
    /// Simula un partido a partir de un `Partido` (local, visitante).
    /// - Parameters:
    ///   - partido: Encuentro a simular.
    ///   - seed: Semilla opcional para reproducibilidad.
    /// - Returns: `MatchStats` con marcador final y estadísticas.
    static func simulate(partido: Partido, seed: Int? = nil) -> MatchStats {
        let rng = SeededRandom(seed: seed ?? defaultSeed(for: partido))
        let localWeight = rating(for: partido.local)
        let visitanteWeight = rating(for: partido.visitante)

        // xG esperadas por equipo (base 0.6...1.8), ajustadas por "fuerza"
        let baseLocal = rng.randomDouble(in: 0.6...1.8)
        let baseVisit = rng.randomDouble(in: 0.6...1.8)

        // Ajuste relativo por peso (diferencia de "fortaleza" 25%)
        let adjLocal = baseLocal * (1.0 + 0.25 * (localWeight - visitanteWeight))
        let adjVisit = baseVisit * (1.0 + 0.25 * (visitanteWeight - localWeight))

        let xgLocal = max(0.05, adjLocal)
        let xgVisit = max(0.05, adjVisit)

        // Goles desde Poisson(xG)
        let golesLocal = poissonSample(mean: xgLocal, rng: rng)
        let golesVisit = poissonSample(mean: xgVisit, rng: rng)

        // Minutos de goles (únicos, ordenados)
        let golesLocalMinutos = uniqueSortedMinutes(count: golesLocal, rng: rng)
        let golesVisitMinutos = uniqueSortedMinutes(count: golesVisit, rng: rng)

        // Nombres de “jugadores” genéricos
        let localGoals = golesLocalMinutos.map { minute in
            GoalEvent(
                minute: minute,
                side: .local,
                scorerName: randomPlayerName(for: partido.local, rng: rng),
                assistName: rng.randomBool(probability: 0.55) ? randomPlayerName(for: partido.local, rng: rng) : nil
            )
        }
        let visitGoals = golesVisitMinutos.map { minute in
            GoalEvent(
                minute: minute,
                side: .visitante,
                scorerName: randomPlayerName(for: partido.visitante, rng: rng),
                assistName: rng.randomBool(probability: 0.55) ? randomPlayerName(for: partido.visitante, rng: rng) : nil
            )
        }

        // Posesión (50/50 +/- 10%, sesgada por el peso)
        let basePoss = 50.0 + (localWeight - visitanteWeight) * 10.0
        let localPoss = clamp(basePoss + rng.randomDouble(in: -6.0...6.0), 35.0, 65.0)
        let visitPoss = 100.0 - localPoss

        // Remates y a puerta correlacionados con xG y goles
        let (shotsL, onTargetL) = shotsFrom(xg: xgLocal, goals: golesLocal, rng: rng)
        let (shotsV, onTargetV) = shotsFrom(xg: xgVisit, goals: golesVisit, rng: rng)

        // Corners correlacionados con remates (redondea el Double ANTES de convertir a Int)
        let cornersL = max(0, Int((Double(shotsL) * rng.randomDouble(in: 0.15...0.35)).rounded()))
        let cornersV = max(0, Int((Double(shotsV) * rng.randomDouble(in: 0.15...0.35)).rounded()))

        // Offsides bajos
        let offsidesL = rng.randomInt(in: 0...3)
        let offsidesV = rng.randomInt(in: 0...3)

        // Faltas y tarjetas
        let foulsL = rng.randomInt(in: 7...16)
        let foulsV = rng.randomInt(in: 7...16)

        let yellowL = rng.randomInt(in: 0...4)
        let yellowV = rng.randomInt(in: 0...4)

        let redL = rng.randomBool(probability: 0.08) ? 1 : 0
        let redV = rng.randomBool(probability: 0.08) ? 1 : 0

        // Eventos de tarjetas con minutos
        let cardEventsL: [CardEvent] = generateCardEvents(
            yellow: yellowL,
            red: redL,
            side: .local,
            team: partido.local,
            rng: rng
        )
        let cardEventsV: [CardEvent] = generateCardEvents(
            yellow: yellowV,
            red: redV,
            side: .visitante,
            team: partido.visitante,
            rng: rng
        )

        // Pases y precisión correlacionados con posesión y “fuerza”
        let passesL = passesFromPossession(localPoss, rng: rng)
        let passesV = passesFromPossession(visitPoss, rng: rng)
        let passAccL = clamp(72.0 + (localWeight * 8.0) + rng.randomDouble(in: -4.0...4.0), 68.0, 92.0)
        let passAccV = clamp(72.0 + (visitanteWeight * 8.0) + rng.randomDouble(in: -4.0...4.0), 68.0, 92.0)

        let localStats = TeamMatchStats(
            goals: golesLocal,
            goalEvents: localGoals,
            shots: shotsL,
            shotsOnTarget: onTargetL,
            expectedGoals: round(xgLocal, digits: 2),
            possession: round(localPoss, digits: 1),
            corners: cornersL,
            offsides: offsidesL,
            foulsCommitted: foulsL,
            yellowCards: yellowL,
            redCards: redL,
            cardEvents: cardEventsL,
            passes: passesL,
            passAccuracy: round(passAccL, digits: 1)
        )

        let visitanteStats = TeamMatchStats(
            goals: golesVisit,
            goalEvents: visitGoals,
            shots: shotsV,
            shotsOnTarget: onTargetV,
            expectedGoals: round(xgVisit, digits: 2),
            possession: round(visitPoss, digits: 1),
            corners: cornersV,
            offsides: offsidesV,
            foulsCommitted: foulsV,
            yellowCards: yellowV,
            redCards: redV,
            cardEvents: cardEventsV,
            passes: passesV,
            passAccuracy: round(passAccV, digits: 1)
        )

        return MatchStats(partido: partido, local: localStats, visitante: visitanteStats)
    }

    /// Simula una lista de partidos.
    static func simulateMany(_ partidos: [Partido], seed: Int? = nil) -> [MatchStats] {
        partidos.enumerated().map { idx, p in
            let combinedSeed = (seed ?? 0) &+ idx &+ defaultSeed(for: p)
            return simulate(partido: p, seed: combinedSeed)
        }
    }

    /// Simula todos los partidos de los grupos generados a partir de una lista de equipos.
    /// - Parameters:
    ///   - equipos: Lista de equipos (ya barajados si lo deseas).
    ///   - mezclarEnGrupos: Si true, vuelve a barajar al formar los grupos (usa tu generador).
    ///   - seed: Semilla base opcional.
    /// - Returns: Lista de `MatchStats` de todos los partidos de los grupos formados.
    static func simulateFromTeams(_ equipos: [Equipos], mezclarEnGrupos: Bool = false, seed: Int? = nil) -> [MatchStats] {
        let grupos = generarGruposDesdeEquipos(equipos, mezclar: mezclarEnGrupos)
        let todos = grupos.flatMap { $0.partidos }
        return simulateMany(todos, seed: seed)
    }
}

// MARK: - Helpers de simulación

private func defaultSeed(for partido: Partido) -> Int {
    var hasher = Hasher()
    hasher.combine(partido.local.name)
    hasher.combine(partido.visitante.name)
    return hasher.finalize()
}

private func rating(for equipo: Equipos) -> Double {
    // Peso pseudo-determinista 0.85 ... 1.15 según el nombre
    var hasher = Hasher()
    hasher.combine(equipo.name)
    let h = hasher.finalize()
    let u = Double(abs(h % 10_000)) / 10_000.0 // [0,1]
    return 0.85 + u * 0.30
}

private func shotsFrom(xg: Double, goals: Int, rng: SeededRandom) -> (shots: Int, onTarget: Int) {
    // Disparos correlacionados con xG y goles (pero con variación)
    let expectedShots = max(3.0, xg * rng.randomDouble(in: 5.0...9.0) + Double(goals) * rng.randomDouble(in: 1.0...2.0))
    let shots = max(1, Int((expectedShots + rng.randomDouble(in: -2.0...2.0)).rounded()))
    let onTarget = clamp(Int((Double(shots) * rng.randomDouble(in: 0.3...0.55)).rounded()), 0, shots)
    return (shots, onTarget)
}

private func passesFromPossession(_ possession: Double, rng: SeededRandom) -> Int {
    // Pases base 280...720 según posesión
    let base = 280.0 + (possession / 100.0) * 480.0
    let noise = rng.randomDouble(in: -60.0...60.0)
    return max(150, Int((base + noise).rounded()))
}

private func uniqueSortedMinutes(count: Int, rng: SeededRandom) -> [Int] {
    guard count > 0 else { return [] }
    var set = Set<Int>()
    while set.count < count {
        set.insert(rng.randomInt(in: 1...95))
    }
    return set.sorted()
}

private func randomPlayerName(for equipo: Equipos, rng: SeededRandom) -> String {
    // Nombres genéricos “Jugador 9 (MEX)”
    let number = rng.randomInt(in: 1...99)
    return "Jugador \(number) (\(equipo.name))"
}

private func generateCardEvents(yellow: Int, red: Int, side: MatchSide, team: Equipos, rng: SeededRandom) -> [CardEvent] {
    var events: [CardEvent] = []
    if yellow > 0 {
        for _ in 0..<yellow {
            events.append(
                CardEvent(
                    minute: rng.randomInt(in: 1...95),
                    side: side,
                    type: .yellow,
                    playerName: randomPlayerName(for: team, rng: rng)
                )
            )
        }
    }
    if red > 0 {
        for _ in 0..<red {
            events.append(
                CardEvent(
                    minute: rng.randomInt(in: 1...95),
                    side: side,
                    type: .red,
                    playerName: randomPlayerName(for: team, rng: rng)
                )
            )
        }
    }
    // Ordenar por minuto ascendente
    events.sort { $0.minute < $1.minute }
    return events
}

private func poissonSample(mean: Double, rng: SeededRandom) -> Int {
    // Knuth's algorithm
    let L = exp(-mean)
    var k = 0
    var p = 1.0
    repeat {
        k += 1
        p *= rng.randomUnit()
    } while p > L
    return max(0, k - 1)
}

private func clamp<T: Comparable>(_ value: T, _ minV: T, _ maxV: T) -> T {
    max(minV, min(value, maxV))
}

private func round(_ value: Double, digits: Int) -> Double {
    let pow10 = pow(10.0, Double(digits))
    return (value * pow10).rounded() / pow10
}

// MARK: - RNG con semilla

private final class SeededRandom {
    private var state: UInt64

    init(seed: Int) {
        // Mezcla la semilla para evitar patrones pobres
        var x = UInt64(bitPattern: Int64(seed))
        x ^= 0x9E3779B97F4A7C15
        x = x &* 0xBF58476D1CE4E5B9
        x ^= x >> 30
        self.state = x
    }

    // Xorshift64*
    private func next() -> UInt64 {
        var x = state
        x ^= x >> 12
        x ^= x << 25
        x ^= x >> 27
        state = x
        return x &* 2685821657736338717
    }

    func randomUnit() -> Double {
        // [0, 1)
        let maxU = Double(UInt64.max)
        return Double(next()) / (maxU + 1.0)
    }

    func randomDouble(in range: ClosedRange<Double>) -> Double {
        let u = randomUnit()
        return range.lowerBound + (range.upperBound - range.lowerBound) * u
    }

    func randomInt(in range: ClosedRange<Int>) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound + 1)
        let r = next() % span
        return range.lowerBound + Int(r)
    }

    func randomBool(probability p: Double) -> Bool {
        randomUnit() < max(0.0, min(1.0, p))
    }
}

// MARK: - Próximos partidos (excluyendo finalizados)

/// Modelo para usar directamente en CardProximo.
struct UpcomingFixture: Identifiable, Hashable {
    let id = UUID()
    let partido: Partido
    let grupo: String
    let fecha: String   // "16/jul"
    let hora: String    // "19:00"
}

enum UpcomingMatchesBuilder {
    /// Genera próximos partidos a partir de grupos barajeados, excluyendo los ya finalizados.
    /// - Parameters:
    ///   - finishedStats: Lista de partidos finalizados (MatchStats) a excluir.
    ///   - count: Cantidad de próximos partidos deseada.
    ///   - startDate: Fecha base para asignar fechas/horas (por defecto 16 JUN 2026 19:00).
    /// - Returns: Lista de UpcomingFixture listos para CardProximo.
    static func generate(excluding finishedStats: [MatchStats], count: Int = 10, startDate: Date? = nil) -> [UpcomingFixture] {
        let finishedPartidos = finishedStats.map { $0.partido }
        return generate(excludingPartidos: finishedPartidos, count: count, startDate: startDate)
    }

    /// Variante que recibe directamente los `Partido` finalizados.
    static func generate(excludingPartidos finished: [Partido], count: Int = 10, startDate: Date? = nil) -> [UpcomingFixture] {
        // Clave canónica para un partido (independiente del orden local/visitante)
        func key(for p: Partido) -> String {
            let a = p.local.name
            let b = p.visitante.name
            return [a, b].sorted().joined(separator: " vs ")
        }

        let finishedKeys = Set(finished.map(key(for:)))

        // Generamos grupos barajeados y sus partidos
        let grupos = generarGruposDesdeEquipos(equiposDetails, mezclar: true)
        var candidatos: [(partido: Partido, grupo: String)] = []
        for g in grupos {
            for p in g.partidos {
                let k = key(for: p)
                if !finishedKeys.contains(k) {
                    candidatos.append((partido: p, grupo: g.nombre))
                }
            }
        }

        // Si no hay suficientes, devolvemos lo que haya.
        let seleccion = Array(candidatos.shuffled().prefix(count))

        // Asignamos fecha/hora deterministas a partir de una base.
        let calendar = Calendar(identifier: .gregorian)
        let baseDate: Date = {
            if let startDate { return startDate }
            var comps = DateComponents()
            comps.year = 2026
            comps.month = 6
            comps.day = 16
            comps.hour = 19
            comps.minute = 0
            return calendar.date(from: comps) ?? Date()
        }()

        let dfFecha = DateFormatter()
        dfFecha.locale = Locale(identifier: "es_ES")
        dfFecha.dateFormat = "dd/MMM" // ejemplo: "16/jul"

        let dfHora = DateFormatter()
        dfHora.locale = Locale(identifier: "es_ES")
        dfHora.dateFormat = "HH:mm"

        return seleccion.enumerated().map { idx, item in
            let fecha = calendar.date(byAdding: .day, value: idx, to: baseDate) ?? baseDate
            return UpcomingFixture(
                partido: item.partido,
                grupo: item.grupo,
                fecha: dfFecha.string(from: fecha).uppercased(),
                hora: dfHora.string(from: fecha)
            )
        }
    }
}
