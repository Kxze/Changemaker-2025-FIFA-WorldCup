//
//  Ticket.swift
//  WorldPass
//

import SwiftUI

// MARK: - TICKET (card compacto con QR + Indicaciones)
struct Ticket: View {
    private let width: CGFloat = 340
    private let height: CGFloat = 520
    private let corner: CGFloat = 16
    private let symbolDuration: Duration = .milliseconds(600)

    enum Theme { case rojo, azul, verde
        var assetName: String {
            switch self {
            case .rojo:  return "FondoRojo"
            case .azul:  return "FondoAzul"
            case .verde: return "FondoVerde"
            }
        }
    }

    // Datos del evento
    let qrPayload: String
    var theme: Theme
    var estadio: String
    var hora: String
    var duelo: String
    var fecha: String
    var piso: String
    var puerta: String
    var seccion: String
    var fila: String
    var asiento: String

    @State private var showQRSheet = false
    @State private var isOn = false
    @State private var isProcessingTap = false
    @State private var showSeatPlanner = false

    init(
        qrPayload: String = #"{"demo":"WORLD_PASS"}"#,
        theme: Theme = .verde,
        estadio: String = "ESTADIO AZTECA",
        hora: String = "5:00 PM",
        duelo: String = "MÉXICO - HOLANDA",
        fecha: String = "16 JUL 2026",
        piso: String = "Piso 2",
        puerta: String = "Puerta 6",
        seccion: String = "E 28",
        fila: String = "C",
        asiento: String = "7"
    ) {
        self.qrPayload = qrPayload
        self.theme = theme
        self.estadio = estadio
        self.hora = hora
        self.duelo = duelo
        self.fecha = fecha
        self.piso = piso
        self.puerta = puerta
        self.seccion = seccion
        self.fila = fila
        self.asiento = asiento
    }

