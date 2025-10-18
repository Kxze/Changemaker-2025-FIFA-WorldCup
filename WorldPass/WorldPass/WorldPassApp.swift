//
//  WorldPassApp.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

@main
struct WorldPassApp: App {
    @StateObject private var tabSelection = TabSelection()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabSelection)
        }
    }
}
