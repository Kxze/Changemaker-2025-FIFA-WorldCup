//
//  WalletView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct WalletView: View {
    // Namespace para transiciones suaves entre layouts
    @Namespace private var ticketNamespace

    // Modelo mínimo: guardamos número completo (16 dígitos) y datos básicos
    @State private var cards: [(holderName: String, cardNumber: String, expiry: String, brand: String, backgroundImageName: String)] = [
        (holderName: "Alex Smith",
         cardNumber: "4111111111111234",
         expiry: "12/27",
         brand: "VISA",
         backgroundImageName: "CardC"),
        (holderName: "Alex Smith",
         cardNumber: "4111111111111234",
         expiry: "12/27",
         brand: "VISA",
         backgroundImageName: "CardUS"),
        (holderName: "Alex Smith",
         cardNumber: "4111111111111234",
         expiry: "12/27",
         brand: "VISA",
         backgroundImageName: "CardM")
    ]

    // Boletos
    @State private var tickets: [(qrPayload: String, theme: Ticket.Theme)] = [
        (qrPayload: "{\"uuid\":\"WALLET-TICKET-001\",\"match\":\"MEX-NED\",\"seat\":\"14-F\"}", theme: .rojo),
        (qrPayload: "{\"uuid\":\"WALLET-TICKET-002\",\"match\":\"USA-CAN\",\"seat\":\"22-B\"}", theme: .azul),
        (qrPayload: "{\"uuid\":\"WALLET-TICKET-003\",\"match\":\"ARG-BRA\",\"seat\":\"07-A\"}", theme: .verde)
    ]

    // Sheets
    @State private var showAddCardSheet: Bool = false
    @State private var showReaderSheet: Bool = false

    // Alert de eliminación
    @State private var showDeleteAlert: Bool = false
    @State private var indexPendingDeletion: Int? = nil

    // Tarjeta seleccionada para animarla “fuera” de la pila
    @State private var selectedIndex: Int? = nil

    // Estados de interacción con boletos (carrusel)
    @State private var isCarouselOpen: Bool = false
    @State private var currentTicketIndex: Int = 0
    @State private var dragOffsetX: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 175) {
                // Sección tarjetas de pago (pila existente)
                if cards.isEmpty {
                    Text("Sin tarjetas aún")
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    // Parámetros de la pila
                    let cardHeight: CGFloat = 170
                    let gap: CGFloat = 78 // separación visible entre tarjetas apiladas

                    ZStack(alignment: .top) {
                        ForEach(cards.indices, id: \.self) { index in
                            let card = cards[index]
                            let isSelected = selectedIndex == index
                            let baseOffsetY = CGFloat(index) * gap

                            CardItemView(
                                holderName: card.holderName,
                                cardNumber: card.cardNumber,
                                expiry: card.expiry,
                                brand: card.brand,
                                backgroundImageName: card.backgroundImageName,
                                onOpenReader: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        selectedIndex = index
                                    }
                                    Task {
                                        try? await Task.sleep(nanoseconds: 350_000_000)
                                        showReaderSheet = true
                                    }
                                },
                                onRequestDelete: {
                                    indexPendingDeletion = index
                                    showDeleteAlert = true
                                }
                            )
                            .frame(height: cardHeight)
                            .offset(y: baseOffsetY + (isSelected ? -40 : 0))
                            .scaleEffect(isSelected ? 1.03 : 1.0)
                            .shadow(color: .black.opacity(isSelected ? 0.25 : 0.15),
                                    radius: isSelected ? 12 : 6,
                                    x: 0,
                                    y: isSelected ? 10 : 4)
                            .opacity(isSelected ? 1.0 : 0.98)
                            .zIndex(isSelected ? 100 : Double(index))
                            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedIndex)
                        }
                    }
                    .frame(height: cardHeight + CGFloat(max(0, cards.count - 1)) * gap + -100)
                    .padding(.horizontal)
                }

                // Sección BOLETOS: apilados → carrusel con drag (con matchedGeometryEffect)
                VStack(alignment: .leading) {
                    Text("BOLETOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                        .padding(.horizontal,10)

                    let ticketBaseWidth: CGFloat = 340
                    let ticketBaseHeight: CGFloat = 400
                    let baseScale: CGFloat = 0.85
                    let itemWidth: CGFloat = ticketBaseWidth * baseScale
                    let itemHeight: CGFloat = ticketBaseHeight * baseScale
                    let itemSpacing: CGFloat = itemWidth * 0.82 // solapamiento agradable
                    let sideRotation: Double = 18               // rotación Y para efecto carrusel
                    let sideScale: CGFloat = 0.86               // escala para los laterales

                    if tickets.isEmpty {
                        Text("Sin boletos aún")
                            .font(.custom("FWC2026-NormalRegular", size: 14))
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                    } else {
                        if !isCarouselOpen {
                            // Vista apilada (stack) con matchedGeometryEffect
                            ZStack(alignment: .top) {
                                let gapY: CGFloat = 20
                                ForEach(tickets.indices, id: \.self) { idx in
                                    let baseOffsetY = CGFloat(idx) * gapY
                                    Ticket(qrPayload: tickets[idx].qrPayload, theme: tickets[idx].theme)
                                        .compositingGroup()
                                        .matchedGeometryEffect(id: "ticket-\(idx)", in: ticketNamespace)
                                        .scaleEffect(baseScale)
                                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                                        .offset(y: baseOffsetY)
                                        .zIndex(Double(idx))
                                }
                            }
                            .frame(height: itemHeight + CGFloat(max(0, tickets.count - 1)) * 50)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                                    isCarouselOpen = true
                                }
                            }
                        } else {
                            // Carrusel con drag y snapping + matchedGeometryEffect
                            GeometryReader { geo in
                                let containerWidth = geo.size.width
                                let centerX = containerWidth / 2

                                ZStack {
                                    ForEach(tickets.indices, id: \.self) { idx in
                                        let distance = CGFloat(idx - currentTicketIndex)
                                        let x = centerX + distance * itemSpacing + dragOffsetX
                                        let absDist = abs(distance + dragOffsetX / itemSpacing)
                                        let clamped = min(1, max(0, absDist))

                                        let rotationY = Double((distance + dragOffsetX / itemSpacing)) * -sideRotation
                                        let scale = baseScale * (1 - (1 - sideScale) * min(1, clamped))

                                        Ticket(qrPayload: tickets[idx].qrPayload, theme: tickets[idx].theme)
                                            .compositingGroup()
                                            .matchedGeometryEffect(id: "ticket-\(idx)", in: ticketNamespace)
                                            .scaleEffect(scale)
                                            .rotation3DEffect(.degrees(rotationY),
                                                              axis: (x: 0, y: 1, z: 0),
                                                              perspective: 0.9)
                                            .shadow(color: .black.opacity(absDist < 0.01 ? 0.22 : 0.12),
                                                    radius: absDist < 0.01 ? 14 : 10,
                                                    x: 0,
                                                    y: absDist < 0.01 ? 12 : 6)
                                            .position(x: x, y: itemHeight / 2 + 8)
                                            .zIndex(Double(tickets.count) - Double(absDist))
                                            .onTapGesture {
                                                if idx != currentTicketIndex {
                                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                                        currentTicketIndex = idx
                                                        dragOffsetX = 0
                                                    }
                                                } else {
                                                    withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                                                        isCarouselOpen = false
                                                        dragOffsetX = 0
                                                    }
                                                }
                                            }
                                    }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 5)
                                        .onChanged { value in
                                            dragOffsetX = value.translation.width
                                        }
                                        .onEnded { value in
                                            let proposedShift = value.translation.width / itemSpacing
                                            let newIndex = currentTicketIndex - Int(round(proposedShift))
                                            let clampedIndex = max(0, min(tickets.count - 1, newIndex))
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                                currentTicketIndex = clampedIndex
                                                dragOffsetX = 0
                                            }
                                        }
                                )
                            }
                            .frame(height: itemHeight + 40)
                            .padding(.horizontal, 8)
                            .padding(.vertical,20)
                            // Animación cuando cambia el índice actual (snap)
                            .animation(.spring(response: 0.45, dampingFraction: 0.9), value: currentTicketIndex)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("WALLET")
                    .font(.custom("FWC2026-NormalBlack", size: 20))
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showAddCardSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Agregar tarjeta")
            }
        }
        // Sheet: “Acerca el iPhone al lector”
        .sheet(isPresented: $showReaderSheet, onDismiss: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                selectedIndex = nil
            }
        }) {
            HoldNearReaderSheet {
                showReaderSheet = false
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Sheet: Agregar tarjeta
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet { newCard in
                withAnimation(.spring) {
                    cards.append(newCard)
                }
                showAddCardSheet = false
            } onCancel: {
                showAddCardSheet = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // Alert de confirmación de eliminación
        .alert("Eliminar tarjeta", isPresented: $showDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                if let i = indexPendingDeletion, cards.indices.contains(i) {
                    withAnimation(.spring) {
                        _ = cards.remove(at: i)
                    }
                }
                indexPendingDeletion = nil
            }
            Button("Cancelar", role: .cancel) {
                indexPendingDeletion = nil
            }
        } message: {
            Text("¿Deseas eliminar esta tarjeta?")
        }
    }
}