    var body: some View {
        ZStack {
            Image("Ticket")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            VStack(spacing: 16) {
                // Encabezado
                VStack(alignment: .leading, spacing: 100) {
                    HStack {
                        Text(estadio)
                        Spacer()
                        Text(hora)
                    }
                    .font(.custom("FWC2026-NormalBlack", size: 14))
                    .offset(y: 50)

                    HStack {
                        Text(duelo)
                        Spacer()
                        Text(fecha)
                    }
                    .font(.custom("FWC2026-NormalRegular", size: 13))
                }

                // Franja inferior con acciones
                ZStack {
                    Image(theme.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(width: width)
                        .clipped()

                    VStack(spacing: 10) {
                        Button {
                            guard !isProcessingTap else { return }
                            isProcessingTap = true
                            Task { @MainActor in
                                isOn.toggle()
                                try? await Task.sleep(for: symbolDuration)
                                showQRSheet = true
                                isOn.toggle()
                                isProcessingTap = false
                            }
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundStyle(.black)
                                .symbolEffect(.bounce, value: isOn)
                                .padding(.vertical, 2)
                        }
                        .buttonStyle(.glass)

                        Button { showSeatPlanner = true } label: {
                            Text("Indicaciones para llegar al asiento")
                                .font(.custom("FWC2026-NormalBlack", size: 14))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)
                        .padding(.horizontal, 16)
                    }
                    .frame(width: width)
                }

                // Datos extra
                VStack(spacing: 8) {
                    Text("GRUPO A - PARTIDO INAUGURAL")
                        .font(.custom("FWC2026-NormalRegular", size: 12))

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SECCIÓN")
                                .font(.custom("FWC2026-NormalRegular", size: 11))
                                .foregroundStyle(.secondary)
                            Text(seccion)
                                .font(.custom("FWC2026-NormalBlack", size: 14))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("ASIENTO")
                                .font(.custom("FWC2026-NormalRegular", size: 11))
                                .foregroundStyle(.secondary)
                            Text("\(asiento)-\(fila)")
                                .font(.custom("FWC2026-NormalBlack", size: 14))
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: width, height: height, alignment: .top)
        }
        .sheet(isPresented: $showQRSheet) {
            QRTicketSheet(payload: qrPayload, backgroundAssetName: theme.assetName)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .fullScreenCover(isPresented: $showSeatPlanner) {
            StadiumSeatGuideVectorView(
                estadio: estadio,
                duelo: duelo,
                fecha: fecha,
                hora: hora,
                ticket: SeatTicket(seccion: seccion, fila: fila, asiento: asiento, piso: piso, puerta: puerta),
                onClose: { showSeatPlanner = false }
            )
        }
    }
}

// MARK: - MODELO
struct SeatTicket: Identifiable {
    let id = UUID()
    var seccion: String
    var fila: String
    var asiento: String
    var piso: String
    var puerta: String
}

// MARK: - VENTANA CON MAPA + ZONAS + INDICADOR GLASS
private struct StadiumSeatGuideVectorView: View {
    var estadio: String
    var duelo: String
    var fecha: String
    var hora: String
    var ticket: SeatTicket
    var onClose: () -> Void

    private var sector: Int {
        let num = Int(ticket.seccion.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        return (num % 24 + 24) % 24
    }

    private func rowFraction(from fila: String) -> CGFloat {
        let c = fila.uppercased().first ?? "C"
        let table: [Character: CGFloat] = [
            "A": 0.20, "B": 0.32, "C": 0.44, "D": 0.58, "E": 0.72, "F": 0.84, "G": 0.92
        ]
        return table[c] ?? 0.50
    }

    private func zoneForFloor(_ piso: String) -> StadiumZone {
        let p = piso.lowercased()
        if p.contains("1") || p.contains("bajo") { return .baja }
        if p.contains("3") || p.contains("alto") { return .alta }
        return .media
    }

    var body: some View {
        let zone = zoneForFloor(ticket.piso)

        ZStack {
            RacetrackStadiumBackdrop(
                highlightSector: sector,
                seatText: ticket.asiento,
                seatRowFraction: rowFraction(from: ticket.fila),
                zone: zone
            )
            .ignoresSafeArea()

            LinearGradient(colors: [Color.black.opacity(0.03), Color.black.opacity(0.20)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // TÍTULOS EN NEGRO
                VStack(spacing: 6) {
                    Text(estadio.uppercased())
                        .font(.custom("FWC2026-NormalBlack", size: 28))
                        .foregroundStyle(.black)
                    Text("\(duelo)  •  \(fecha)  •  \(hora)")
                        .font(.custom("FWC2026-NormalRegular", size: 13))
                        .foregroundStyle(.black.opacity(0.75))
                }
                .padding(.top, 8)

                Spacer(minLength: 56)

                SingleTicketSummary(ticket: ticket)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                ZonesStrip(active: zone)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        dataChip("PISO", ticket.piso)
                        dataChip("PUERTA", ticket.puerta)
                        dataChip("SECCIÓN", ticket.seccion)
                        dataChip("FILA", ticket.fila)
                        dataChip("ASIENTO", ticket.asiento)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                }
                .padding(.bottom, 16)
            }
        }
    }

    private func dataChip(_ title: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.custom("FWC2026-NormalRegular", size: 11))
                .foregroundStyle(.black.opacity(0.65))
            Text(value)
                .font(.custom("FWC2026-NormalBlack", size: 12))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(.regularMaterial, in: Capsule())
        .overlay(Capsule().stroke(.black.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
}

// MARK: - Zonas
private enum StadiumZone: String {
    case baja  = "Zona Baja"
    case media = "Zona Media"
    case alta  = "Zona Alta"
}

private struct ZonesStrip: View {
    var active: StadiumZone
    var body: some View {
        HStack(spacing: 10) {
            zoneChip(.baja, active: active == .baja)
            zoneChip(.media, active: active == .media)
            zoneChip(.alta, active: active == .alta)
        }
    }
    private func zoneChip(_ z: StadiumZone, active: Bool) -> some View {
        Text(z.rawValue)
            .font(.custom("FWC2026-NormalBlack", size: 12))
            .foregroundStyle(active ? .black : .black.opacity(0.6))
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(active ? .regularMaterial : .ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.black.opacity(active ? 0.15 : 0.08), lineWidth: 1))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }
}

// MARK: - Resumen
private struct SingleTicketSummary: View {
    var ticket: SeatTicket
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Row \(ticket.fila)")
                    .font(.custom("FWC2026-NormalBlack", size: 16))
                    .foregroundStyle(.black)
                Text("Sección \(ticket.seccion)")
                    .font(.custom("FWC2026-NormalRegular", size: 12))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    pill("Asiento", ticket.asiento)
                }
            }
            Spacer(minLength: 10)
            BarcodeStub()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }

    private func pill(_ title: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.custom("FWC2026-NormalRegular", size: 11))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.custom("FWC2026-NormalBlack", size: 12))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(.ultraThinMaterial))
    }
}

// MARK: - Código de barras
private struct BarcodeStub: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<16, id: \.self) { i in
                Rectangle()
                    .fill(i.isMultiple(of: 3) ? .black.opacity(0.7) : .black.opacity(0.35))
                    .frame(width: i.isMultiple(of: 5) ? 3 : 2, height: 54)
            }
        }
        .padding(.leading, 8)
    }
}

