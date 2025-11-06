//
//  CardEnVivo.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import SwiftUI
import WebKit

struct CardEnVivo: View {
    let partido: Partido
    let grupo: String
    let marcadorLocal: Int
    let marcadorVisitante: Int
    let minuto: Int? // nil si aún no inicia o no disponible

    // URL a abrir en el WebView
    private var url: URL? {
        URL(string: "https://www.plus.fifa.com/es/?gl=mx")
    }

    // Estado para presentar el WebView
    @State private var showWebView = false

    // Pulso del botón FIFA+
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 16) {
                // Lado izquierdo: Equipo local
                equipoView(equipo: partido.local, alignment: .leading)
                    .zIndex(1)
                    .padding(.leading, 50)
                    .offset(y: 15)

                // Centro: Logo, grupo, marcador y minuto
                VStack(spacing: 16) {
                    // Botón con el logo FifaPlus que abre la URL en WebView
                    Button {
                        if url != nil {
                            showWebView = true
                        }
                    } label: {
                        Image("FifaPlus")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            // Efecto “respirar”: escala y una leve sombra para atraer atención
                            .scaleEffect(pulse ? 1.15 : 0.96, anchor: .center)
                            .shadow(color: Color.blue.opacity(pulse ? 0.35 : 0.12),
                                    radius: pulse ? 10 : 4, x: 0, y: pulse ? 4 : 2)
                            .onAppear {
                                guard !reduceMotion else { return }
                                // Animación continua y autoreversible
                                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                                    pulse = true
                                }
                            }
                            .onDisappear {
                                pulse = false
                            }
                    }
                    .buttonStyle(.plain)
                    .offset(y: -5)
                    .accessibilityLabel("Abrir FIFA+")

                    Text(grupo.uppercased())
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundColor(.primary)
                        .offset(y: -12)

                    HStack(alignment: .center, spacing: 20) {
                        Text("\(marcadorLocal)")
                            .font(.custom("FWC2026-NormalBlack", size: 30))
                        Text(":")
                            .font(.custom("FWC2026-NormalBlack", size: 24))
                            .foregroundColor(.primary)
                        Text("\(marcadorVisitante)")
                            .font(.custom("FWC2026-NormalBlack", size: 30))
                    }
                    .offset(y: -20)
                    .foregroundColor(.primary)

                    Text(minutoText)
                        .offset(y: -20)
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.green, lineWidth: 1.5)
                                .offset(x: -1, y: -20)
                                .frame(width: 50)
                        )
                }
                .zIndex(0)
                .frame(maxWidth: 200)

                // Lado derecho: Equipo visitante
                equipoView(equipo: partido.visitante, alignment: .trailing)
                    .zIndex(1)
                    .padding(.trailing, 50)
                    .offset(y: 15)
            }
            //Tamaño de la card
            .frame(width: 350, height: 175)
            .glassEffect(in: .rect(cornerRadius: 25, style: .continuous))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        // Presentación del WebView a pantalla completa
        .fullScreenCover(isPresented: $showWebView) {
            NavigationStack {
                if let url {
                    WebView(url: url)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Cerrar") { showWebView = false }
                            }
                        }
                        .ignoresSafeArea()
                } else {
                    Text("URL inválida")
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Cerrar") { showWebView = false }
                            }
                        }
                        .ignoresSafeArea()
                }
            }
            // Si quieres impedir cerrar con gesto:
            // .interactiveDismissDisabled(true)
        }

    }

    private func equipoView(equipo: Equipos, alignment: HorizontalAlignment) -> some View {
        VStack(spacing: 10) {
            Image(equipo.flag)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 5))

            // Nombre centrado debajo de la bandera
            Text(equipo.name)
                .font(.custom("FWC2026-NormalRegular", size: 20))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: 90, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }

    private var minutoText: String {
        if let m = minuto {
            return "\(m)′"
        } else {
            return "Por iniciar"
        }
    }
}

// Wrapper de WKWebView para SwiftUI
private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Si quisieras recargar al cambiar la URL, podrías hacerlo aquí.
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}

#Preview {
    // Ejemplo de uso con datos reales del proyecto:
    // Tomamos dos equipos de equiposDetails para el partido de prueba.
    let local = equiposDetails[0]
    let visitante = equiposDetails[1]
    let partido = Partido(local: local, visitante: visitante)

    return VStack(spacing: 16) {
        CardEnVivo(
            partido: partido,
            grupo: "Grupo A",
            marcadorLocal: 1,
            marcadorVisitante: 0,
            minuto: 23
        )
    }
    .padding()
}
