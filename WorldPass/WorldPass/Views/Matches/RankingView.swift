//
//  RankingView.swift
//  WorldPass
//
//  Created by Pau Pau on 26/10/25.
//

import SwiftUI

// Estado
enum RankingTab { case global, friends }

//  Modelo
struct Player: Identifiable, Hashable {
    let id = UUID()
    let rank: Int
    let name: String
    let points: Int
    let flagAsset: String?
}

// Vista principal
struct RankingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tab: RankingTab = .global

    //
    private let currentUserName: String = "Alex"

    // ====== 
    private var globalPlayers: [Player] = [
           .init(rank: 1560,  name: "Erick",    points: 100, flagAsset: "Noruega"),     // escandinavo
           .init(rank: 1561,  name: "Adriana",  points: 90,  flagAsset: "Spain"),       // España / LatAm
           .init(rank: 1562,  name: "Tania",    points: 80,  flagAsset: "Ucrania"),     // eslavo
           .init(rank: 1563,  name: "Josepe",   points: 79,  flagAsset: "mex"),         // México / hispano
           .init(rank: 1564,  name: "Alex",     points: 69,  flagAsset: "USA"),         // uso global / EUA
           .init(rank: 1565,  name: "Gerard",   points: 68,  flagAsset: "France"),      // Gérard (Francia)
           .init(rank: 1566,  name: "Eduard",   points: 67,  flagAsset: "Ucrania"),     // Europa del este
           .init(rank: 1567,  name: "Antoine",  points: 65,  flagAsset: "France"),      // Francia
           .init(rank: 1568,  name: "Liang",    points: 64,  flagAsset: "japon"),       // Asia oriental (≈)
           .init(rank: 1569, name: "Mei 美",   points: 63,  flagAsset: "corea"),       // Asia oriental (≈)
           .init(rank: 1570, name: "Santiago", points: 62,  flagAsset: "arg"),         // Argentina / hispano
           .init(rank: 1571, name: "Luca",     points: 61,  flagAsset: "italia"),      // Italia
           .init(rank: 1572, name: "Noah",     points: 60,  flagAsset: "USA"),         // EUA / Europa
           .init(rank: 1573, name: "Aisha",    points: 59,  flagAsset: "egipto"),      // mundo árabe / Egipto
           .init(rank: 1574, name: "Yuri",     points: 58,  flagAsset: "Serbia"),      // eslavo (≈)
           .init(rank: 1575, name: "Lea",      points: 57,  flagAsset: "German.svg"),  // Alemania
           .init(rank: 1576, name: "Inés",     points: 56,  flagAsset: "Spain"),       // España
           .init(rank: 1560, name: "Tom",      points: 55,  flagAsset: "Ing"),         // Inglaterra
           .init(rank: 1577, name: "João",     points: 54,  flagAsset: "Por"),         // Portugal
           .init(rank: 1578, name: "Khalid",   points: 53,  flagAsset: "arabia")       // Arabia Saudita
       ]

    private var friendsPlayers: [Player] = [
        .init(rank: 4,  name: "Angel",    points: 70, flagAsset: nil),
        .init(rank: 5,  name: "Alex",     points: 69, flagAsset: nil),
        .init(rank: 6,  name: "Diego", points: 68, flagAsset: nil),
        .init(rank: 7,  name: "Sol",      points: 67, flagAsset: nil),
        .init(rank: 8,  name: "Gigi",     points: 66, flagAsset: nil),
        .init(rank: 10, name: "Pau",      points: 64, flagAsset: nil),
        .init(rank: 11, name: "Sandra",   points: 63, flagAsset: nil),
    ]
    // ==============================================

    var body: some View {
        ZStack { Color.white.ignoresSafeArea()
            VStack(spacing: 0) {

              
                VStack(spacing: 10) {
                    header
                        .padding(.top, 6)

                    TopThreeMedals(
                        centerScore: 100,
                        leftScore: 90,
                        rightScore: 80,
                        centerName: tab == .global ? "أريك" : "Erick",
                        leftName: "Adriana",
                        rightName: tab == .global ? "타냐" : "Tania"
                    )
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.94))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 6)
                        .ignoresSafeArea(edges: .top)
                )

                // Lista
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if tab == .global {
                            ForEach(globalPlayers) { p in
                                PlayerRow(
                                    player: p,
                                    showFlag: true,
                                    isCurrentUser: p.name == currentUserName
                                )
                                .padding(.horizontal, 16)
                            }
                        } else {
                            ForEach(friendsPlayers) { p in
                                PlayerRow(
                                    player: p,
                                    showFlag: false,
                                    isCurrentUser: p.name == currentUserName
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // Header
    private var header: some View {
        ZStack {
            Text(tab == .global ? "RANKING GLOBAL" : "RANKING AMIGOS")
                .font(.fwcBlack(22))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 56)
        }
        .frame(height: 44)
        .overlay {
            HStack(spacing: 12) {
                GlassIcon(system: "chevron.left") { dismiss() }
                Spacer()
                if tab == .global {
                    GlassIcon(system: "person.2.fill") {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) { tab = .friends }
                    }
                } else {
                    GlassIcon(system: "globe") {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) { tab = .global }
                    }
                }
            }
        }
    }
}




