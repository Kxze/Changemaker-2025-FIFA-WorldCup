//
//  MainView.swift
//  WorldPass
//
//  Created by Kxze on 13/10/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Main")
            // Aquí podrías navegar hacia ProfileView si lo deseas:
             NavigationLink("Ir al Perfil") { ProfileView() }
        }
        .navigationTitle("MAIN")
    }
}

#Preview {
    NavigationStack { MainView() }
}