// MARK: - Estadio racetrack con texturas + callout glass
private struct RacetrackStadiumBackdrop: View {
    var highlightSector: Int? = nil        // 0..23
    var seatText: String? = nil            // número de asiento
    var seatRowFraction: CGFloat = 0.45    // 0 interior, 1 exterior
    var zone: StadiumZone = .media

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.12)],
                               startPoint: .top, endPoint: .bottom)

                // Dimensiones base
                let baseWidth = min(w, h) * 0.90
                let baseHeight = baseWidth * 0.60
                let ringThickness: CGFloat = 18
                let gap: CGFloat = 10

                // Campo (105x68)
                let fieldRatio: CGFloat = 105/68
                let rawFieldW = baseWidth * 0.42
                let rawFieldH = rawFieldW / fieldRatio
                let maxFieldH = baseHeight * 0.60
                let fieldH = min(rawFieldH, maxFieldH)
                let fieldW = fieldH * fieldRatio

                // Gradas (tres zonas)
                let ring1 = CGSize(width: fieldW + gap*2 + ringThickness*2,
                                   height: fieldH + gap*2 + ringThickness*2)      // Baja
                let ring2 = CGSize(width: ring1.width + gap*2 + ringThickness*2,
                                   height: ring1.height + gap*2 + ringThickness*2) // Media
                let ring3 = CGSize(width: ring2.width + gap*2 + ringThickness*2,
                                   height: ring2.height + gap*2 + ringThickness*2) // Alta

                // --- TEXTURAS: tus assets como ImagePaint (se repiten en mosaico) ---
                let texBaja  = texturePaint(named: "FondoAzul",   for: ring1)
                let texMedia = texturePaint(named: "FondoMorado", for: ring2)
                let texAlta  = texturePaint(named: "FondoVerde",  for: ring3)
                //let texVIP   = texturePaint(named: "FondoRojo",   for: CGSize(width: fieldW + 26, height: fieldH + 26))

                // Anillos con textura + línea blanca suave
                RacetrackRing(size: ring3, thickness: ringThickness)
                    .fill(texAlta, style: FillStyle(eoFill: true))
                    .overlay(RacetrackRing(size: ring3, thickness: ringThickness).stroke(.white.opacity(0.15), lineWidth: 1))

                RacetrackRing(size: ring2, thickness: ringThickness)
                    .fill(texMedia, style: FillStyle(eoFill: true))
                    .overlay(RacetrackRing(size: ring2, thickness: ringThickness).stroke(.white.opacity(0.16), lineWidth: 1))

                RacetrackRing(size: ring1, thickness: ringThickness)
                    .fill(texBaja, style: FillStyle(eoFill: true))
                    .overlay(RacetrackRing(size: ring1, thickness: ringThickness).stroke(.white.opacity(0.18), lineWidth: 1))

                /* (Opcional) Anillo VIP muy fino en rojo cerca del campo
                RoundedRectangle(cornerRadius: min(fieldW, fieldH)*0.20, style: .continuous)
                    //.strokeBorder(texVIP, lineWidth: 8)
                    .frame(width: fieldW + 20, height: fieldH + 20)
                    .opacity(0.9)
                 
                 */

                // Sólo la etiqueta de la zona seleccionada
                switch zone {
                case .alta:
                    ZoneRingLabel(size: ring3, thickness: ringThickness, color: .clear, text: "Zona Alta", showLabel: true)
                case .media:
                    ZoneRingLabel(size: ring2, thickness: ringThickness, color: .clear, text: "Zona Media", showLabel: true)
                case .baja:
                    ZoneRingLabel(size: ring1, thickness: ringThickness, color: .clear, text: "Zona Baja", showLabel: true)
                }

                // Campo centrado
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.green.opacity(0.78))
                    .frame(width: fieldW, height: fieldH)
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.white.opacity(0.95), lineWidth: 2))
                    .overlay(FieldLines().stroke(.white.opacity(0.95), lineWidth: 2))

                // Callout asiento
                if let seatText, let sector = highlightSector {
                    let angle = Double(sector) * (2 * .pi / 24.0) + (2 * .pi / 24.0)/2
                    let p = pointOnRacetrack(size: ring2, angle: angle, fraction: seatRowFraction, thickness: ringThickness)

                    GlassLocator(text: seatText)
                        .offset(x: p.x, y: p.y - 24)
                    PulseDot()
                        .offset(x: p.x, y: p.y + 2)
                }

                // Halo de zona activa
                let activeSize: CGSize = {
                    switch zone {
                    case .baja:  return ring1
                    case .media: return ring2
                    case .alta:  return ring3
                    }
                }()
                RoundedRectangle(cornerRadius: min(activeSize.width, activeSize.height)*0.22, style: .continuous)
                    .strokeBorder(.white.opacity(0.55), lineWidth: 2.0)
                    .frame(width: activeSize.width, height: activeSize.height)
                    .blur(radius: 0.4)
                    .opacity(0.9)
            }
            .padding(.top, h * 0.02)
        }
    }

    // Crea un ImagePaint escalado para que el patrón no se deforme
    private func texturePaint(named name: String, for size: CGSize) -> ImagePaint {
        // escala heurística: mayor anillo → mayor escala (patrón más grande)
        // ajusta si quieres el patrón más chico/grande
        let longest = max(size.width, size.height)
        let scale = max(1.0, longest / 260.0)
        return ImagePaint(image: Image(name), scale: scale)
    }

    private func pointOnRacetrack(size: CGSize, angle: Double, fraction: CGFloat, thickness: CGFloat) -> CGPoint {
        let outerRx = size.width / 2
        let outerRy = size.height / 2
        let innerRx = outerRx - thickness
        let innerRy = outerRy - thickness
        let rx = innerRx + (outerRx - innerRx) * min(max(fraction, 0), 1)
        let ry = innerRy + (outerRy - innerRy) * min(max(fraction, 0), 1)
        return CGPoint(x: rx * CGFloat(cos(angle)), y: ry * CGFloat(sin(angle)))
    }
}

