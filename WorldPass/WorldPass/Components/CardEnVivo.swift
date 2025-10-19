//
//  CardEnVivo.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import SwiftUI

struct CardEnVivo: View {
    let partido: Partido
    let grupo: String
    let marcadorLocal: Int
    let marcadorVisitante: Int
    let minuto: Int? // nil si aún no inicia o no disponible

    var body: some View {
        
        ZStack {
            HStack(alignment: .center, spacing: 16) {
                // Lado izquierdo: Equipo local
                equipoView(equipo: partido.local, alignment: .leading)
                    .zIndex(1)
                    .padding(.leading, 50)
                    .offset(y:15)

                
                // Centro: Logo, grupo, marcador y minuto
                VStack(spacing: 16) {
                    // Logo FifaPlus arriba del grupo, pequeño y con máscara de rectángulo redondeado
                    Image("FifaPlus")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .offset(y:-5)
                    
                    Text(grupo.uppercased())
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundColor(.primary)
                        .offset(y:-12)
                    
                    HStack(alignment: .center, spacing: 20) {
                        Text("\(marcadorLocal)")
                            .font(.custom("FWC2026-NormalBlack", size: 30))
                        Text(":")
                            .font(.custom("FWC2026-NormalBlack", size: 24))
                            .foregroundColor(.primary)
                        Text("\(marcadorVisitante)")
                            .font(.custom("FWC2026-NormalBlack", size:30))
                    }
                    .offset(y: -20)
                    .foregroundColor(.primary)
                    
                    Text(minutoText)
                        .offset(y:-20)
                        .font(.custom("FWC2026-NormalRegular", size: 12))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.green, lineWidth: 1.5)
                                .offset(x: -1,y:-20)
                                .frame(width: 50)
                        )
                    
                }
                .zIndex(0)
                .frame(maxWidth: 200)
                
                // Lado derecho: Equipo visitante
                equipoView(equipo: partido.visitante, alignment: .trailing)
                    .zIndex(1)
                    .padding(.trailing, 50)
                    .offset(y:15)

            }
            //Tamaño de la card
            .frame(width: 350,height: 175)
            .glassEffect(in: .rect(cornerRadius: 25, style: .continuous))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        
        
    }

    private func equipoView(equipo: Equipos, alignment: HorizontalAlignment) -> some View {
        VStack(spacing:10) {
            Image(equipo.flag)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            

            // Nombre centrado debajo de la bandera
            Text(equipo.name)
                .font(.custom("FWC2026-NormalRegular", size: 20))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: 90, alignment: .center)
                
        }
        
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
        
    }

    private var minutoText: String {
        if let m = minuto {
            return "\(m)′"
        } else {
            return "Por iniciar"
        }
    }
}

#Preview {
    // Ejemplo de uso con datos reales del proyecto:
    // Tomamos dos equipos de equiposDetails para el partido de prueba.
    let local = equiposDetails[0]
    let visitante = equiposDetails[1]
    let partido = Partido(local: local, visitante: visitante)

    return VStack(spacing: 16) {
        CardEnVivo(
            partido: partido,
            grupo: "Grupo A",
            marcadorLocal: 1,
            marcadorVisitante: 0,
            minuto: 23
        )

    }
    .padding()
}
