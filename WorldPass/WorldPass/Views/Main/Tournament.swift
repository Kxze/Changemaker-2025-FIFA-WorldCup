//
//  Tournament.swift
//  WorldPass
//
//  Created by Kxze on 19/10/25.
//

import SwiftUI

struct Tournament: View {
    var body: some View {
         
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Título de la sección
                    HStack {
                        Text("FASE DE GRUPOS")
                            .font(.custom("FWC2026-NormalBlack", size: 20))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    ZStack{
                        LazyVStack(spacing: 16) {
                            ForEach(gruposMundial2026) { grupo in
                                GroupCapsuleView(grupo: grupo)
                            }
                            .offset(x:15, y:10)
                            .opacity(0.9)
                        }
                        // Lista de grupos
                        LazyVStack(spacing: 16) {
                            ForEach(gruposMundial2026) { grupo in
                                GroupCapsuleView(grupo: grupo)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .title) {
                    Image("logo")
                }
            }
        }
    }


private struct GroupCapsuleView: View {
    let grupo: Grupo

    // 2 columnas para formar los 4 cuadrantes (2x2)
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Encabezado del grupo
            HStack {
                Text(grupo.nombre.uppercased())
                    .font(.custom("FWC2026-NormalBlack", size: 16))
                    .foregroundColor(.primary)
                Spacer()
            }

            // Grid 2x2: 4 cuadrantes, uno por equipo
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(grupo.equipos) { equipo in
                    MiniTeamQuadrant(equipo: equipo, puntos: 0)
                }
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 25, style: .continuous))
    }
}

private struct MiniTeamQuadrant: View {
    let equipo: Equipos
    let puntos: Int

    var body: some View {
        HStack(spacing: 10) {
            // 1) Nombre
            Text(equipo.name)
                .font(.custom("FWC2026-NormalRegular", size: 14))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)

            // 2) Bandera
            Image(equipo.flag)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 30)

            // 3) Puntaje
            Text("\(puntos) pts")
                .font(.custom("FWC2026-NormalBlack", size: 10))
                .foregroundColor(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        Tournament()
    }
}
