//
//  MainView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct MainView: View {
    // Fuente: todos los partidos con su grupo asociado en una lista plana
    private var todosLosPartidos: [(partido: Partido, grupo: String)] {
        var items: [(partido: Partido, grupo: String)] = []
        for grupo in gruposMundial2026 {
            for p in grupo.partidos {
                items.append((partido: p, grupo: grupo.nombre))
            }
        }
        return items
    }
    
    // Selecciona hasta 'maxCount' partidos sin equipos repetidos
    private func seleccionarPartidosSinRepetidos(from lista: [(partido: Partido, grupo: String)], maxCount: Int) -> [(partido: Partido, grupo: String)] {
        var usados: Set<UUID> = [] // IDs de equipos usados
        var resultado: [(partido: Partido, grupo: String)] = []
        
        for item in lista {
            let localID = item.partido.local.id
            let visitanteID = item.partido.visitante.id
            // Si ninguno de los dos equipos está ya en uso, añadimos el partido
            if !usados.contains(localID) && !usados.contains(visitanteID) {
                resultado.append(item)
                usados.insert(localID)
                usados.insert(visitanteID)
                if resultado.count == maxCount { break }
            }
        }
        return resultado
    }
    
    private var partidosEnVivo: [(partido: Partido, grupo: String)] {
        // Puedes barajar para variedad y luego filtrar sin repetidos:
        let barajada = todosLosPartidos.shuffled()
        return seleccionarPartidosSinRepetidos(from: barajada, maxCount: 5)
    }
    
    // Generador de marcador ficticio para "En vivo"
    private func marcadorFicticio(index: Int) -> (local: Int, visitante: Int, minuto: Int?) {
        // Minuto entre 1 y 90, marcador pequeño
        let local = (index % 3)
        let visitante = ((index + 1) % 3)
        let minuto = 5 + (index * 13) % 90
        return (local, visitante, minuto)
    }
    
    // Partidos finalizados: tomamos 2 de la lista y les asignamos marcador ficticio (sin minuto)
    private var partidosFinalizados: [(partido: Partido, grupo: String, local: Int, visitante: Int)] {
        let base = todosLosPartidos.shuffled()
        let seleccion = Array(base.prefix(2))
        return seleccion.enumerated().map { idx, item in
            let m = marcadorFicticio(index: idx + 7) // offset para variar respecto a "En vivo"
            return (partido: item.partido, grupo: item.grupo, local: m.local, visitante: m.visitante)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CardEventos()
                // Sección En vivo (Horizontal)
                if !partidosEnVivo.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HOY")
                            .font(.custom("FWC2026-NormalBlack", size: 20))
                        HStack{
                            Image(systemName: "circle.fill")
                                .foregroundStyle(.red)
                                .glassEffect()
                            Text("EN VIVO")
                                .font(.custom("FWC2026-NormalRegular", size: 15))
                            
                            
                        }
                    }
                    .padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment:.center, spacing: 50) {
                            ForEach(Array(partidosEnVivo.enumerated()), id: \.offset) { idx, item in
                                let m = marcadorFicticio(index: idx)
                                CardEnVivo(
                                    partido: item.partido,
                                    grupo: item.grupo,
                                    marcadorLocal: m.local,
                                    marcadorVisitante: m.visitante,
                                    minuto: m.minuto
                                )
                                .frame(width: 300)
                                // Transición/animación durante el scroll
                                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.94)
                                        .opacity(phase.isIdentity ? 1.0 : 0.85)
                                }
                                .zIndex(1) // ayuda a que el overdraw no quede por debajo
                            }
                        }
                        // margen interno para permitir que el efecto se salga sin ser cortado
                        .padding(.horizontal, 40)
                        // Importante: evitar clipping del scroll
                        .contentShape(Rectangle())
                    }
                    
                    // Deshabilita el clip del ScrollView horizontal (iOS 17+)
                    .scrollClipDisabled(true)
                    // Hace que el scroll se alinee por vistas, más suave
                    .scrollTargetBehavior(.viewAligned)
                    // Layout target para que cada tarjeta sea un target de scroll
                    .scrollTargetLayout()
                } else {
                    // Fallback si no hay suficientes partidos (no debería ocurrir con 48 equipos)
                    Text("No hay partidos en vivo disponibles")
                        .font(.custom("FWC2026-NormalRegular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                // Sección Finalizados (2 cards)
                if !partidosFinalizados.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FINALIZADOS")
                            .font(.custom("FWC2026-NormalRegular", size: 15))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            ForEach(Array(partidosFinalizados.enumerated()), id: \.offset) { _, item in
                                CardFinalizado(
                                    partido: item.partido,
                                    grupo: item.grupo,
                                    marcadorLocal: item.local,
                                    marcadorVisitante: item.visitante
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    Tournament()
                } label: {
                    Image(systemName: "globe.americas.fill")
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .title) {
                Image("logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProfileView()
                } label: {
                    Image(systemName: "person")
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        
    }
}

#Preview {
    NavigationStack { MainView() }
}
