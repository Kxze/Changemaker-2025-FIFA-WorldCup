//
//  ProfileView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                statsView
                matchesSection
            }
        }
        
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("MI PERFIL")
                    .font(.custom("FWC2026-NormalBlack", size: 20))
                Spacer()
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.orange)
            
            Text("Alex")
                .font(.custom("FWC2026-NormalBlack", size: 20))
            
            Text("@alexsmith96")
                .font(.custom("FWC2026-NormalRegular", size: 14))
            
            HStack(spacing: 40) {
                VStack {
                    Text("15")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("Siguiendo")
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                }
                
                VStack {
                    Text("12")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("Seguidores")
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Añadir amigos")
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                }
                .foregroundColor(.gray)
                .font(.system(size: 16))
            }
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
    
    private var statsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(icon: "flame.fill", value: "12", label: "Días de racha")
                StatCard(icon: "star.fill", value: "127", label: "Puntos en total")
            }
            
            HStack(spacing: 12) {
                StatCard(icon: "figure.run", value: "3", label: "Partidos asistidos")
                StatCard(icon: "medal.fill", value: "2", label: "Top 3")
            }
        }
        .padding()
    }
    
    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PARTIDOS")
                .font(.custom("FWC2026-NormalBlack", size: 20))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    MatchCard(
                        color: Color.green,
                        group: "GRUPO A PARTIDO INAUGURAL",
                        teams: "MÉXICO VS\nHOLANDA",
                        estadio: "ESTADIO AZTECA\nCDMX",
                        fecha: "16 DE JUL 2026"
                    )
                    
                    MatchCard(
                        color: Color.yellow,
                        group: "GRUPO A PARTIDO INAUGURAL",
                        teams: "ALEMANIA VS\nJAPÓN",
                        estadio: "ESTADIO AZTECA\nCDMX",
                        fecha: "16 DE JUL 2026"
                    )
                    
                    MatchCard(
                        color: Color.cyan,
                        group: "GRUPO A PARTIDO INAUGURAL",
                        teams: "QATAR VS\nECUADOR",
                        estadio: "ESTADIO AZTECA\nCDMX",
                        fecha: "16 DE JUL 2026"
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(value)
                    .font(.custom("FWC2026-NormalBlack", size: 20))
            }
            
            Text(label)
                .font(.custom("FWC2026-NormalRegular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct MatchCard: View {
    let color: Color
    let group: String
    let teams: String
    let estadio: String
    let fecha: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group)
                .font(.custom("FWC2026-NormalRegular", size: 10))
                .foregroundColor(.white)
            
            Text(teams)
                .font(.custom("FWC2026-NormalBlack", size: 20))
                .foregroundColor(.white)
            
            Text(estadio)
                .font(.custom("FWC2026-NormalRegular", size: 10))
                .foregroundColor(.white)
            
            Text(fecha)
                .font(.custom("FWC2026-NormalRegular", size: 10))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .frame(width: 200, height: 220)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            Image(systemName: "soccerball")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.2))
                .offset(x: 50, y: 80),
            alignment: .topLeading
        )
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(TabSelection())
    }
}
