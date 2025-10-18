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
        case main, wallet, profile
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
            .tabItem {
                Label("Main", systemImage: "house")
            }
            .tag(TabSelection.TabID.main)

            NavigationStack {
                MatchesView()
            }
            .tabItem {
                Label("Matches", systemImage: "soccerball.inverse")
            }
            .tag(TabSelection.TabID.profile)

            NavigationStack {
                WalletView()
            }
            .tabItem {
                Label("Wallet", systemImage: "wallet.bifold.fill")
            }
            .tag(TabSelection.TabID.wallet)
        }
        .tint(tintColor(for: tabSelection.selection))
    }

    private func tintColor(for tab: TabSelection.TabID) -> Color {
        switch tab {
        case .main: return .red
        case .wallet: return .green
        case .profile: return .blue
        }
    }
}

#Preview {
    ToolBarView()
        .environmentObject(TabSelection())
}
