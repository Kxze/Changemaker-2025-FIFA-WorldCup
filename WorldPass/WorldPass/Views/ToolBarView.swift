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
        TabView{
            Tab("", systemImage: "house.fill")
            {
                NavigationStack{
                    MainView()
                }
            }
            
            Tab("", systemImage: "soccerball.inverse"){
                NavigationStack{
                    MatchesView()
                }
            }
            Tab("", systemImage: "wallet.bifold") {
                NavigationStack{
                    WalletView()
                }
            }
            
        }
        .tabBarMinimizeBehavior(.onScrollDown)
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