// MARK: - Item de tarjeta con overlay y gesto
private struct CardItemView: View {
    let holderName: String
    let cardNumber: String
    let expiry: String
    let brand: String
    let backgroundImageName: String

    var onOpenReader: () -> Void
    var onRequestDelete: () -> Void

    @State private var dragOffsetX: CGFloat = 0

    // Umbral para disparar la eliminación
    private let triggerThreshold: CGFloat = -100

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red.opacity(max(0, min(0.25, Double(-dragOffsetX / 200)))))
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.trailing, 20)
                            .opacity(dragOffsetX < 0 ? min(1, Double(-dragOffsetX / 80)) : 0)
                    }
                )

            CardPay(
                backgroundImageName: backgroundImageName,
                holderName: holderName,
                cardNumber: cardNumber,
                expiry: expiry,
                brand: brand
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .offset(x: dragOffsetX)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onOpenReader()
                }
            )
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        dragOffsetX = min(0, value.translation.width)
                    }
                    .onEnded { value in
                        if value.translation.width <= triggerThreshold {
                            onRequestDelete()
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            dragOffsetX = 0
                        }
                    }
            )

            .buttonStyle(.plain)
            .padding(10)
            .offset(x: -4, y: 4)
            .accessibilityLabel("Abrir lector")
        }
        .frame(height: 180)
    }
}

