//
//  MatchesView.swift
//  WorldPass
//
//  Created by Kxze on 16/10/25.
//

import SwiftUI

struct MatchesView: View {
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
            if !usados.contains(localID) && !usados.contains(visitanteID) {
                resultado.append(item)
                usados.insert(localID)
                usados.insert(visitanteID)
                if resultado.count == maxCount { break }
            }
        }
        return resultado
    }
    
    // Generador de marcador ficticio para demo (reutilizado)
    private func marcadorFicticio(index: Int) -> (local: Int, visitante: Int, minuto: Int?) {
        let local = (index % 3)
        let visitante = ((index + 1) % 3)
        let minuto: Int? = nil
        return (local, visitante, minuto)
    }
    
    // Generador de marcador en vivo ficticio (con minuto no nulo)
    private func marcadorEnVivoFicticio(index: Int) -> (local: Int, visitante: Int, minuto: Int) {
        let local = (index + 1) % 3
        let visitante = index % 2
        // Minuto entre 5 y 88 para simular partido en curso
        let minuto = 5 + (index * 17 % 84)
        return (local, visitante, minuto)
    }
    
    // Fechas/horas ficticias para demostración
    private func fechaHoraFicticia(index: Int) -> (fecha: String, hora: String) {
        let dias = ["16/JUL", "17/JUL", "18/JUL", "19/JUL", "20/JUL", "21/JUL", "22/JUL"]
        let horas = ["16:00", "18:30", "19:00", "20:00", "21:30", "22:00"]
        let fecha = dias[index % dias.count]
        let hora = horas[(index * 2 + 1) % horas.count]
        return (fecha, hora)
    }
    
    // Partidos en vivo: tomamos 2 de la lista y les asignamos marcador y minuto ficticio
    private var partidosEnVivo: [(partido: Partido, grupo: String, local: Int, visitante: Int, minuto: Int)] {
        let base = todosLosPartidos.shuffled()
        let seleccion = Array(base.prefix(2))
        return seleccion.enumerated().map { idx, item in
            let m = marcadorEnVivoFicticio(index: idx)
            return (partido: item.partido, grupo: item.grupo, local: m.local, visitante: m.visitante, minuto: m.minuto)
        }
    }
    
    // Partidos finalizados: tomamos 2 de la lista y simulamos marcador con MatchSimulator
    private var partidosFinalizados: [(partido: Partido, grupo: String, local: Int, visitante: Int)] {
        let base = todosLosPartidos.shuffled()
        let seleccion = Array(base.prefix(2))
        return seleccion.map { item in
            let stats = MatchSimulator.simulate(partido: item.partido)
            return (partido: item.partido, grupo: item.grupo, local: stats.local.goals, visitante: stats.visitante.goals)
        }
    }
    
    // Próximos: 2 partidos con fecha/hora ficticia
    private var partidosProximos: [(partido: Partido, grupo: String, fecha: String, hora: String)] {
        let base = todosLosPartidos.shuffled()
        let seleccion = Array(base.prefix(2))
        return seleccion.enumerated().map { idx, item in
            let fh = fechaHoraFicticia(index: idx)
            return (partido: item.partido, grupo: item.grupo, fecha: fh.fecha, hora: fh.hora)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack{
                    CalendarView().frame(width: 380)
                    
                }
                
                // Sección EN VIVO (igual a MainView)
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
                        HStack(alignment: .center, spacing: 50) {
                            ForEach(Array(partidosEnVivo.enumerated()), id: \.offset) { idx, item in
                                CardEnVivo(
                                    partido: item.partido,
                                    grupo: item.grupo,
                                    marcadorLocal: item.local,
                                    marcadorVisitante: item.visitante,
                                    minuto: item.minuto
                                )
                                .frame(width: 300)
                                .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.94)
                                        .opacity(phase.isIdentity ? 1.0 : 0.85)
                                }
                                .zIndex(1)
                            }
                        }
                        .padding(.horizontal, 40)
                        .contentShape(Rectangle())
                    }
                    .scrollClipDisabled(true)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollTargetLayout()
                }
                
                // Sección Finalizados (2 cards)
                if !partidosFinalizados.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 120){
                        Text("FINALIZADOS")
                            .font(.custom("FWC2026-NormalRegular", size: 15))
                            .padding(.horizontal, 40)
                            NavigationLink {
                                FinalizadosView()
                            } label: {
                                Text("Ver todos")
                                    .font(.custom("FWC2026-NormalRegular", size: 13))
                            }
                            .foregroundStyle(.secondary)
                        }
                        
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
                
                // Sección Próximos (igual padding que Finalizados)
                if !partidosProximos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing:140){
                            Text("PRÓXIMOS")
                                .font(.custom("FWC2026-NormalRegular", size: 15))
                                .padding(.horizontal, 40)
                            NavigationLink {
                                NextMatchesView()
                            } label: {
                                Text("Ver todos")
                                    .font(.custom("FWC2026-NormalRegular", size: 13))
                            }
                            .foregroundStyle(.secondary)                        }
                        
                        VStack(spacing: 16) {
                            ForEach(Array(partidosProximos.enumerated()), id: \.offset) { _, item in
                                CardProximo(
                                    partido: item.partido,
                                    grupo: item.grupo,
                                    fecha: item.fecha,
                                    hora: item.hora
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .vertical)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    pickNDream()
                } label: {
                    Image(systemName: "dice")
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .title) {
                Text("PARTIDOS")
                    .font(.custom("FWC2026-NormalBlack", size: 20))
            }
            ToolbarSpacer(.flexible, placement: .bottomBar)

            
        }
                
    }
}

#Preview {
    NavigationStack {
        MatchesView()
    }
}
