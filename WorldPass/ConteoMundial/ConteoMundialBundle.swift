//
//  ConteoMundialBundle.swift
//  ConteoMundial
//
//  Created by Pau Pau on 09/11/25.
//

import WidgetKit
import SwiftUI

@main
struct ConteoMundialBundle: WidgetBundle {
    var body: some Widget {
        ConteoMundial()
        ConteoMundialControl()
        ConteoMundialLiveActivity()
    }
}
