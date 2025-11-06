//  pickNDream.swift
//  WorldPass
//
//

import SwiftUI
import Combine
import UIKit
import Lottie



enum APISports {
    static let defaultTZ = "America/Mexico_City"
    static let worldCupSeason = 2026
}



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




extension Font {
    static func fwcBlack(_ size: CGFloat) -> Font { .custom("FWC2026-NormalBlack", size: size) }
    static func fwcRegular(_ size: CGFloat) -> Font { .custom("FWC2026-NormalRegular", size: size) }
}
extension Color {
    static let glassStroke = Color.white.opacity(0.28)
    static let pillGreen   = Color.green.opacity(0.90)
    static let pillRed     = Color.red.opacity(0.90)
}



struct FWCGlassCardBackground: ViewModifier {
    var corner: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(Color.glassStroke, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
extension View { func fwcGlassCard(_ c: CGFloat = 18) -> some View { modifier(FWCGlassCardBackground(corner: c)) } }


private let allowedTeamCodes: Set<String> = Set(equiposDetails.map { $0.name })
private let flagByEquipoDetails: [String: String] =
    Dictionary(uniqueKeysWithValues: equiposDetails.map { ($0.name, $0.flag) })

//



private let fallbackFlagByCode: [String: String] = [
    "MEX":"mex","EGY":"egipto","DEN":"DK","NZL":"NuevaZel","USA":"USA","GHA":"Ghana",
    "JPN":"japon","SRB":"Serbia","CAN":"Canada","GER":"germany","MAR":"Mar","KOR":"corea",
    "ARG":"arg","NGA":"Nig","AUS":"aus","POL":"Pol","FRA":"France","URU":"uruguay",
    "IRN":"iran","CRC":"CostaR","BRA":"brasil","CRO":"Cro","CMR":"camerun","KSA":"arabia",
    "ENG":"Ing","COL":"col","TUR":"Turquia","SUI":"Suiza","ESP":"Spain","BEL":"Belgium",
    "CHI":"chile","SWE":"Suecia","NED":"Ned","CZE":"Cz","RSA":"Sud","ITA":"italia",
    "ECU":"ecu","SVK":"Eslovaquia","TUN":"Tunez","POR":"Por","CIV":"CostaDeMarfil",
    "UKR":"Ucrania","CHN":"China","PRK":"corea","HUN":"Hungria","SVN":"Eslovenia","QAT":"Catar"
]
private func flagAsset(for code: String) -> String {
    if let asset = flagByEquipoDetails[code] { return asset }
    return fallbackFlagByCode[code] ?? "placeholderFlag"
}

//
private let wcStart = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 11))!
private let wcEnd   = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 19))!
private let june11  = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 11))!
private let june12  = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 12))!

// CALENDARIO


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




private func parseDate(_ s: String) -> Date {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.timeZone = TimeZone(identifier: APISports.defaultTZ)
    return f.date(from: s) ?? wcStart
}
private func statusFrom(_ s: String) -> MatchStatus {
    switch s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
    case "FT": return .finished
    case "LIVE": return .live
    default: return .notStarted
    }
}

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

        
        guard allowedTeamCodes.contains(hCode), allowedTeamCodes.contains(aCode) else {
            continue
        }

        
        if !Calendar.current.isDate(date, inSameDayAs: june11) {
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

//
private func logEquiposFaltantes() {
    let lines = CALENDAR_CSV.split(whereSeparator: \.isNewline).map(String.init)
    var usados = Set<String>()
    for line in lines {
        let p = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard p.count >= 6 else { continue }
        usados.insert(p[2]); usados.insert(p[4])
    }
    let faltan = usados.subtracting(allowedTeamCodes).sorted()
    if !faltan.isEmpty {
        print("⚠️ Equipos sin asset:", faltan.joined(separator: ", "))
    } else {
        print("✅ Todos los equipos del CSV tienen asset.")
    }
}


//
final class ConfettiContainerView: UIView {
    private let animationView = LottieAnimationView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        // Configurar animación Lottie
        let animation = LottieAnimation.named("Confetti Rain v2")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()

        // Añadir y ajustar constraints
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        ConfettiContainerView()
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}



// VIEWMODEL
@MainActor final class HoyVM: ObservableObject {
    @Published var allMatches: [UIMatch] = []
    @Published var matchesToday: [UIMatch] = []
    @Published var isLoading = false
    @Published var totalPoints: Int = 50
    @Published var streak: Int = 1
    @Published var selectedDate: Date = wcStart
    @Published var showConfetti: Bool = false

    // Toast de pick realizado
    @Published var showPickToast: Bool = false

    // Identificar partido con recompensa (solo el primero del 12 de junio)
    @Published var rewardMatchID: String? = nil
    private var firstJune12MatchID: String? = nil

    private var hasScheduledTestReward = false

    // Persistencia de selecciones
    @AppStorage("predictions_wc_2026") private var storedPredictionsData: Data = Data()
    @Published var selections: [String: PredictionKind] = [:] {
        didSet { persistSelections() }
    }

    init() {
        loadAll()
        restoreSelections()
        filterForSelectedDate()
        computeFirstJune12MatchID()
        logEquiposFaltantes()
    }

    func loadAll() {
        isLoading = true
        defer { isLoading = false }
        allMatches = loadCalendar()
    }

    func filterForSelectedDate() {
        matchesToday = allMatches.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    func selection(for match: UIMatch) -> PredictionKind? { selections[match.id] }
    func isLocked(_ match: UIMatch) -> Bool { match.status != .notStarted }

    func setSelection(for match: UIMatch, kind: PredictionKind) {
        guard !isLocked(match) else { return }
        selections[match.id] = kind

        // Mostrar toast “Pick realizado”
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            showPickToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.showPickToast = false
            }
        }

        triggerTestRewardIfNeeded(match: match, pick: kind)
    }

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

    private func computeFirstJune12MatchID() {
        let first = allMatches.first { Calendar.current.isDate($0.date, inSameDayAs: june12) }
        firstJune12MatchID = first?.id
    }

    private func triggerTestRewardIfNeeded(match: UIMatch, pick: PredictionKind) {
        // Solo para el primer partido del 12 de junio y si pick es EMPATE (ejemplo)
        guard pick == .signDraw else { return }
        guard Calendar.current.isDate(match.date, inSameDayAs: june12) else { return }
        guard match.id == firstJune12MatchID else { return }
        guard !hasScheduledTestReward else { return }
        hasScheduledTestReward = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            self.totalPoints += 50
            self.streak += 1
            self.rewardMatchID = match.id
            withAnimation { self.showConfetti = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation { self.showConfetti = false }
                self.rewardMatchID = nil
            }
        }
    }

  
    private func persistSelections() {
        do {
            let data = try JSONEncoder().encode(selections.mapValues { $0.rawValue })
            storedPredictionsData = data
        } catch { print("persist error", error) }
    }
    private func restoreSelections() {
        guard !storedPredictionsData.isEmpty else { return }
        do {
            let decoded = try JSONDecoder().decode([String:String].self, from: storedPredictionsData)
            selections = decoded.compactMapValues { PredictionKind(rawValue: $0) }
        } catch { print("restore error", error) }
    }
}




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

