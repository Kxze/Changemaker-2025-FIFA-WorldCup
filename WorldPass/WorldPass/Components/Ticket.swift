//
//  Ticket.swift
//  WorldPass
//
//  Created by Kxze on 21/10/25.
//

import SwiftUI

struct Ticket: View {
    // Tamaño controlado (ocupa solo lo necesario)
    private let width: CGFloat = 340
    private let height: CGFloat = 520
    private let corner: CGFloat = 16

    // Duración estimada del symbolEffect (.bounce suele rondar ~0.5–0.7 s)
    private let symbolDuration: Duration = .milliseconds(600)

    // Variantes de tema para la franja inferior y el sheet
    enum Theme {
        case rojo
        case azul
        case verde

        var assetName: String {
            switch self {
            case .rojo:  return "FondoRojo"
            case .azul:  return "FondoAzul"
            case .verde: return "FondoVerde"
            }
        }
    }

    // Payload para generar el QR (puedes pasar uno real desde fuera)
    let qrPayload: String

    // Tema del ticket
    var theme: Theme

    // Sheet interno para mostrar el QR
    @State private var showQRSheet: Bool = false

    init(
        qrPayload: String = "{\"demo\":\"WORLD_PASS\"}",
        theme: Theme = .rojo
    ) {
        self.qrPayload = qrPayload
        self.theme = theme
    }

    var body: some View {
        // Contenedor del ticket compacto
        ticketCardCompact
            .frame(width: width, height: height, alignment: .center)
            // Sheet interno con el fondo según el tema
            .sheet(isPresented: $showQRSheet) {
                QRTicketSheet(payload: qrPayload, backgroundAssetName: theme.assetName)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            }
    }

    //  Compact Card
    @State private var isOn = false
    @State private var isProcessingTap = false

    private var ticketCardCompact: some View {
        
        ZStack {
            // Fondo del ticket
            Image("Ticket")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            // Contenido
            VStack(spacing: 16) {
                // Encabezado
                VStack(alignment: .leading, spacing: 100) {
                    HStack {
                        Text("ESTADIO AZTECA")
                        Spacer()
                        Text("5:00 PM")
                    }
                    .font(.custom("FWC2026-NormalBlack", size: 14))
                    .offset(y: 50)

                    HStack {
                        Text("MÉXICO - HOLANDA")
                        Spacer()
                        Text("16 JULIO")
                    }
                    .font(.custom("FWC2026-NormalRegular", size: 13))
                }

                // Franja inferior con botón para mostrar QR
                ZStack {
                    Image(theme.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(width: 340)
                        .clipped()

                    // Botón centrado que abre el sheet de QR
                    Button {
                        // Evita taps repetidos mientras corre la animación
                        guard !isProcessingTap else { return }
                        isProcessingTap = true

                        Task { @MainActor in
                            // Dispara el efecto
                            isOn.toggle()
                            // Espera a que termine
                            try? await Task.sleep(for: symbolDuration)
                            // Presenta el sheet
                            showQRSheet = true
                            // Opcional: restablece el estado del símbolo para poder repetir la animación en el próximo tap
                            isOn.toggle()
                            isProcessingTap = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "qrcode.viewfinder")
                        }
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(.black)
                        .symbolEffect(.bounce, value: isOn)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.glass)
                }

                // Datos adicionales
                VStack(spacing: 8) {
                    Text("GRUPO A - PARTIDO INAUGURAL")
                        .font(.custom("FWC2026-NormalRegular", size: 12))

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SECCIÓN")
                                .font(.custom("FWC2026-NormalRegular", size: 11))
                                .foregroundStyle(.secondary)
                            Text("GRAL B")
                                .font(.custom("FWC2026-NormalBlack", size: 14))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("ASIENTO")
                                .font(.custom("FWC2026-NormalRegular", size: 11))
                                .foregroundStyle(.secondary)
                            Text("14-F")
                                .font(.custom("FWC2026-NormalBlack", size: 14))
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: width, height: height, alignment: .top)
        }
    }
}

// Sheet de QR con fondo según tema
private struct QRTicketSheet: View {
    let payload: String
    let backgroundAssetName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image(backgroundAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 900)

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer(minLength: 0)

                Text("Código QR del boleto")
                    .font(.custom("FWC2026-NormalBlack", size: 22))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

                // Usa el componente compartido QRCodeView del proyecto
                QRCodeView(payload: payload, size: 260)

                Text("Muestra este código al personal para validar tu acceso.")
                    .font(.custom("FWC2026-NormalBlack", size: 13))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer(minLength: 12)

                Button {
                    dismiss()
                } label: {
                    Text("Cerrar")
                        .font(.custom("FWC2026-NormalBlack", size: 16))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.glass)
                .padding(.bottom, 200)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        // Ejemplos con los 3 fondos
        VStack(spacing: 24) {
            Ticket(qrPayload: "{\"uuid\":\"PREVIEW\",\"ticketId\":\"DEMO-R\"}", theme: .azul)
        }
        .padding()
    }
}
