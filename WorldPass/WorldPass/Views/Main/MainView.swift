//
//  MainView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI
import Foundation
import Lottie

struct MainView: View {

    private var todosLosPartidos: [(partido: Partido, grupo: String)] {
        var items: [(partido: Partido, grupo: String)] = []
        for grupo in gruposMundial2026 {
            for p in grupo.partidos {
                items.append((partido: p, grupo: grupo.nombre))
            }
        }
        return items
    }

    private func seleccionarPartidosSinRepetidos(from lista: [(partido: Partido, grupo: String)], maxCount: Int) -> [(partido: Partido, grupo: String)] {
        var usados: Set<UUID> = []
        var resultado: [(partido: Partido, grupo: String)] = []

        for item in lista {
            let localID = item.partido.local.id
            let visitanteID = item.partido.visitante.id
            if !usados.contains(localID) && !usados.contains(visitanteID) {
                resultado.append(item)
                usados.insert(localID)
                usados.insert(visitanteID)
                if resultado.count == maxCount { break }
            }
        }
        return resultado
    }

    private var partidosEnVivo: [(partido: Partido, grupo: String)] {
        let barajada = todosLosPartidos.shuffled()
        return seleccionarPartidosSinRepetidos(from: barajada, maxCount: 5)
    }

    private func marcadorFicticio(index: Int) -> (local: Int, visitante: Int, minuto: Int?) {
        let local = (index % 3)
        let visitante = ((index + 1) % 3)
        let minuto = 5 + (index * 13) % 90
        return (local, visitante, minuto)
    }

    @State private var showChatbotFullScreen = false
    @State private var horaSugerida: String = "14:00"
    @State private var probLluvia: Int = 56

    // Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // PRÓXIMOS EVENTOS
                    VStack {
                        HStack {
                            Text("PRÓXIMOS EVENTOS")
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .font(.fwcBlack(20))

                        CardEventos()
                    }

                    // Chatbot
                    ZayuSection(hora: horaSugerida, probLluvia: probLluvia) {
                        showChatbotFullScreen = true
                    }
                    .padding(.top, 4)

                    // HOY EN VIVO
                    if !partidosEnVivo.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("HOY")
                                .font(.fwcBlack(20))
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(.red)
                                    .glassEffect()
                                Text("EN VIVO")
                                    .font(.fwcRegular(15))
                            }
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 50) {
                                ForEach(Array(partidosEnVivo.enumerated()), id: \.offset) { idx, item in
                                    let m = marcadorFicticio(index: idx)
                                    CardEnVivo(
                                        partido: item.partido,
                                        grupo: item.grupo,
                                        marcadorLocal: m.local,
                                        marcadorVisitante: m.visitante,
                                        minuto: m.minuto
                                    )
                                    .frame(width: 300)
                                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.94)
                                            .opacity(phase.isIdentity ? 1.0 : 0.85)
                                    }
                                    .zIndex(1)
                                }
                            }
                            .padding(.horizontal, 40)
                            .contentShape(Rectangle())
                        }
                        .scrollClipDisabled(true)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollTargetLayout()
                    } else {
                        Text("No hay partidos en vivo disponibles")
                            .font(.fwcRegular(14))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
            }
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { Tournament() } label: {
                        Image(systemName: "globe.americas.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .title) {
                    Image("logo")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { ProfileView() } label: {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showChatbotFullScreen = true
                } label: {
                    Image(systemName: "apple.intelligence")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.gray)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                }
                .padding(.trailing, 26)
                .padding(.bottom, 18)
            }
            .sheet(isPresented: $showChatbotFullScreen) {
                ChatbotFlowView()
                    .ignoresSafeArea()
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct ZayuSection: View {
    let hora: String
    let probLluvia: Int
    var onTap: (() -> Void)? = nil

    private let titleSize: CGFloat = 28
    private let cardCorner: CGFloat = 28
    private let bubbleCorner: CGFloat = 24
    private let innerPad: CGFloat = 20

    private let zayuBase: CGFloat = 176
    private let zayuMin: CGFloat  = 148
    private let zayuMax: CGFloat  = 200
    private let zayuOverlap: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¡HOLA, SOY KICKO!")
                .font(.fwcBlack(titleSize))
                .foregroundColor(.black)
                .padding(.horizontal, 2)

            ZStack {
                RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.10), radius: 18, y: 10)

                GeometryReader { geo in
                    let W = geo.size.width
                    let zayuW = max(zayuMin, min(zayuMax, min(zayuBase, W * 0.36)))
                    let reserveTrailing = max(96, zayuW - (zayuOverlap + 12))

                    Circle()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: zayuW * 0.94, height: zayuW * 0.94)
                        .offset(x: (W/2) - (zayuW * 0.35), y: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.45), lineWidth: 1)
                                .frame(width: zayuW * 0.94, height: zayuW * 0.94)
                                .offset(x: (W/2) - (zayuW * 0.35), y: 18)
                        )

                    VStack(alignment: .leading, spacing: 0) {
                        Text(mensaje)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                            .padding(.vertical, 20)
                            .padding(.leading, innerPad)
                            .padding(.trailing, reserveTrailing)
                            .background(
                                RoundedRectangle(cornerRadius: bubbleCorner, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: bubbleCorner)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, innerPad)
                    .padding(.top, innerPad)
                    .padding(.bottom, innerPad + 6)
                    .fixedSize(horizontal: false, vertical: true)

                    // Zayu
                    LottieView(animation: .named("kickoHi"))
                        .playing()
                        .looping()
                        .offset(x:100)
                }
            }
            .frame(minHeight: 270)
            .contentShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
            .onTapGesture { onTap?() }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private var mensaje: AttributedString {
        var regular = AttributeContainer()
        regular.font = .custom("FWC2026-NormalRegular", size: 14)
        regular.foregroundColor = .black.opacity(0.82)

        var bold = AttributeContainer()
        bold.font = .custom("FWC2026-NormalBlack", size: 14)
        bold.foregroundColor = .black

        var s = AttributedString("Recuerda que tienes un partido hoy. Te recomiendo salir a las ")
        s.mergeAttributes(regular)
        var h  = AttributedString(hora); h.mergeAttributes(bold); s.append(h)
        var t1 = AttributedString(" para llegar a tiempo. "); t1.mergeAttributes(regular); s.append(t1)
        var l1 = AttributedString("Lleva paraguas"); l1.mergeAttributes(bold); s.append(l1)
        var t2 = AttributedString(", existe "); t2.mergeAttributes(regular); s.append(t2)
        var p  = AttributedString("\(probLluvia)%"); p.mergeAttributes(bold); s.append(p)
        var t3 = AttributedString(" probabilidad de "); t3.mergeAttributes(regular); s.append(t3)
        var ll = AttributedString("lluvia."); ll.mergeAttributes(bold); s.append(ll)
        return s
    }
}

#Preview {
    ContentView()
        .environmentObject(TabSelection())
}
