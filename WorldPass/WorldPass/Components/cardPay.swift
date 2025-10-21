//
//  cardPay.swift
//  WorldPass
//
//  Created by Kxze on 20/10/25.
//

import SwiftUI

struct CardPay: View {
    // Imagen de fondo de la tarjeta (asset en el proyecto) elegido por el usuario
    let backgroundImageName: String

    // Placeholders que luego podrás reemplazar por datos reales del usuario
    let holderName: String      // Ej: "NOMBRE APELLIDO"
    let cardNumber: String      // Debe contener los 16 dígitos
    let expiry: String          // Ej: "MM/AA"
    let brand: String           // Ej: "VISA / MasterCard"

    // Color del texto (ajústalo si quieres volver a dorado)
    private let gold = Color.white

    // Normaliza a solo dígitos
    private var sanitizedDigits: String {
        cardNumber.filter(\.isNumber)
    }

    // ¿El usuario ingresó los 16 dígitos?
    private var isComplete: Bool {
        sanitizedDigits.count == 16
    }

    // Últimos 4 dígitos cuando hay 16
    private var last4: String {
        guard sanitizedDigits.count >= 4 else { return "1234" }
        return String(sanitizedDigits.suffix(4))
    }

    // Representación a mostrar en la tarjeta
    private var maskedNumber: String {
        if isComplete {
            return "**** **** **** \(last4)"
        } else {
            // Placeholder hasta que se completen los 16 dígitos
            return "**** **** **** 1234"
        }
    }

    init(
        backgroundImageName: String,
        holderName: String,
        cardNumber: String,
        expiry: String,
        brand: String
    ) {
        self.backgroundImageName = backgroundImageName
        self.holderName = holderName
        self.cardNumber = cardNumber
        self.expiry = expiry
        self.brand = brand
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fondo con imagen (elegido por el usuario, no cambia aleatoriamente)
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .frame(width:350,height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            // Textos de la tarjeta en la tipografía indicada
            HStack {
                VStack(alignment: .leading, spacing: 120) {
                    // Nombre del titular
                    Text(holderName.isEmpty ? "NOMBRE APELLIDO" : holderName)
                        .font(.custom("FWC2026-NormalBlack", size: 16))
                        .foregroundStyle(gold)
                        .innerShadow(color: .black.opacity(0.35), radius: 1.2, x: 0, y: 1)

                    // Número enmascarado (cuando hay 16 dígitos)
                    Text(maskedNumber)
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                        .monospacedDigit()
                        .foregroundStyle(gold)
                        .innerShadow(color: .black.opacity(0.35), radius: 1.2, x: 0, y: 1)
                }
                

                VStack(alignment:.trailing) {
                    Spacer()
                    Text("\(expiry.isEmpty ? "MM/AA" : expiry)")
                        .innerShadow(color: .black.opacity(0.15), radius: 1.0, x: 0, y: 1)

                    Text(brand.isEmpty ? "MARCA" : brand)
                        .innerShadow(color: .black.opacity(0.15), radius: 1.0, x: 0, y: 1)
                }
                .offset(x:70)
               
            }
            .font(.custom("FWC2026-NormalBlack", size: 12))
            .foregroundStyle(gold)
            .shadow(radius: 50)
            .padding(16)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(holderName.isEmpty ? "Nombre no establecido" : holderName), terminación \(isComplete ? last4 : "1234"), vence \(expiry.isEmpty ? "MM/AA" : expiry), \(brand.isEmpty ? "Marca" : brand)")
    }
}

// Modificador para simular sombra interna en cualquier View (incluido Text)
private extension View {
    func innerShadow(color: Color = .black.opacity(0.3), radius: CGFloat = 1, x: CGFloat = 0, y: CGFloat = 1) -> some View {
        self.overlay(
            self
                .foregroundColor(color)
                .blur(radius: radius)
                .offset(x: x, y: y)
                .mask(self)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        // Ejemplo con selección de fondo por el usuario
        CardPay(
            backgroundImageName: "CardM",
            holderName: "NOMBRE APELLIDO",
            cardNumber: "4111111111111234", // 16 dígitos -> se enmascaran los primeros 12
            expiry: "12/27",
            brand: "VISA"
        )
        .frame(height: 180)

        CardPay(
            backgroundImageName: "CardC",
            holderName: "Alex Smith",
            cardNumber: "1234", // incompleto -> muestra placeholder
            expiry: "08/26",
            brand: "Mastercard"
        )
        .frame(height: 180)

        CardPay(
            backgroundImageName: "CardUS",
            holderName: "Alex Smith",
            cardNumber: "5555555555555678", // 16 dígitos
            expiry: "08/26",
            brand: "Mastercard"
        )
        .frame(height: 180)
    }
    .padding()
}
