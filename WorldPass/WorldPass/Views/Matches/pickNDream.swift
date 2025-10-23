//  PartidosPorFechaView.swift
//  WorldPass
//
//  Mundial 2026 – Quinielas por día (calendario embebido, DatePicker inline, sin flechas).
//
import SwiftUI
import Foundation
import Combine

// MARK: - CONFIG
enum APISports {
    static let defaultTZ = "America/Mexico_City"
    static let worldCupLeagueId = 1
    static let worldCupSeason   = 2026
    // API real (opcional, mantener comentada)
    // static let base = URL(string:"https://v3.football.api-sports.io")!
    // static let key: String = {
    //     if let k = Bundle.main.object(forInfoDictionaryKey: "API_SPORTS_KEY") as? String, !k.isEmpty { return k }
    //     return "4aea74ce5a44af9b50ad9038b383fb32"
    // }()
}

// MARK: - DOMAIN/UI
enum MatchStatus { case notStarted, live, finished }

struct UIMatch: Identifiable {
    let id: String
    let date: Date
    let status: MatchStatus
    let phase: String
    let homeCode: String
    let awayCode: String
    let homeName: String
    let awayName: String
    let homeScore: Int?
    let awayScore: Int?
    let homeFlagAsset: String
    let awayFlagAsset: String
}

enum PredictionKind: String, Codable, CaseIterable { case signHome, signDraw, signAway }

// MARK: - ESTILOS
extension Font {
    static func fwcBlack(_ size: CGFloat) -> Font { .custom("FWC2026-NormalBlack", size: size) }
    static func fwcRegular(_ size: CGFloat) -> Font { .custom("FWC2026-NormalRegular", size: size) }
}
extension Color {
    static let glassStroke = Color.white.opacity(0.28)
    static let pillGreen   = Color.green.opacity(0.90)
    static let pillRed     = Color.red.opacity(0.90)
    static let captionGray = Color.gray.opacity(0.9)
}

