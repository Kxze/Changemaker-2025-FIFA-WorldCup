//
//  WalletView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct WalletView: View {
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

    // Tarjeta seleccionada para animarla “fuera” de la pila antes de abrir sheet
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 175) {
                // Sección tarjetas de pago
                CardsStackSection(
                    cards: cards,
                    selectedIndex: selectedIndex,
                    onOpenReader: { index in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selectedIndex = index
                        }
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 350_000_000)
                            showReaderSheet = true
                        }
                    },
                    onRequestDelete: { index in
                        indexPendingDeletion = index
                        showDeleteAlert = true
                    }
                )
                .padding(.horizontal)

                // Sección boletos (stack → carrusel)
                TicketsCarouselSection(tickets: tickets)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
        
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ExpensesRootView()
                    } label: {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            
            
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
