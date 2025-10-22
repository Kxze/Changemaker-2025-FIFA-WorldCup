//
//  Calendar.swift
//  WorldPass
//
//  Created by Kxze on 21/10/25.
//

import SwiftUI

struct CalendarView: View {
    // Fechas oficiales del Mundial 2026: 11 Jun 2026 – 19 Jul 2026
    private static let worldCupStart: Date = {
        let cal = Foundation.Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 6
        comps.day = 11
        // Si falla por alguna razón, usamos la fecha actual como fallback
        return cal.date(from: comps) ?? Date()
    }()

    private static let worldCupEnd: Date = {
        let cal = Foundation.Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 7
        comps.day = 19
        return cal.date(from: comps) ?? Date()
    }()

    // Fechas dentro del rango del Mundial 2026
    private let dates: [Date] = {
        let cal = Foundation.Calendar(identifier: .gregorian)
        let start = CalendarView.worldCupStart
        let end = CalendarView.worldCupEnd

        guard start <= end else { return [] }

        var result: [Date] = []
        var current = cal.startOfDay(for: start)

        let endOfDay = cal.startOfDay(for: end)
        while current <= endOfDay {
            result.append(current)
            current = cal.date(byAdding: .day, value: 1, to: current) ?? current
            if result.count > 1000 { break } // safety guard
        }
        return result
    }()

    // Formatters abreviados y localizados
    private static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES") // nombres de día en español
        df.dateFormat = "E" // nombre de día abreviado
        return df
    }()

    private static let numberFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "d" // número de día
        return df
    }()

    private static let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "MMM" // mes abreviado
        return df
    }()

    // Configuración de presentación
    private let itemWidth: CGFloat = 36   // antes 44
    private let itemSpacing: CGFloat = 8  // antes 12
    private let visibleItems: Int = 7

    // Estado para el popup de calendario
    @State private var showCalendarOverlay = false
    @State private var selectedDate: Date = Date()

    var body: some View {
        ZStack {
            // Contenido principal
            HStack(alignment: .center, spacing: 12) {
                // Segmento desplazable de 7 días visibles
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(dates, id: \.self) { date in
                            VStack(spacing: 4) {
                                Text(CalendarView.dayFormatter.string(from: date).capitalized)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)

                                Text("\(CalendarView.numberFormatter.string(from: date)) \(CalendarView.monthFormatter.string(from: date).capitalized)")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: itemWidth)
                        }
                    }
                }
                // Ancho exacto para mostrar 7 ítems + 6 espacios entre ellos (más compacto)
                .frame(width: itemWidth * CGFloat(visibleItems) + itemSpacing * CGFloat(visibleItems - 1))
                .frame(height: 56) // opcional, para altura consistente

                // Botón al lado del carrusel
                Button {
                    withAnimation(.easeInOut) { showCalendarOverlay = true }
                } label: {
                    Image(systemName: "calendar")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            .font(.custom("FWC2026-NormalBlack", size: 9))
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Overlay de calendario
            if showCalendarOverlay {
                // Fondo semitransparente que cierra al tocar fuera
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) { showCalendarOverlay = false }
                    }
                    .transition(.opacity)
                    .zIndex(1)

                // Tarjeta centrada con el DatePicker
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Calendario")
                                .font(.headline)
                            Spacer()
                            Button {
                                withAnimation(.easeInOut) { showCalendarOverlay = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Cerrar")
                        }

                        DatePicker(
                            "Selecciona una fecha",
                            selection: $selectedDate,
                            in: CalendarView.worldCupStart...CalendarView.worldCupEnd,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)

                        Text("Fecha seleccionada: \(formattedSelectedDate(selectedDate))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)

                    Divider()

                    HStack {
                        Button("Cancelar") {
                            withAnimation(.easeInOut) { showCalendarOverlay = false }
                        }
                        .buttonStyle(.borderless)

                        Spacer()

                        Button("Listo") {
                            // Aquí podrías sincronizar la selección con el carrusel si lo deseas
                            withAnimation(.easeInOut) { showCalendarOverlay = false }
                        }
                        .buttonStyle(.glass)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial.opacity(0.6))
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 20)
                .glassEffect(in: .rect(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16) // antes 24, más compacto
                .frame(maxWidth: 320) // antes 480, más angosto
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
                
            }
        }
        .animation(.easeInOut, value: showCalendarOverlay)
    }

    private func formattedSelectedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "EEEE d 'de' MMMM 'de' yyyy"
        return df.string(from: date).capitalized
    }
}

#Preview {
    CalendarView()
}