// MARK: - GLASS
struct GlassCardBackground: ViewModifier {
    var corner: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(Color.glassStroke, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
extension View { func glassCard(_ c: CGFloat = 18) -> some View { modifier(GlassCardBackground(corner: c)) } }

// MARK: - FLAGS (ajusta a tus assets locales)
let flagByCode: [String: String] = [
    "MEX":"mex","EGY":"egipto","DEN":"DK","NZL":"NuevaZel",
    "USA":"USA","GHA":"Ghana","JPN":"japon","SRB":"Serbia",
    "CAN":"Canada","GER":"germany","MAR":"Mar","KOR":"corea",
    "ARG":"arg","NGA":"Nig","AUS":"aus","POL":"Pol",
    "FRA":"France","URU":"uruguay","IRN":"iran","CRC":"CostaR",
    "BRA":"brasil","CRO":"Cro","CMR":"camerun","KSA":"arabia",
    "ENG":"Ing","COL":"col","TUR":"Turquia","SUI":"Suiza",
    "ESP":"Spain","BEL":"Belgium","CHI":"chile","SWE":"Suecia",
    "NED":"Ned","CZE":"Cz","RSA":"Sud","ITA":"italia","ECU":"ecu",
    "SVK":"Eslovaquia","TUN":"Tunez","POR":"Por","CIV":"CostaDeMarfil",
    "UKR":"Ucrania","CHN":"China","PRK":"corea","HUN":"Hungria",
    "SVN":"Eslovenia","QAT":"Catar"
]

// MARK: - RANGO / FECHA INICIAL
private let wcStart: Date = {
    var c = DateComponents(); c.year=2026; c.month=6; c.day=11
    return Calendar.current.date(from: c) ?? Date()
}()
private let wcEnd: Date = {
    var c = DateComponents(); c.year=2026; c.month=7; c.day=19
    return Calendar.current.date(from: c) ?? wcStart
}()

// MARK: - CALENDARIO EMBEBIDO (TU LISTA)
// Columnas: date(YYYY-MM-DD),phase,homeCode,homeName,awayCode,awayName,status(NS|LIVE|FT),homeScore,awayScore
// Nota: más abajo forzamos que TODAS las fechas != 2026-06-11 se comporten como NS (apuestas habilitadas).
private let CALENDAR_CSV: String = """
2026-06-11,Grupos A, MEX,México, EGY,Egipto, NS,,
2026-06-11,Grupos G, ENG,Inglaterra, COL,Colombia, LIVE,1,0
2026-06-11,Grupos J, ITA,Italia, ECU,Ecuador, FT,2,0
2026-06-11,Grupos D, ARG,Argentina, POL,Polonia, FT,3,0
2026-06-11,Grupos L, HUN,Hungría, PRK,Corea del Norte, FT,2,1

2026-06-12,Grupos A, DEN,Dinamarca, NZL,Nueva Zelanda, FT,3,0
2026-06-12,Grupos B, USA,Estados Unidos, GHA,Ghana, FT,2,1
2026-06-12,Grupos F, BRA,Brasil, CRO,Croacia, FT,2,1
2026-06-12,Grupos G, TUR,Turquía, SUI,Suiza, FT,1,1
2026-06-12,Grupos J, SVK,Eslovaquia, TUN,Túnez, FT,1,1

2026-06-13,Grupos C, CAN,Canadá, KOR,Corea del Sur, FT,1,0
2026-06-13,Grupos C, GER,Alemania, MAR,Marruecos, FT,2,2
2026-06-13,Grupos E, FRA,Francia, IRN,Irán, FT,4,0
2026-06-13,Grupos H, ESP,España, BEL,Bélgica, FT,1,1
2026-06-13,Grupos I, NED,Países Bajos, CZE,República Checa, FT,2,0
2026-06-13,Grupos K, POR,Portugal, CIV,Costa de Marfil, FT,2,1

2026-06-14,Grupos B, JPN,Japón, SRB,Serbia, FT,0,0
2026-06-14,Grupos E, URU,Uruguay, CRC,Costa Rica, FT,2,1
2026-06-14,Grupos H, CHI,Chile, SWE,Suecia, FT,2,0
2026-06-14,Grupos I, RSA,Sudáfrica, MEX,México B, FT,1,1
2026-06-14,Grupos K, UKR,Ucrania, CHN,China, FT,1,0
2026-06-14,Grupos L, SVN,Eslovenia, QAT,Catar, FT,1,1

2026-06-17,Grupos A, MEX,México, NZL,Nueva Zelanda, FT,4,0
2026-06-17,Grupos D, ARG,Argentina, AUS,Australia, FT,2,1
2026-06-17,Grupos J, ITA,Italia, TUN,Túnez, FT,3,1
2026-06-17,Grupos L, SVN,Eslovenia, PRK,Corea del Norte, FT,2,0

2026-06-18,Grupos A, DEN,Dinamarca, EGY,Egipto, FT,1,1
2026-06-18,Grupos D, NGA,Nigeria, POL,Polonia, FT,2,0
2026-06-18,Grupos G, COL,Colombia, TUR,Turquía, FT,2,1
2026-06-18,Grupos H, BEL,Bélgica, CHI,Chile, FT,2,1
2026-06-18,Grupos K, CIV,Costa de Marfil, UKR,Ucrania, FT,1,1
2026-06-18,Grupos L, HUN,Hungría, QAT,Catar, FT,1,0

2026-06-19,Grupos B, USA,Estados Unidos, SRB,Serbia, FT,3,0
2026-06-19,Grupos C, CAN,Canadá, MAR,Marruecos, FT,1,1
2026-06-19,Grupos E, FRA,Francia, CRC,Costa Rica, FT,2,1
2026-06-19,Grupos F, CRO,Croacia, CMR,Camerún, FT,2,0

2026-06-20,Grupos C, GER,Alemania, KOR,Corea del Sur, FT,3,1
2026-06-20,Grupos E, URU,Uruguay, IRN,Irán, FT,3,0
2026-06-20,Grupos H, ESP,España, SWE,Suecia, FT,3,0
2026-06-20,Grupos I, CZE,República Checa, RSA,Sudáfrica, FT,2,2
2026-06-20,Grupos K, POR,Portugal, CHN,China, FT,3,0

2026-06-24,Grupos A, MEX,México, DEN,Dinamarca, FT,1,1
2026-06-24,Grupos D, ARG,Argentina, NGA,Nigeria, FT,1,1
2026-06-24,Grupos L, PRK,Corea del Norte, QAT,Catar, FT,1,1
2026-06-24,Grupos J, ITA,Italia, SVK,Eslovaquia, FT,1,1

2026-06-25,Grupos A, EGY,Egipto, NZL,Nueva Zelanda, FT,2,1
2026-06-25,Grupos G, ENG,Inglaterra, TUR,Turquía, FT,3,0
2026-06-25,Grupos J, ECU,Ecuador, TUN,Túnez, FT,2,0
2026-06-25,Grupos L, HUN,Hungría, SVN,Eslovenia, FT,0,0

2026-06-26,Grupos B, USA,Estados Unidos, JPN,Japón, FT,1,2
2026-06-26,Grupos C, GER,Alemania, CAN,Canadá, FT,2,0
2026-06-26,Grupos F, BRA,Brasil, CMR,Camerún, FT,1,1
2026-06-26,Grupos F, CRO,Croacia, KSA,Arabia Saudita, FT,3,0

2026-06-27,Grupos C, MAR,Marruecos, KOR,Corea del Sur, FT,2,0
2026-06-27,Grupos E, FRA,Francia, URU,Uruguay, FT,1,0
2026-06-27,Grupos H, BEL,Bélgica, SWE,Suecia, FT,1,0
2026-06-27,Grupos I, NED,Países Bajos, RSA,Sudáfrica, FT,1,1

2026-07-03,Dieciseisavos, MEX,México, SUI,Suiza, FT,2,0
2026-07-03,Dieciseisavos, JPN,Japón, EGY,Egipto, FT,0,1

2026-07-04,Dieciseisavos, GER,Alemania, CAN,Canadá, FT,3,1
2026-07-04,Dieciseisavos, ARG,Argentina, CHI,Chile, FT,2,0

2026-07-05,Dieciseisavos, FRA,Francia, RSA,Sudáfrica, FT,3,0
2026-07-05,Dieciseisavos, BRA,Brasil, UKR,Ucrania, FT,2,1

2026-07-06,Dieciseisavos, ENG,Inglaterra, CRC,Costa Rica, FT,2,0
2026-07-06,Dieciseisavos, ESP,España, AUS,Australia, FT,1,1

2026-07-08,Octavos, MEX,México, JPN,Japón, FT,1,1
2026-07-08,Octavos, ARG,Argentina, GER,Alemania, FT,2,1

2026-07-09,Octavos, FRA,Francia, BRA,Brasil, FT,2,2
2026-07-09,Octavos, ENG,Inglaterra, ESP,España, FT,2,1

2026-07-12,Cuartos, MEX,México, ARG,Argentina, FT,1,2
2026-07-12,Cuartos, FRA,Francia, ENG,Inglaterra, FT,1,0

2026-07-13,Cuartos, NED,Países Bajos, HUN,Hungría, FT,2,0
2026-07-13,Cuartos, USA,Estados Unidos, ECU,Ecuador, FT,2,1

2026-07-16,Semifinal, ARG,Argentina, FRA,Francia, FT,2,1
2026-07-17,Semifinal, NED,Países Bajos, USA,Estados Unidos, FT,1,2

2026-07-18,Tercer Puesto, FRA,Francia, NED,Países Bajos, FT,2,1
2026-07-19,Final, ARG,Argentina, USA,Estados Unidos, FT,2,0
"""

// MARK: - PARSER / AJUSTE DE ESTADOS PARA PERMITIR APUESTAS
private func parseDate(_ ymd: String) -> Date {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = TimeZone(identifier: APISports.defaultTZ)
    return f.date(from: ymd) ?? wcStart
}
private func statusFrom(_ s: String) -> MatchStatus {
    switch s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
    case "FT": return .finished
    case "LIVE": return .live
    default: return .notStarted
    }
}
private func flagAsset(for code: String) -> String {
    flagByCode[code] ?? "placeholderFlag"
}

private let june11 = "2026-06-11"

private func loadCalendar() -> [UIMatch] {
    var out: [UIMatch] = []
    let lines = CALENDAR_CSV
        .split(whereSeparator: \.isNewline)
        .map { String($0).trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty && !$0.hasPrefix("#") }

    for (i, line) in lines.enumerated() {
        let parts = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 9 else { continue }
        let dateStr  = parts[0]
        let date     = parseDate(dateStr)
        let phase    = parts[1]
        let hCode    = parts[2], hName = parts[3]
        let aCode    = parts[4], aName = parts[5]
        var status   = statusFrom(parts[6])
        var hScore   = Int(parts[7])
        var aScore   = Int(parts[8])

        // Regla: salvo el 11/jun, todos los partidos se consideran "no iniciados"
        // para que se pueda apostar en cualquier día del torneo.
        if dateStr != june11 {
            status = .notStarted
            hScore = nil
            aScore = nil
        }

        out.append(
            UIMatch(
                id: "wc26-\(i)-\(hCode)-\(aCode)",
                date: date,
                status: status,
                phase: phase,
                homeCode: hCode,
                awayCode: aCode,
                homeName: hName,
                awayName: aName,
                homeScore: hScore,
                awayScore: aScore,
                homeFlagAsset: flagAsset(for: hCode),
                awayFlagAsset: flagAsset(for: aCode)
            )
        )
    }
    return out.sorted { $0.date < $1.date }
}

// MARK: - HEADER (sin flechas)
struct QuinielaHeader: View {
    let total: Int; let streak: Int
    let dateText: String
    let onTogglePicker: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                HStack(spacing: 6) { Image(systemName: "trophy.fill"); Text("26").font(.fwcBlack(20)) }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 2)

