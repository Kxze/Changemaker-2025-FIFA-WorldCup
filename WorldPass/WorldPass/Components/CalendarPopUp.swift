//
//  CalendarPopUp.swift
//  WorldPass
//
//  Created by Kxze on 22/10/25.
//

import SwiftUI

struct CalendarPopUp: View {
    // Controla la presentación del pop-up
    @State private var showCalendar = false
    @State private var selectedDate: Date = Date()

    // Personalización opcional del botón
    var systemImage: String = "calendar"

    // Mismo rango de fechas que CalendarView (11 Jun 2026 – 19 Jul 2026)
    private static let worldCupStart: Date = {
        let cal = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 6
        comps.day = 11
        return cal.date(from: comps) ?? Date()
    }()

    private static let worldCupEnd: Date = {
        let cal = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 7
        comps.day = 19
        return cal.date(from: comps) ?? Date()
    }()

    private var worldCupRange: ClosedRange<Date> {
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: Self.worldCupStart)
        let end = cal.date(bySettingHour: 23, minute: 59, second: 59, of: Self.worldCupEnd) ?? Self.worldCupEnd
        return start...end
    }

    var body: some View {
        Button {
            showCalendar = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .resizable()
                    .frame(width: 30,height: 30)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
        }
        .buttonStyle(.glass)
        // Popover con calendario nativo (no CalendarView)
        .popover(
            isPresented: $showCalendar,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Calendario gráfico nativo, limitado al rango del Mundial
                DatePicker(
                    "Selecciona una fecha",
                    selection: $selectedDate,
                    in: worldCupRange,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "es_ES"))

                // Opcional: mostrar la fecha seleccionada
                HStack {
                    Text("Fecha seleccionada:")
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundStyle(.secondary)
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted).uppercased())
                        .font(.custom("FWC2026-NormalBlack", size: 13))
                }

                HStack {
                    Spacer()
                    Button("Cerrar") {
                        showCalendar = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(minWidth: 360, idealWidth: 420, maxWidth: 480,
                   minHeight: 280, idealHeight: 320, maxHeight: 380)
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    CalendarPopUp()
        .padding()
}
