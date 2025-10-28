//
//  MatchStatsSectionView.swift
//  WorldPass
//
//  Created by Assistant on 24/10/25.
//

import SwiftUI

struct MatchStatsSectionView: View {
    let match: MatchStats
    let localLineup: Lineup
    let visitLineup: Lineup

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Goleadores y minutos, alineados a cada lado (usando nombres de la alineación)
            goalEventsSection(match: match, localLineup: localLineup, visitLineup: visitLineup)
                .padding(.top, -6)
                .padding(.horizontal, 12)

            // ESTADÍSTICAS DEL PARTIDO
            statsSection(match: match)
        }
    }

    // MARK: - Goleadores por lado (usando nombres de la alineación)

    private func goalEventsSection(match: MatchStats, localLineup: Lineup, visitLineup: Lineup) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Local (izquierda)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(match.local.goalEvents.enumerated()), id: \.element.id) { idx, ev in
                    HStack(spacing: 6) {
                        Text("\(ev.minute)'")
                            .font(.custom("FWC2026-NormalBlack", size: 12))
                            .foregroundStyle(.secondary)
                        Text(scorerName(from: localLineup, at: idx))
                            .font(.custom("FWC2026-NormalRegular", size: 12))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Visitante (derecha)
            VStack(alignment: .trailing, spacing: 6) {
                ForEach(Array(match.visitante.goalEvents.enumerated()), id: \.element.id) { idx, ev in
                    HStack(spacing: 6) {
                        Text(scorerName(from: visitLineup, at: idx))
                            .font(.custom("FWC2026-NormalRegular", size: 12))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("\(ev.minute)'")
                            .font(.custom("FWC2026-NormalBlack", size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 8)
    }

    private func scorerName(from lineup: Lineup, at index: Int) -> String {
        // Prioriza FW, luego MF, DF y GK
        let ordered: [Player] =
            lineup.players.filter { $0.position == .FW } +
            lineup.players.filter { $0.position == .MF } +
            lineup.players.filter { $0.position == .DF } +
            lineup.players.filter { $0.position == .GK }

        guard !ordered.isEmpty else { return "Jugador" }
        let p = ordered[index % ordered.count]
        return p.name
    }

    // MARK: - ESTADÍSTICAS DEL PARTIDO

    private func statsSection(match: MatchStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ESTADÍSTICAS")
                .font(.custom("FWC2026-NormalBlack", size: 16))
                .padding(.leading, 2)

            // Barras comparativas (posesión, tiros, xG)
            compareRow(
                title: "Posesión",
                leftText: "\(Int(match.local.possession))%",
                rightText: "\(Int(match.visitante.possession))%",
                leftValue: match.local.possession,
                rightValue: match.visitante.possession,
                maxValue: 100
            )

            compareRow(
                title: "Tiros",
                leftText: "\(match.local.shots)",
                rightText: "\(match.visitante.shots)",
                leftValue: Double(match.local.shots),
                rightValue: Double(match.visitante.shots),
                maxValue: Double(max(1, max(match.local.shots, match.visitante.shots)))
            )

            compareRow(
                title: "xG",
                leftText: String(format: "%.2f", match.local.expectedGoals),
                rightText: String(format: "%.2f", match.visitante.expectedGoals),
                leftValue: match.local.expectedGoals,
                rightValue: match.visitante.expectedGoals,
                maxValue: max(0.1, max(match.local.expectedGoals, match.visitante.expectedGoals))
            )

            // Tabla comparativa para el resto
            statRow(title: "A puerta", left: "\(match.local.shotsOnTarget)", right: "\(match.visitante.shotsOnTarget)")
            statRow(title: "Corners", left: "\(match.local.corners)", right: "\(match.visitante.corners)")
            statRow(title: "Offsides", left: "\(match.local.offsides)", right: "\(match.visitante.offsides)")
            statRow(title: "Faltas", left: "\(match.local.foulsCommitted)", right: "\(match.visitante.foulsCommitted)")
            statRow(title: "Amarillas", left: "\(match.local.yellowCards)", right: "\(match.visitante.yellowCards)")
            statRow(title: "Rojas", left: "\(match.local.redCards)", right: "\(match.visitante.redCards)")
            statRow(title: "Pases", left: "\(match.local.passes)", right: "\(match.visitante.passes)")
            statRow(
                title: "Precisión de pase",
                left: "\(Int(match.local.passAccuracy))%",
                right: "\(Int(match.visitante.passAccuracy))%"
            )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func statRow(title: String, left: String, right: String) -> some View {
        HStack {
            Text(left)
                .font(.custom("FWC2026-NormalBlack", size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.custom("FWC2026-NormalRegular", size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 140)
                .minimumScaleFactor(0.8)

            Text(right)
                .font(.custom("FWC2026-NormalBlack", size: 14))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }

    private func compareRow(
        title: String,
        leftText: String,
        rightText: String,
        leftValue: Double,
        rightValue: Double,
        maxValue: Double
    ) -> some View {
        VStack(spacing: 6) {
            statRow(title: title, left: leftText, right: rightText)
            compareBar(leftValue: leftValue, rightValue: rightValue, maxValue: maxValue)
        }
    }

    private func compareBar(leftValue: Double, rightValue: Double, maxValue: Double) -> some View {
        let total = max(0.0001, leftValue + rightValue)
        let leftRatio = total > 0 ? leftValue / total : 0.5
        let rightRatio = 1.0 - leftRatio

        return GeometryReader { geo in
            let width = geo.size.width
            let leftW = width * leftRatio
            let rightW = width * rightRatio

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 8)

                HStack(spacing: 0) {
                    Capsule()
                        .fill(Color("Verde").opacity(0.9))
                        .frame(width: leftW, height: 8)

                    Capsule()
                        .fill(Color("Azul").opacity(0.9))
                        .frame(width: rightW, height: 8)
                }
            }
        }
        .frame(height: 8)
        .animation(.easeInOut(duration: 0.35), value: leftValue + rightValue + maxValue)
    }
}