            HStack(spacing: 12) {
                StatPill(title: "Puntaje", value: "\(total)")
                StatPill(title: "Racha", value: "\(streak)")
                Spacer()
                Button(action: onTogglePicker) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(dateText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassCard(20)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
    }
}
struct StatPill: View {
    let title: String; let value: String
    var body: some View {
        HStack(spacing: 8) {
            Text(title).font(.fwcRegular(14)).foregroundColor(.secondary)
            Text(value).font(.fwcBlack(18))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassCard(20)
    }
}

// MARK: - IMAGE HELPER
@ViewBuilder
private func FlagView(flagAsset: String, size: CGSize = .init(width: 36, height: 24)) -> some View {
    if UIImage(named: flagAsset) != nil {
        Image(flagAsset).resizable().scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    } else {
        Color.secondary.opacity(0.15)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - ROWS
struct MatchRow: View {
    let match: UIMatch
    let selected: PredictionKind?
    let onSelect: (PredictionKind) -> Void
    let pointsInfo: (value: Int, won: Bool, finished: Bool)

    var body: some View {
        let locked = match.status != .notStarted
        let showChip = (selected != nil) && pointsInfo.finished
        let chipText = showChip ? (pointsInfo.won ? "\(pointsInfo.value) pts" : "0 pts") : nil
        let chipWin  = showChip ? pointsInfo.won : nil

        VStack(spacing: 12) {
            HStack {
                Text(match.phase.uppercased())
                    .font(.fwcRegular(11))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)

            HStack(spacing: 14) {
                TeamPill(code: match.homeCode,
                         flagAsset: match.homeFlagAsset,
                         alignLeft: true,
                         chipText: chipText,
                         chipWin: chipWin,
                         name: match.homeName)

                Text("VS").font(.fwcBlack(12))
                    .frame(width: 28, height: 28)
                    .glassCard(14)

                TeamPill(code: match.awayCode,
                         flagAsset: match.awayFlagAsset,
                         alignLeft: false,
                         chipText: nil,
                         chipWin: nil,
                         name: match.awayName)
            }
            .padding(12)
            .glassCard(22)

            PredictionPicker(selected: selected, onSelect: onSelect, isLocked: locked)

            Text(match.status == .finished ? "FINALIZADO" :
                 (match.status == .live ? "EN JUEGO" : "AÚN NO COMIENZA EL JUEGO"))
                .font(.fwcBlack(12))
                .foregroundColor(.secondary)
        }
        .overlay(alignment: .topTrailing) {
            if locked {
                Label(match.status == .finished ? "No disponible" : "Cierra al inicio",
                      systemImage: match.status == .finished ? "lock.fill" : "lock")
                    .font(.fwcRegular(11))
                    .padding(8)
                    .glassCard(14)
                    .padding(.trailing, 8)
            }
        }
    }
}

struct PredictionPicker: View {
    let selected: PredictionKind?
    let onSelect: (PredictionKind) -> Void
    var isLocked: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            SelectablePill(text: "LOCAL",  isSelected: selected == .signHome,  isDisabled: isLocked) { onSelect(.signHome) }
            SelectablePill(text: "EMPATE", isSelected: selected == .signDraw,  isDisabled: isLocked) { onSelect(.signDraw) }
            SelectablePill(text: "VISITA", isSelected: selected == .signAway,  isDisabled: isLocked) { onSelect(.signAway) }
        }
        .padding(.horizontal, 2)
        .opacity(isLocked ? 0.5 : 1)
    }
}

struct SelectablePill: View {
    let text: String
    let isSelected: Bool
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.fwcBlack(12))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? Color.black.opacity(0.85) : Color(.secondarySystemBackground))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: isSelected ? 0 : 1))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct TeamPill: View {
    let code: String
    let flagAsset: String
    let alignLeft: Bool
    let chipText: String?
    let chipWin: Bool?
    var name: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if alignLeft {
                FlagView(flagAsset: flagAsset)
                VStack(alignment: .leading, spacing: 0) {
                    Text(code == "UNK" ? "—" : code).font(.fwcBlack(14))
                    if let name { Text(name).font(.fwcRegular(11)).foregroundColor(.secondary) }
                }
                Spacer(minLength: 0)
                Image(systemName: "checkmark.circle").font(.caption).opacity(0.8)
            } else {
                Image(systemName: "checkmark.circle").font(.caption).opacity(0.8)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(code == "UNK" ? "—" : code).font(.fwcBlack(14))
                    if let name { Text(name).font(.fwcRegular(11)).foregroundColor(.secondary) }
                }
                FlagView(flagAsset: flagAsset)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard(22)
        .overlay(alignment: .center) {
            if let chipText, let chipWin {
                Text(chipText)
                    .font(.fwcBlack(12)).foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(chipWin ? Color.pillGreen : Color.pillRed)
                    .clipShape(Capsule())
                    .shadow(radius: 2, x: 0, y: 1)
                    .offset(y: 22)
            }
        }
    }
}