struct SelectablePill: View {
    let text: String
    let isSelected: Bool
    var isDisabled: Bool = false
    var highlightAsWin: Bool = false
    var highlightAsLose: Bool = false
    let action: () -> Void

    var body: some View {
        let isWinningSelected = isSelected && highlightAsWin
        let isLosingSelected  = isSelected && highlightAsLose

        Button(action: action) {
            Text(text)
                .font(.fwcBlack(12))
                .foregroundColor((isWinningSelected || isLosingSelected) ? .white : .black)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    isWinningSelected ? Color.pillGreen :
                    (isLosingSelected ? Color.pillRed : Color(.secondarySystemBackground))
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        isWinningSelected ? Color.pillGreen.opacity(0.95) :
                        (isLosingSelected ? Color.pillRed.opacity(0.95) : .black.opacity(isSelected ? 0.9 : 0.25)),
                        lineWidth: (isWinningSelected || isLosingSelected) ? 2 : (isSelected ? 2 : 1)
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        // Mantener tinte visible: no atenuar si fue win/lose ni si es la seleccionada
        .opacity(isDisabled && !(isWinningSelected || isLosingSelected) && !isSelected ? 0.5 : 1)
    }
}

struct PredictionPicker: View {
    let selected: PredictionKind?
    let onSelect: (PredictionKind) -> Void
    var isLocked: Bool = false
    var highlightWin: Bool = false
    var highlightLose: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            SelectablePill(
                text: "LOCAL",
                isSelected: selected == .signHome,
                isDisabled: isLocked,
                highlightAsWin: highlightWin && selected == .signHome,
                highlightAsLose: highlightLose && selected == .signHome
            ) { onSelect(.signHome) }

            SelectablePill(
                text: "EMPATE",
                isSelected: selected == .signDraw,
                isDisabled: isLocked,
                highlightAsWin: highlightWin && selected == .signDraw,
                highlightAsLose: highlightLose && selected == .signDraw
            ) { onSelect(.signDraw) }

            SelectablePill(
                text: "VISITA",
                isSelected: selected == .signAway,
                isDisabled: isLocked,
                highlightAsWin: highlightWin && selected == .signAway,
                highlightAsLose: highlightLose && selected == .signAway
            ) { onSelect(.signAway) }
        }
        .padding(.horizontal, 2)
    }
}

struct TeamPill: View {
    let code: String
    let flagAsset: String
    let alignLeft: Bool
    var name: String? = nil
    let chipText: String?
    let chipWin: Bool?

