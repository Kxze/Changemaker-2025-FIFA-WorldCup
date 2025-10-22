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
        df.locale = Locale(identifier: "es_ES") // unificar locale con el resto
        df.dateFormat = "dd" // número de día con dos dígitos para evitar saltos (01, 02, ..., 31)
        return df
    }()

    private static let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_ES") // asegurar consistencia en español
        df.dateFormat = "LLL" // mes abreviado (standalone), más consistente que "MMM" en algunos locales
        return df
    }()

    // Estado para el popup de calendario
    @State private var showCalendarOverlay = false
    @State private var selectedDate: Date = Date()

    var body: some View {
        ZStack {
            // Contenido principal
            HStack {
                // Segmento desplazable que solo ocupa el contenido
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing:25) {
                        ForEach(dates, id: \.self) { date in
                            VStack(spacing: 4) {
                                // Día abreviado (ej: Jue)
                                Text(CalendarView.dayFormatter.string(from: date).capitalized)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("FWC2026-NormalRegular", size: 13))

                                // Número de día (ej: 11)
                                Text(CalendarView.numberFormatter.string(from: date))
                                    .monospacedDigit()
                                    .multilineTextAlignment(.center)
                                    .font(.custom("FWC2026-NormalBlack", size: 13))

                                // Mes abreviado (ej: Jun)
                                Text(CalendarView.monthFormatter.string(from: date).capitalized)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("FWC2026-NormalRegular", size: 13))
                            }
                            // Sin ancho fijo: el ítem solo ocupa lo que miden los textos
                        }
                    }
                }
                .frame(width: 300, height: 80)
                // Sin ancho forzado del ScrollView
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    CalendarView()
}