// MARK: - VIEW MODEL
@MainActor final class HoyVM: ObservableObject {
    @Published var allMatches: [UIMatch] = []
    @Published var matchesToday: [UIMatch] = []
    @Published var isLoading = false
    @Published var totalPoints: Int = 50
    @Published var streak: Int = 1

    @Published var selectedDate: Date = wcStart

    // Persistencia de selecciones
    @AppStorage("predictions_wc_2026") private var storedPredictionsData: Data = Data()
    @Published var selections: [String: PredictionKind] = [:] {
        didSet { self.persistSelections() }
    }

    init() {
        self.loadAll()
        self.restoreSelections()
        self.filterForSelectedDate()
    }

    func loadAll() {
        isLoading = true
        defer { isLoading = false }
        self.allMatches = loadCalendar()
    }

    func filterForSelectedDate() {
        let cal = Calendar.current
        self.matchesToday = allMatches.filter { cal.isDate($0.date, inSameDayAs: selectedDate) }
    }

    func selection(for match: UIMatch) -> PredictionKind? { selections[match.id] }
    func isLocked(_ match: UIMatch) -> Bool { match.status != .notStarted }

    func setSelection(for match: UIMatch, kind: PredictionKind) {
        guard !isLocked(match) else { return }
        selections[match.id] = kind
    }

