//
//  ProfileView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

// Glass Effect
struct GlassBackground: ViewModifier {
    var corner: CGFloat = 14
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: corner, style: .continuous)
            )
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.7), Color.white.opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func glassCard(corner: CGFloat = 14) -> some View {
        self.modifier(GlassBackground(corner: corner))
    }
}

// ProfileView
struct ProfileView: View {
    // Persistimos el nombre del asset elegido como avatar
    @AppStorage("profileAvatarName") private var profileAvatarName: String?
    @State private var showAvatarSheet = false

    // Ajusta aquí los nombres EXACTOS de tus imágenes en Assets.xcassets
    private let appAvatars: [String] = [
        "perfil_zayu", "perfil_maple", "perfil_clutch"
    ]

    // Imagen a mostrar (usa asset si hay selección; si no, placeholder del sistema)
    private var profileImage: Image {
        if let name = profileAvatarName, !name.isEmpty {
            return Image(name)
        } else {
            return Image(systemName: "person.circle.fill")
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                statsView
                matchesSection
            }
        }
        .background(.clear) // fondo transparente
        .sheet(isPresented: $showAvatarSheet) {
            AvatarPickerSheet(
                selectedName: $profileAvatarName,
                availableNames: appAvatars
            )
        }
    }

    // Header
    private var headerView: some View {
        VStack(spacing: 16) {
            // Toca la foto para abrir el selector interno de avatares de la app
            Button {
                showAvatarSheet = true
            } label: {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.6), lineWidth: 3)
                    )
                    .shadow(radius: 5)
                    .foregroundColor(.white.opacity(0.9)) // 👈 hace claro el person.circle.fill

                    .shadow(radius: 5)
                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.30)) // fondo oscuro sutil
                                .frame(width: 32, height: 32)

                            Image(systemName: "pencil")         // solo el lápiz (sin círculo)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .offset(x: 6, y: 6)
                    }
            }
            .buttonStyle(.plain)

            Text("Alex")
                .font(.custom("FWC2026-NormalBlack", size: 20))

            VStack(spacing: 2) { // acercar @ al nombre
                Text("@alexsmith96")
                    .font(.custom("FWC2026-NormalRegular", size: 14))
            }

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
        .padding(.top, 12)
        .background(.clear)
    }

    // Stats (Grid 2x2 con tamaño uniforme)
    private var statsView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            StatCard(icon: "flame.fill",  value: "12",  label: "Días de racha")
            StatCard(icon: "star.fill",   value: "127", label: "Puntos en total")
            StatCard(icon: "figure.run",  value: "3",   label: "Partidos")
            StatCard(icon: "medal.fill",  value: "2",   label: "Top 3")
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: Matches
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    Settings()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// Components

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    private let cardHeight: CGFloat = 74 // altura fija para uniformidad

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black.opacity(0.6))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.custom("FWC2026-NormalBlack", size: 20))
                    .foregroundStyle(.black.opacity(0.75))
                Text(label)
                    .font(.custom("FWC2026-NormalRegular", size: 12))
                    .foregroundStyle(.black.opacity(0.45))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .glassCard(corner: 14)
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
                startPoint: .topLeading, endPoint: .bottomTrailing
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

// Avatar Picker (solo imágenes de la app)
struct AvatarPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedName: String?
    let availableNames: [String]

    private let cols = [GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(availableNames, id: \.self) { name in
                        Button {
                            selectedName = name
                            dismiss()
                        } label: {
                            ZStack {
                                Image(name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                if selectedName == name {
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(.blue, lineWidth: 3)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Elige tu avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(TabSelection())
    }
}
