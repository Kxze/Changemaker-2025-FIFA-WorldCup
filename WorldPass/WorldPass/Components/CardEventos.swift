//
//  CardEventos.swift
//  WorldPass
//
//  Created by Kxze on 19/10/25.
//

import SwiftUI

struct CardEventos: View {
    var body: some View {
        HStack(spacing:10){
            VStack(alignment: .leading, spacing: 40){
                HStack(spacing:80){
                    
                        Text("GRUPO A PARTIDO INAUGURAL")
                            .font(.custom("FWC2026-NormalRegular", size: 13))
                
                }
                VStack(alignment: .leading, spacing: 1){
                    Text("MÉXICO VS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("PAISES BAJOS")
                        .font(.custom("FWC2026-NormalBlack", size: 20))
                    Text("ESTADIO AZTECA")
                        .font(.custom("FWC2026-NormalRegular", size: 13))
                    Text("CDMX")
                        .font(.custom("FWC2026-NormalRegular", size: 13))
                }
                HStack{
                    HStack{
                        Text("16 DE JUL 2026")
                            .font(.custom("FWC2026-NormalRegular", size: 13))
                        Spacer()
                        HStack{
                            Spacer()

                           
                        }
                    }
                }
            }
            VStack(alignment: .trailing, spacing: 120){
                Image("mundialLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50,height: 70)
                Text("16:30 HRS")
                    .font(.custom("FWC2026-NormalRegular", size: 13))
            }
        }
        .frame(width:350, height: 150)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .glassEffect(in: .rect(cornerRadius: 25, style: .continuous))
        .tint(.green)
        
        
        
    }
}

#Preview {
    CardEventos()
}
