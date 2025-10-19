//
//  CardFinalizado.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import SwiftUI

struct CardFinalizado: View {
    let partido: Partido
    let grupo: String
    let marcadorLocal: Int
    let marcadorVisitante: Int

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Lado izquierdo: Equipo local
            equipoView(equipo: partido.local, alignment: .leading)

            // Centro: Grupo y marcador (sin minuto)
            VStack(spacing: 6) {
                Image("FifaPlus")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                Text(grupo.uppercased())
                    .font(.custom("FWC2026-NormalRegular", size: 12))
                    .foregroundColor(.gray)

                HStack(alignment: .center, spacing: 8) {
                    Text("\(marcadorLocal)")
                        .font(.custom("FWC2026-NormalBlack", size: 28))
                    Text(":")
                        .font(.custom("FWC2026-NormalBlack", size: 24))
                        .foregroundColor(.gray)
                    Text("\(marcadorVisitante)")
                        .font(.custom("FWC2026-NormalBlack", size: 28))
                }
                .foregroundColor(.primary)
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
        .frame(width: 350)
        .ignoresSafeArea()
        .glassEffect()
        .foregroundStyle(.thinMaterial)
    }

    private func equipoView(equipo: Equipos, alignment: HorizontalAlignment) -> some View {
        HStack(spacing: 8) {
            if alignment == .leading {
                // Texto afuera (a la izquierda), luego bandera
                Text(equipo.name)
                    .font(.custom("FWC2026-NormalBlack", size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: 90, alignment: .trailing)

                Image(equipo.flag)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                // Bandera primero, luego texto afuera (a la derecha)
                Image(equipo.flag)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(equipo.name)
                    .font(.custom("FWC2026-NormalBlack", size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: 90, alignment: .leading)
            }
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
        CardFinalizado(
            partido: partido,
            grupo: "Grupo A",
            marcadorLocal: 2,
            marcadorVisitante: 1
        )
        .frame(width: 300)
    }
    .padding()
}