    var body: some View {
        HStack(spacing: 10) {
            if alignLeft {
                FlagView(flagAsset: flagAsset)
                VStack(alignment: .leading, spacing: 0) {
                    Text(code == "UNK" ? "—" : code).font(.fwcBlack(14)).foregroundColor(.black)
                    
                }
                Spacer(minLength: 0)
                Image(systemName: "checkmark.circle").font(.caption).opacity(0.8)
            } else {
                Image(systemName: "checkmark.circle").font(.caption).opacity(0.8)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(code == "UNK" ? "—" : code).font(.fwcBlack(14)).foregroundColor(.black)
                   
                }
                FlagView(flagAsset: flagAsset)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .fwcGlassCard(22)
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

struct MatchRow: View {
    let match: UIMatch
    let selected: PredictionKind?
    let onSelect: (PredictionKind) -> Void
    let pointsInfo: (value: Int, won: Bool, finished: Bool)
    // Permitir forzar highlight verde durante confetti del partido premiado
    var bonusHighlightWin: Bool = false

    var body: some View {
        let locked = match.status != .notStarted
        let showChip = (selected != nil) && pointsInfo.finished
        let chipText = showChip ? (pointsInfo.won ? "\(pointsInfo.value) pts" : "0 pts") : nil
        let chipWin  = showChip ? pointsInfo.won : nil

        VStack(spacing: 12) {
            HStack {
                Text(match.phase.uppercased())
                    .font(.fwcRegular(11)).foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)

            HStack(spacing: 14) {
                TeamPill(code: match.homeCode,
                         flagAsset: match.homeFlagAsset,
                         alignLeft: true,
                         name: match.homeName,
                         chipText: chipText,
                         chipWin: chipWin)

                Text("VS").font(.fwcBlack(12)).foregroundColor(.black)
                    .frame(width: 28, height: 28)
                    .fwcGlassCard(14)

                TeamPill(code: match.awayCode,
                         flagAsset: match.awayFlagAsset,
                         alignLeft: false,
                         name: match.awayName,
                         chipText: nil,
                         chipWin: nil)
            }
            .padding(12)
            .fwcGlassCard(22)

            PredictionPicker(
                selected: selected,
                onSelect: onSelect,
                isLocked: locked,
                highlightWin: (pointsInfo.finished && pointsInfo.won) || bonusHighlightWin,
                highlightLose: pointsInfo.finished && !pointsInfo.won && selected != nil
            )

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
                    .fwcGlassCard(14)
                    .padding(.trailing, 8)
            }
        }
    }
}




struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.fwcRegular(14))
                .foregroundColor(.secondary)

            Text(value)
                .font(.fwcBlack(18))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .fwcGlassCard(20)
    }
}

struct PickToastView: View {
    var body: some View {
        Text("Pick realizado")
            .font(.fwcBlack(14))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            .accessibilityAddTraits(.isStaticText)
    }
}



// HEADER
struct QuinielaHeader: View {
    let total: Int; let streak: Int
    let onCalendarTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            StatPill(title: "Puntaje", value: "\(total)")
            StatPill(title: "Racha", value: "\(streak)")
            Spacer(minLength: 0)
            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .resizable().scaledToFit()
                    .frame(width: 22, height: 22)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.glassStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Calendario")
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }
}

/* RANKING
struct RankingView: View {
    var body: some View {
        Text("Ranking")
            .font(.fwcBlack(22))
            .navigationTitle("Ranking")
    }
}
*/


// MAIN VIEW
struct PartidosPorFechaView: View {
    @StateObject var vm = HoyVM()
    @State private var showCalendar = false
    @State private var goRanking = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                   
                    QuinielaHeader(
                        total: vm.totalPoints,
                        streak: vm.streak,
                        onCalendarTap: { withAnimation(.spring()) { showCalendar = true } }
                    )
                    .popover(isPresented: $showCalendar, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            DatePicker(
                                "",
                                selection: $vm.selectedDate,
                                in: wcStart...wcEnd,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "es_MX"))
                            .onChange(of: vm.selectedDate) { vm.filterForSelectedDate() }

                            HStack {
                                Spacer()
                                Button("Cerrar") { showCalendar = false }
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                        .frame(minWidth: 360, idealWidth: 420, maxWidth: 480,
                               minHeight: 280, idealHeight: 320, maxHeight: 380)
                        .presentationCompactAdaptation(.popover)
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
                                Text("No hay partidos (con banderas disponibles) para esta fecha.")
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
                                        pointsInfo: vm.points(for: m, selected: sel),
                                        bonusHighlightWin: vm.showConfetti && vm.rewardMatchID == m.id
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }

                if vm.showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                // Toast de pick realizado (centro inferior)
                if vm.showPickToast {
                    VStack {
                        Spacer()
                        PickToastView()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 22)
                    }
                    .padding(.horizontal, 16)
                    .animation(.spring(response: 0.3, dampingFraction: 0.9), value: vm.showPickToast)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .accessibilityHidden(true)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        goRanking = true
                    } label: {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .padding(8)
                            .glassEffect()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Ranking")
                }
            }
            .navigationDestination(isPresented: $goRanking) {
                RankingView()
            }
        }
        .onAppear { vm.filterForSelectedDate() }
    }
}

#Preview {
    PartidosPorFechaView()
}
