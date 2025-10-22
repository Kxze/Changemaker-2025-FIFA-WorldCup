//
//  Ticket.swift
//  WorldPass
//
//  Created by Kxze on 21/10/25.
//

import SwiftUI

struct Ticket: View {
    var body: some View {
        ZStack{
            Image("Ticket")
            VStack(spacing:20){
                VStack(alignment: .leading){
                    HStack(spacing: 130){
                        Text("ESTADIO AZTECA")
                        Text("5:00 PM")
                    }
                    HStack(spacing: 100){
                        Text("MEXICO - HOLANDA")
                        Text("16 JULIO")
                    }
                }
                Image("FondoRojo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 490, height: 150)
                    .clipped()
                HStack{
                    Text("GRUPO A - PARTIDO INAGURAL")
                    
                }
                HStack(spacing: 200){
                    
                    VStack(alignment: .leading){
                        Text("SECCIÓN")
                        Text("GRAL B")
                    }
                    VStack(alignment: .trailing){
                        Text("ASIENTO")
                        Text("14-F")
                    }
                }
            }
            .padding(.horizontal, 100)
        }
    }
}

#Preview {
    Ticket()
}
