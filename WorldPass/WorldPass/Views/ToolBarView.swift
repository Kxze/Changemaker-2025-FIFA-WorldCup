//
//  ToolBarView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI
import Combine

final class TabSelection: ObservableObject {
    enum TabID: Hashable {
        case main, matches, wallet
    }

    @Published var selection: TabID = .main
}

struct ToolBarView: View {
    @EnvironmentObject var tabSelection: TabSelection

    var body: some View {
        TabView(selection: $tabSelection.selection) {
            NavigationStack {
                MainView()
            }
            // Anula el tinte dentro del contenido para no afectar botones
            .tint(nil)
            .tabItem {
                Label("Main", systemImage: "house")
            }
            .tag(TabSelection.TabID.main)

            NavigationStack {
                MatchesView()
            }
            // Anula el tinte dentro del contenido para no afectar botones
            .tint(nil)
            .tabItem {
                Label("Matches", systemImage: "soccerball.inverse")
            }
            .tag(TabSelection.TabID.matches)

            NavigationStack {
                WalletView()
            }
            // Anula el tinte dentro del contenido para no afectar botones
            .tint(nil)
            .tabItem {
                Label("Wallet", systemImage: "wallet.bifold.fill")
            }
            .tag(TabSelection.TabID.wallet)
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        // Este tinte solo debe afectar los iconos/estado de la Tab Bar
        .tint(tintColor(for: tabSelection.selection))
    }

    private func tintColor(for tab: TabSelection.TabID) -> Color {
        switch tab {
        case .main: return .red
        case .matches: return .blue
        case .wallet: return .green
        }
    }
}

#Preview {
    ToolBarView()
        .environmentObject(TabSelection())
}