// MARK: - Utilidad: Blur nativo para el overlay
private struct VisualEffectBlur: UIViewRepresentable {
    let material: UIBlurEffect.Style

    init(material: UIBlurEffect.Style) {
        self.material = material
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: material))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: material)
    }
}

// MARK: - Sheet para agregar tarjeta (16 dígitos)
private struct AddCardSheet: View {
    var onAdd: ((holderName: String, cardNumber: String, expiry: String, brand: String, backgroundImageName: String)) -> Void
    var onCancel: () -> Void

    @State private var holderName: String = ""
    @State private var cardNumber: String = "" // 16 dígitos
    @State private var expiry: String = ""
    @State private var brand: String = "VISA"
    @State private var backgroundImageName: String = ""

    private let brands = ["VISA", "Mastercard", "Amex"]
    private let sampleBackgrounds = ["CardC", "CardM", "CardUS"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Titular")) {
                    TextField("Nombre del titular", text: $holderName)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }

                Section(header: Text("Detalles de la tarjeta")) {
                    TextField("Número de tarjeta (16 dígitos)", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: cardNumber) { _, newValue in
                            let digits = newValue.filter { $0.isNumber }
                            cardNumber = String(digits.prefix(16))
                        }

                    TextField("Vencimiento (MM/AA)", text: $expiry)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: expiry) { _, newValue in
                            let digits = newValue.filter { $0.isNumber }.prefix(4)
                            var formatted = ""
                            for (i, ch) in digits.enumerated() {
                                if i == 2 { formatted.append("/") }
                                formatted.append(ch)
                            }
                            expiry = formatted
                        }

                    Picker("Marca", selection: $brand) {
                        ForEach(brands, id: \.self) { b in
                            Text(b).tag(b)
                        }
                    }
                }

                Section(header: Text("Fondo")) {
                    Picker("Imagen de fondo", selection: $backgroundImageName) {
                        ForEach(sampleBackgrounds, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    TextField("o escribe el nombre del asset", text: $backgroundImageName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Agregar tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onAdd((holderName: holderName.trimmingCharacters(in: .whitespaces),
                               cardNumber: cardNumber,
                               expiry: expiry,
                               brand: brand,
                               backgroundImageName: backgroundImageName))
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            backgroundImageName = sampleBackgrounds.randomElement() ?? "CardC"
        }
    }

    private var isFormValid: Bool {
        !holderName.trimmingCharacters(in: .whitespaces).isEmpty &&
        cardNumber.count == 16 &&
        expiry.count == 5 // MM/AA
    }
}

// MARK: - Mock de “Hold Near Reader”
private struct HoldNearReaderSheet: View {
    var onCancel: () -> Void

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse ? 1.06 : 0.96)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 6) {
                Text("Acerca el iPhone al lector")
                    .font(.title3.weight(.semibold))
                Text("Mantén tu iPhone cerca del lector para completar el pago.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(role: .cancel) {
                onCancel()
            } label: {
                Text("Cancelar")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal)

            Spacer(minLength: 12)
        }
        .onAppear {
            pulse = true
        }
    }
}

#Preview {
    NavigationStack {
        WalletView()
    }
}
