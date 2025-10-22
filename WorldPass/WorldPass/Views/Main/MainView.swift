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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack{
                    HStack{
                        Text("PRÓXIMOS EVENTOS")
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .font(.custom("FWC2026-NormalBlack", size: 20))
                    
                    CardEventos()
                    
                }
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
            }
            .padding(.vertical, 16)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    Tournament()
                        .toolbar(.hidden, for: .navigationBar)
                        // Si usas TabView y quieres ocultar la barra inferior también:
                        //.toolbar(.hidden, for: .tabBar)
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
                        .toolbar(.hidden, for: .navigationBar)
                        //.toolbar(.hidden, for: .tabBar)
                } label: {
                    Image(systemName: "person")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            NavigationLink {
                ZayuIntroView()
                    .toolbar(.hidden, for: .navigationBar)
                    //.toolbar(.hidden, for: .tabBar)
            } label: {
                Image(systemName: "apple.intelligence")
                    .font(.custom("", size: 25))
                    .foregroundStyle(.gray)
                    .padding(12)
                    .glassEffect()
            }
            .padding(.trailing, 30)  // margen desde el borde izquierdo
        }

        
    }
}

#Preview {
    NavigationStack { MainView() }
}
