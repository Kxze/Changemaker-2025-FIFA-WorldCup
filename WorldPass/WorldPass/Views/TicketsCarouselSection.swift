import SwiftUI

struct TicketsCarouselSection: View {
    let tickets: [(qrPayload: String, theme: Ticket.Theme)]

    // Estados internos (se quedan aquí para no invalidar toda la WalletView)
    @Namespace private var ticketNamespace
    @State private var isCarouselOpen: Bool = false
    @State private var currentTicketIndex: Int = 0
    @State private var dragOffsetX: CGFloat = 0

    // Parámetros visuales (ajusta si quieres)
    private let ticketBaseWidth: CGFloat = 340
    private let ticketBaseHeight: CGFloat = 400
    private let baseScale: CGFloat = 0.85
    private let sideScale: CGFloat = 0.86
    private let sideRotation: Double = 18

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("BOLETOS")
                .font(.custom("FWC2026-NormalBlack", size: 20))
                .padding(.horizontal, 10)

            if tickets.isEmpty {
                Text("Sin boletos aún")
                    .font(.custom("FWC2026-NormalRegular", size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            } else {
                let itemWidth = ticketBaseWidth * baseScale
                let itemHeight = ticketBaseHeight * baseScale
                let itemSpacing = itemWidth * 0.82

                if !isCarouselOpen {
                    // Stack apilado (source del matched geometry)
                    ZStack(alignment: .top) {
                        let gapY: CGFloat = 20
                        ForEach(tickets.indices, id: \.self) { idx in
                            let baseOffsetY = CGFloat(idx) * gapY
                            Ticket(qrPayload: tickets[idx].qrPayload, theme: tickets[idx].theme)
                                .compositingGroup()
                                .matchedGeometryEffect(id: "ticket-\(idx)", in: ticketNamespace, isSource: !isCarouselOpen)
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
                    .transition(.opacity)
                } else {
                    // Carrusel (destino del matched geometry)
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
                                    .matchedGeometryEffect(id: "ticket-\(idx)", in: ticketNamespace, isSource: isCarouselOpen)
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
                    .padding(.vertical, 20)
                    .transition(.opacity)
                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: currentTicketIndex)
                }
            }
        }
        // Anima el cambio de estado abierto/cerrado para que el fade ocurra
        .animation(.spring(response: 0.6, dampingFraction: 0.9), value: isCarouselOpen)
    }
}
