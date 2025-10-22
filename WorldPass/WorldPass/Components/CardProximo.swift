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
        ZStack{
            HStack(spacing:110){
                equipoView(equipo: partido.local, alignment: .leading)
                equipoView(equipo: partido.visitante, alignment: .trailing)
            }
            .offset(y:5)
            .opacity(0.6)
            HStack(alignment: .center, spacing: -5) {
                // Lado izquierdo: Equipo local
                equipoView(equipo: partido.local, alignment: .leading)
                
                // Centro: Grupo, fecha y hora
                VStack(spacing:5) {
                    Text(grupo.uppercased())
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundColor(.gray)
                        .offset(y:-5)
                    
                    VStack(alignment:.center,spacing: -5) {
                        Text(hora)
                            .font(.custom("FWC2026-NormalRegular", size: 14))
                            .foregroundColor(.primary)
                        Text(fecha)
                            .font(.custom("FWC2026-NormalBlack", size: 15))
                            .foregroundColor(.primary)
                        
                    }
                    .offset(y:-10)
                }
                .frame(maxWidth: .infinity)
                
                // Lado derecho: Equipo visitante
                equipoView(equipo: partido.visitante, alignment: .trailing)
                
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .ignoresSafeArea()
            .glassEffect(in: .rect(cornerRadius: 30, style: .continuous))
            .foregroundStyle(.thinMaterial)
            .frame(width: 380)
        }
    }

    private func equipoView(equipo: Equipos, alignment: HorizontalAlignment) -> some View {
        HStack(spacing: 8) {
            if alignment == .leading {
                // Nombre primero, luego bandera
                Text(equipo.name)
                    .font(.custom("FWC2026-NormalRegular", size: 14))
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
                // Bandera primero, luego nombre
                Image(equipo.flag)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(equipo.name)
                    .font(.custom("FWC2026-NormalRegular", size: 14))
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
