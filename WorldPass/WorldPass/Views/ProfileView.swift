//
//  ProfileView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var tabSelection: TabSelection

    var body: some View {
        VStack {
            Text("Contenido del perfil")
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("PERFIL")
                    .font(.title)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(TabSelection())
    }
}
