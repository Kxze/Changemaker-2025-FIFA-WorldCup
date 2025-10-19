//
//  CardProximo.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import SwiftUI

struct CardProximo: View {
    let partido: Partido
    let grupo: String
    let fecha: String   // Ej: "16 JUL 2026"
    let hora: String    // Ej: "19:00"

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Lado izquierdo: Equipo local
            equipoView(equipo: partido.local, alignment: .leading)

            // Centro: Grupo, fecha y hora
            VStack(spacing: 6) {
                Text(grupo.uppercased())
                    .font(.custom("FWC2026-NormalRegular", size: 12))
                    .foregroundColor(.gray)

                VStack(spacing: 2) {
                    Text(fecha)
                        .font(.custom("FWC2026-NormalBlack", size: 18))
                        .foregroundColor(.primary)
                    Text(hora)
                        .font(.custom("FWC2026-NormalBlack", size: 12))
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity)

            // Lado derecho: Equipo visitante
            equipoView(equipo: partido.visitante, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 40)
        )
        .ignoresSafeArea()
        .glassEffect()
        .foregroundStyle(.thinMaterial)
        .frame(width: 400)
    }

    private func equipoView(equipo: Equipos, alignment: HorizontalAlignment) -> some View {
        VStack(spacing: 8) {
            Image(equipo.flag)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(equipo.name)
                .font(.custom("FWC2026-NormalBlack", size: 12))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: 90, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
}

#Preview {
    // Datos de ejemplo
    let local = equiposDetails[0]
    let visitante = equiposDetails[1]
    let partido = Partido(local: local, visitante: visitante)

    return VStack(spacing: 16) {
        CardProximo(
            partido: partido,
            grupo: "Grupo A",
            fecha: "17/JUL",
            hora: "19:00"
        )
        .frame(width: 300)
    }
    .padding()
}
