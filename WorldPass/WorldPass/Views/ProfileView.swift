//
//  ProfileView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

// MARK: - Glass Effect
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

// MARK: - ProfileView
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

    // ===== Stacked Cards: estado y datos =====
    @State private var selectedStackCardID: UUID? = nil
    @State private var goToWallet: Bool = false

    private var stackedCardsData: [StackCardData] = [
        .init(
            backgroundName: "FondoVerde",
            title: "GRUPO A PARTIDO INAUGURAL",
            subtitle: "MÉXICO VS HOLANDA",
            footnote: "ESTADIO AZTECA · CDMX · 16 JUL 2026"
        ),
        .init(
            backgroundName: "FondoAzul",
            title: "GRUPO A PARTIDO INAUGURAL",
            subtitle: "ALEMANIA VS JAPÓN",
            footnote: "ESTADIO AZTECA · CDMX · 16 JUL 2026"
        ),
        .init(
            backgroundName: "FondoMorado",
            title: "GRUPO A PARTIDO INAUGURAL",
            subtitle: "QATAR VS ECUADOR",
            footnote: "ESTADIO AZTECA · CDMX · 16 JUL 2026"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                statsView
                stackedCardsSection   // << Reemplaza las MatchCard por esta sección
            }
        }
        .background(.clear) // fondo transparente
        .sheet(isPresented: $showAvatarSheet) {
            AvatarPickerSheet(
                selectedName: $profileAvatarName,
                availableNames: appAvatars
            )
        }
        // Modern programmatic navigation target (iOS 17+)
        .navigationDestination(isPresented: $goToWallet) {
            WalletView()
        }
    }

    // MARK: Header
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
                    .foregroundColor(.white.opacity(0.9)) // placeholder claro

                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.30)) // fondo oscuro sutil
                                .frame(width: 32, height: 32)
                            Image(systemName: "pencil")         // solo el lápiz
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

    // MARK: Stats (Grid 2x2 con tamaño uniforme)
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

    // MARK: Stacked Cards (animación + navegación a WalletView)
    private var stackedCardsSection: some View {
        VStack(alignment: .leading) {
            Text("MIS BOLETOS")
                .font(.custom("FWC2026-NormalBlack", size: 20))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            
            ZStack {
                ForEach(Array(stackedCardsData.enumerated()), id: \.element.id) { (index, item) in
                    let isSelected = selectedStackCardID == item.id
                    let anySelected = selectedStackCardID != nil
                    let isDimmed = anySelected && !isSelected

                    StackCardView(data: item, isSelected: isSelected, isDimmed: isDimmed)
                        // apilado: un poco a la derecha y arriba por carta
                        .offset(x: CGFloat(index) * 60, y: CGFloat(-index) * 10)
                        .zIndex(isSelected ? 100 : Double(index))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedStackCardID = item.id
                            }
                            // deja que se note el énfasis y navega a WalletView
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                goToWallet = true
                                // opcional: reset selección al volver
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    selectedStackCardID = nil
                                }
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .bottomLeading)
            .contentShape(Rectangle())
        }
        .padding(.bottom, 28)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("MI PERFIL")
                    .font(.custom("FWC2026-NormalBlack", size: 20))
            }
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

// MARK: - Components

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

// ===== Stacked Card Models & Views =====
struct StackCardData: Identifiable {
    let id = UUID()
    let backgroundName: String
    let title: String
    let subtitle: String
    let footnote: String
}

struct StackCardView: View {
    let data: StackCardData
    let isSelected: Bool
    let isDimmed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(data.title)
                .font(.custom("FWC2026-NormalRegular", size: 10))
                .foregroundStyle(.white.opacity(0.95))

            Text(data.subtitle)
                .font(.custom("FWC2026-NormalBlack", size: 18))
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer()

            Text(data.footnote)
                .font(.custom("FWC2026-NormalRegular", size: 10))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(16)
        .frame(width: 240, height: 140)
        .background {
            // Fondo con imagen de Assets
            Image(data.backgroundName)
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(isSelected ? 0.18 : 0.08),
                radius: isSelected ? 16 : 8, x: 0, y: isSelected ? 10 : 4)
        .opacity(isDimmed ? 0.65 : 1)
        .scaleEffect(isSelected ? 1.03 : 0.96)
        .rotation3DEffect(.degrees(isSelected ? 0 : 8), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.15), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isDimmed)
    }
}

// MARK: - Avatar Picker (solo imágenes de la app)
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
