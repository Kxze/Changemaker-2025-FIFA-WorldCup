//
//  ToolBarView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct ToolBarView: View {
    var body: some View {
        TabView{
            Tab("Main", systemImage: "house"){
                MainView()
            }
            Tab("Wallet", systemImage: "wallet.bifold.fill"){
                WalletView()
            }
            Tab("Profile", systemImage: "person.circle.fill"){
                ProfileView()
            }
        }
    }
}

#Preview {
    ToolBarView()
}
