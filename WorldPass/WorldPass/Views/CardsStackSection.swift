import SwiftUI

struct CardsStackSection: View {
    let cards: [(holderName: String, cardNumber: String, expiry: String, brand: String, backgroundImageName: String)]
    let selectedIndex: Int?
    let onOpenReader: (Int) -> Void
    let onRequestDelete: (Int) -> Void

    private let cardHeight: CGFloat = 170
    private let gap: CGFloat = 78

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if cards.isEmpty {
                Text("Sin tarjetas aún")
                    .font(.custom("FWC2026-NormalRegular", size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            } else {
                ZStack(alignment: .top) {
                    ForEach(cards.indices, id: \.self) { index in
                        let card = cards[index]
                        let isSelected = selectedIndex == index
                        let baseOffsetY = CGFloat(index) * gap

                        CardRowView(
                            holderName: card.holderName,
                            cardNumber: card.cardNumber,
                            expiry: card.expiry,
                            brand: card.brand,
                            backgroundImageName: card.backgroundImageName,
                            onTap: { onOpenReader(index) },
                            onRequestDelete: { onRequestDelete(index) }
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
                // Altura coherente y flexible según cantidad de tarjetas (mínimo una altura de tarjeta)
                .frame(height: max(cardHeight, cardHeight + CGFloat(max(0, cards.count - 1)) * gap))
                .padding(.top, 4) // pequeño respiro respecto al toolbar
            }
        }
    }
}

private struct CardRowView: View {
    let holderName: String
    let cardNumber: String
    let expiry: String
    let brand: String
    let backgroundImageName: String

    var onTap: () -> Void
    var onRequestDelete: () -> Void

    @State private var dragOffsetX: CGFloat = 0
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
            .simultaneousGesture(TapGesture().onEnded { onTap() })
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
