//
//  Equipos.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import Foundation

struct Equipos: Identifiable{
    let id = UUID()
    let name: String
    let flag: String
}

var equiposDetails = [
    Equipos(name: "MEX", flag: "mex")
]