    // Puntos: solo si terminó (20 acierto, 0 fallo). Si no apostaste, no hay chip.
    func points(for match: UIMatch, selected: PredictionKind?) -> (value: Int, won: Bool, finished: Bool) {
        guard match.status == .finished, let h = match.homeScore, let a = match.awayScore else {
            return (0, false, false)
        }
        guard let pick = selected else { return (0, false, true) }
        switch pick {
        case .signDraw: return (h == a ? 20 : 0, h == a, true)
        case .signHome: return (h > a ? 20 : 0, h > a, true)
        case .signAway: return (a > h ? 20 : 0, a > h, true)
        }
    }

    // Persistencia
    private func persistSelections() {
        do {
            let data = try JSONEncoder().encode(selections.mapValues { $0.rawValue })
            storedPredictionsData = data
        } catch {
            print("persist error", error)
        }
    }

    private func restoreSelections() {
        guard !storedPredictionsData.isEmpty else { return }
        do {
            let decoded = try JSONDecoder().decode([String:String].self, from: storedPredictionsData)
            selections = decoded.compactMapValues { PredictionKind(rawValue: $0) }
        } catch {
            print("restore error", error)
        }
    }
}

// MARK: - VIEW PRINCIPAL
struct PartidosPorFechaView: View {
    @StateObject var vm = HoyVM()
    @State private var showInlinePicker = true // visible por defecto