struct TopThreeMedals: View {
    let centerScore: Int
    let leftScore: Int
    let rightScore: Int
    let centerName: String
    let leftName: String
    let rightName: String

    var body: some View {
        HStack(spacing: 28) {
            MedalBubble(score: leftScore, name: leftName, size: 72, tint: .gray.opacity(0.32))
                .offset(y: 10)
            MedalBubble(score: centerScore, name: centerName, size: 96, tint: .yellow.opacity(0.45))
            MedalBubble(score: rightScore, name: rightName, size: 72, tint: .orange.opacity(0.33))
                .offset(y: 10)
        }
    }
}

struct MedalBubble: View {
    let score: Int
    let name: String
    let size: CGFloat
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(tint)
                Text("\(score)")
                    .font(.fwcBlack(size * 0.27))
                    .foregroundColor(.black)
                    .kerning(-0.5)
            }
            .frame(width: size, height: size)

            Text(name)
                .font(.fwcRegular(15))
                .foregroundColor(.black.opacity(0.85))
        }
    }
}



struct PlayerRow: View {
    let player: Player
    let showFlag: Bool
    let isCurrentUser: Bool

  
    private let rankColWidth: CGFloat = 58
    private let flagBoxWidth: CGFloat = 30
    private let pointsColWidth: CGFloat = 44

    var body: some View {
        HStack(spacing: 12) {
           
            Text(formatRank(player.rank))
                .font(.fwcBlack(16))
                .foregroundColor(.black.opacity(0.22))
                .kerning(0.6)
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.85)
                .frame(width: rankColWidth, alignment: .leading)

         
            Text(player.name)
                .font(.fwcRegular(15))
                .foregroundColor(.black.opacity(isCurrentUser ? 0.95 : 0.6))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

           
            Group {
                if showFlag, let asset = player.flagAsset {
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.8))
                        .frame(width: flagBoxWidth, height: 28, alignment: .center)
                } else {
                   
                    Color.clear.frame(width: flagBoxWidth, height: 28)
                }
            }

            // PUNTOS
            Text("\(player.points)")
                .font(.fwcBlack(15))
                .foregroundColor(.black.opacity(isCurrentUser ? 0.95 : 0.6))
                .frame(width: pointsColWidth, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Group {
                if isCurrentUser {
                    Color.white.opacity(0.58).background(.ultraThinMaterial)
                } else {
                    Color.white.opacity(0.30).background(.ultraThinMaterial)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(isCurrentUser ? 0.38 : 0.22), lineWidth: 1)
        )
        .opacity(isCurrentUser ? 1 : 0.9)
    }

    ///
    private func formatRank(_ n: Int) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = ","
        let s = fmt.string(from: NSNumber(value: n)) ?? "\(n)"
        return s.replacingOccurrences(of: ",", with: "\u{202F}")
    }
}



//
struct GlassIcon: View {
    var system: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.title3)
                .foregroundColor(.black)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.85), Color.white.opacity(0.25)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                )
        }
        .buttonStyle(.plain)
    }
}



            
#Preview {
                RankingView()
            }
        

