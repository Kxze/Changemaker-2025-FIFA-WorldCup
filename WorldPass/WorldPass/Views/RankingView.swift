//
//  RankingView.swift
//  WorldPass
//
//  Created by Pau Pau on 19/10/25.
//

import SwiftUI


struct Player: Identifiable {
    let id = UUID()
    var rank: Int
    var name: String
    var score: Int
    var flag: String?
}


struct RankingView: View {
    @State private var showingFriends = false
    @EnvironmentObject var tabSelection: TabSelection
    
    //
    //
    let globalRanking: [Player] = [
        Player(rank: 1, name: "Adrianha", score: 100, flag: "🇲🇽"),
        Player(rank: 2, name: "Arık", score: 90, flag: "🇹🇷"),
        Player(rank: 3, name: "Tanya", score: 80, flag: "🇰🇷"),
        Player(rank: 4, name: "Josepe", score: 70, flag: "🇲🇽"),
        Player(rank: 5, name: "Diego", score: 69, flag: "🇲🇽"),
        Player(rank: 6, name: "Gerard", score: 68, flag: "🏴"),
        Player(rank: 7, name: "Eduard", score: 67, flag: "🇱🇻"),
        Player(rank: 8, name: "Antoine", score: 65, flag: "🇫🇷"),
        Player(rank: 9, name: "Liang", score: 64, flag: "🇯🇵"),
        Player(rank: 10, name: "Mei 美", score: 63, flag: "🇰🇷")
    ]
    
    let friendsRanking: [Player] = [
        Player(rank: 1, name: "Erick", score: 100, flag: "🇲🇽"),
        Player(rank: 2, name: "Adriana", score: 90, flag: "🇲🇽"),
        Player(rank: 3, name: "Tania", score: 80, flag: "🇲🇽"),
        Player(rank: 4, name: "Angel", score: 70, flag: "🇲🇽"),
        Player(rank: 5, name: "Diego", score: 69, flag: "🇲🇽"),
        Player(rank: 6, name: "Leonardo", score: 68, flag: "🇲🇽"),
        Player(rank: 7, name: "Sol", score: 67, flag: "🇲🇽"),
        Player(rank: 8, name: "Gigi", score: 66, flag: "🇲🇽"),
        Player(rank: 9, name: "Pau", score: 65, flag: "🇲🇽"),
        Player(rank: 10, name: "Sandra", score: 63, flag: "🇲🇽")
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                //
                //
                //
                HStack {
                  
                    Button(action: {
                        
                        tabSelection.selection = .main
                    }) {
                        Image("back")
                            .font(.title3.bold())
                            .foregroundColor(.black.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    //
                    Text(showingFriends ? "RANKING AMIGOS" : "RANKING GLOBAL")
                        .font(.custom("FWC2026-NormalBlack", size: 18))
                        .kerning(1)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    //
                    //
                    //
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showingFriends.toggle()
                        }
                    }) {
                        Image(showingFriends ? "RMundial" : "RAmigos")
                            .font(.title3.bold())
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer().frame(height: 30)
                
               //
                //
                //
                
                HStack(alignment: .bottom, spacing: 30) {
                    VStack {
                        TopCircleView(
                            score: showingFriends ? 90 : 90,
                            gradient: LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.white.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom)
                        )
                        Text(showingFriends ? "Adriana" : "Arık")
                            .font(.custom("FWC2026-NormalRegular", size: 14))
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)
                    
                    VStack {
                        TopCircleView(
                            score: 100,
                            gradient: LinearGradient(
                                colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom)
                        )
                        Text(showingFriends ? "Erick" : "Adrianha")
                            .font(.custom("FWC2026-NormalRegular", size: 14))
                            .foregroundColor(.gray)
                    }
                    .offset(y: -15)
                    
                    //
                    
                    VStack {
                        TopCircleView(
                            score: 80,
                            gradient: LinearGradient(
                                colors: [Color.orange.opacity(0.5), Color.yellow.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom)
                        )
                        Text(showingFriends ? "Tania" : "Tanya")
                            .font(.custom("FWC2026-NormalRegular", size: 14))
                            .foregroundColor(.gray)
                    }
                    .offset(y: 20)
                }
                .padding(.bottom, 40)
                
            //
                //
                //
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(showingFriends ? friendsRanking.dropFirst(3) : globalRanking.dropFirst(3)) { player in
                            HStack(spacing: 15) {
                                Text("\(player.rank.formatted(.number.grouping(.automatic)))")
                                    .font(.custom("FWC2026-NormalRegular", size: 14))
                                    .foregroundColor(.gray)
                                    .frame(width: 40, alignment: .leading)
                                
                                Spacer()
                                
                                Text(player.name)
                                    .font(.custom("FWC2026-NormalRegular", size: 16))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if let flag = player.flag {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 34, height: 34)
                                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                        
                                        Text(flag)
                                            .font(.title3)
                                    }
                                }

                                //Spacer()
                                
                                Text("\(player.score)")
                                    .font(.custom("FWC2026-NormalRegular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(
                                RoundedRectangle(cornerRadius: 22) //
                                    .fill(Color.white.opacity(0.7))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        // toolbar
        .overlay(
            VStack {
                Spacer()
                ToolBarView()
                    .environmentObject(tabSelection)
                    .frame(height: 70)
            }
        )
    }
}


struct TopCircleView: View {
    var score: Int
    var gradient: LinearGradient
    
    var body: some View {
        ZStack {
            Circle()
                .fill(gradient)
                .frame(width: 90, height: 90)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            
            Text("\(score)")
                .font(.custom("FWC2026-NormalBlack", size: 22))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 2)
        }
    }
}

#Preview {
    RankingView()
        .environmentObject(TabSelection())
}