// Etiqueta glass de zona (solo texto)
private struct ZoneRingLabel: View {
    var size: CGSize
    var thickness: CGFloat
    var color: Color
    var text: String
    var showLabel: Bool = true

    var body: some View {
        if showLabel {
            Text(text)
                .font(.custom("FWC2026-NormalBlack", size: 12))
                .foregroundStyle(.black)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(.black.opacity(0.08), lineWidth: 0.5))
                .offset(x: -size.width*0.32, y: -size.height*0.36)
        }
    }
}

// Pin glass con “colita”
private struct GlassLocator: View {
    var text: String
    var body: some View {
        ZstackWithTail(text: text)
    }
}
private struct ZstackWithTail: View {
    var text: String
    var body: some View {
        ZStack(alignment: .bottom) {
            Triangle()
                .fill(.ultraThinMaterial)
                .frame(width: 12, height: 8)
                .overlay(Triangle().stroke(.black.opacity(0.1), lineWidth: 0.5))
                .offset(y: 6)

            Text(text)
                .font(.custom("FWC2026-NormalBlack", size: 14))
                .foregroundStyle(.black)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.black.opacity(0.1), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// Punto con pulso
private struct PulseDot: View {
    @State private var anim = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.7), lineWidth: 2)
                .frame(width: 16, height: 16)
                .scaleEffect(anim ? 1.8 : 0.8)
                .opacity(anim ? 0.0 : 0.8)
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                anim = true
            }
        }
    }
}

// Ring racetrack (even-odd fill)
private struct RacetrackRing: Shape {
    var size: CGSize
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let outer = CGRect(x: rect.midX - size.width/2,
                           y: rect.midY - size.height/2,
                           width: size.width, height: size.height)
        let corner = min(size.width, size.height) * 0.22

        let inner = outer.insetBy(dx: thickness, dy: thickness)
        let innerCorner = max(corner - thickness, 1)

        var p = Path()
        p.addPath(Path(roundedRect: outer, cornerRadius: corner))
        p.addPath(Path(roundedRect: inner, cornerRadius: innerCorner))
        return p
    }
}

// Líneas de campo
private struct FieldLines: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let inset: CGFloat = 10
        let areaW: CGFloat = rect.width * 0.32
        let areaH: CGFloat = rect.height * 0.36

        p.move(to: CGPoint(x: rect.midX, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - inset))
        p.addEllipse(in: CGRect(x: rect.midX - 16, y: rect.midY - 16, width: 32, height: 32))

        p.addRect(CGRect(x: rect.minX + inset, y: rect.midY - areaH/2, width: areaW, height: areaH))
        p.addRect(CGRect(x: rect.maxX - inset - areaW, y: rect.midY - areaH/2, width: areaW, height: areaH))
        return p
    }
}

// MARK: - Sheet del QR
private struct QRTicketSheet: View {
    let payload: String
    let backgroundAssetName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image(backgroundAssetName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 0)
                Text("Código QR del boleto")
                    .font(.custom("FWC2026-NormalBlack", size: 22))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                QRCodeView(payload: payload, size: 260)
                Text("Muestra este código al personal para validar tu acceso.")
                    .font(.custom("FWC2026-NormalBlack", size: 13))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer(minLength: 12)
                Button { dismiss() } label: {
                    Text("Cerrar")
                        .font(.custom("FWC2026-NormalBlack", size: 16))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.glass)
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        Ticket()
            .padding()
            .background(Color(.systemGroupedBackground))
    }
}