    private var dateFormatter: DateFormatter {
        let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .none
        df.locale = Locale(identifier: "es_MX"); df.timeZone = TimeZone(identifier: APISports.defaultTZ)
        return df
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                QuinielaHeader(
                    total: vm.totalPoints,
                    streak: vm.streak,
                    dateText: dateFormatter.string(from: vm.selectedDate),
                    onTogglePicker: { withAnimation(.spring()) { showInlinePicker.toggle() } }
                )

                if showInlinePicker {
                    HStack {
                        DatePicker(
                            "Selecciona",
                            selection: $vm.selectedDate,
                            in: wcStart...wcEnd,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .onChange(of: vm.selectedDate) { _ in vm.filterForSelectedDate() }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Text("PARTIDOS")
                    .font(.fwcBlack(22))
                    .padding(.horizontal, 16)
                    .padding(.top, 2)

                ScrollView {
                    LazyVStack(spacing: 18) {
                        if vm.isLoading {
                            ProgressView().padding(.top, 40)
                        } else if vm.matchesToday.isEmpty {
                            Text("No hay partidos para esta fecha.")
                                .font(.fwcRegular(14))
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(vm.matchesToday) { m in
                                let sel = vm.selection(for: m)
                                MatchRow(
                                    match: m,
                                    selected: sel,
                                    onSelect: { vm.setSelection(for: m, kind: $0) },
                                    pointsInfo: vm.points(for: m, selected: sel)
                                )
                                .padding(.horizontal, 16)
                            }
                            Text(" Apuestas habilitadas en partidos que aún no cominezan.")
                                .font(.fwcRegular(13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 24)
                                .padding(.horizontal, 24)
                        }
                    }
                }
            }
        }
        .onAppear { vm.filterForSelectedDate() }
    }
}

struct PartidosPorFechaView_Previews: PreviewProvider {
    static var previews: some View {
        PartidosPorFechaView().preferredColorScheme(.light)
    }
}
