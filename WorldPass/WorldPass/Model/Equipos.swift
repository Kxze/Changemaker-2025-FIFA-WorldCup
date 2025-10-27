//
//  Equipos.swift
//  WorldPass
//
//  Created by Kxze on 18/10/25.
//

import Foundation

struct Equipos: Identifiable, Hashable {
    let id = UUID()
    let name: String   // Código o nombre a mostrar ("MEX" o "México")
    let flag: String   // Nombre EXACTO del asset de la bandera en Assets.xcassets
}

// Lista exacta solicitada (48 selecciones) usando códigos FIFA en 'name'
// Ordenada alfabéticamente global por 'name'
var equiposDetails = [
    Equipos(name: "ALG", flag: "argelia"),    // Argelia
    Equipos(name: "ARG", flag: "arg"),    // Argentina
    Equipos(name: "AUS", flag: "aus"),    // Australia
    Equipos(name: "BRA", flag: "brasil"),    // Brasil
    Equipos(name: "CAN", flag: "Canada"),    // Canadá
    Equipos(name: "CHI", flag: "chile"),  // Chile (asset exacto: "chile")
    Equipos(name: "CMR", flag: "camerun"),    // Camerún
    Equipos(name: "COL", flag: "col"),    // Colombia
    Equipos(name: "CRC", flag: "CostaR"),    // Costa Rica
    Equipos(name: "CRO", flag: "Cro"),    // Croacia
    Equipos(name: "CZE", flag: "Cz"),     // República Checa (asset exacto: "Cz")
    Equipos(name: "DEN", flag: "DK"),    // Dinamarca
    Equipos(name: "ECU", flag: "ecu"),    // Ecuador
    Equipos(name: "EGY", flag: "egipto"),    // Egipto
    Equipos(name: "ENG", flag: "Ing"),    // Inglaterra
    Equipos(name: "ESP", flag: "Spain"),    // España
    Equipos(name: "FRA", flag: "France"), // Francia (asset exacto: "france")
    Equipos(name: "GER", flag: "German.svg"),    // Alemania
    Equipos(name: "GHA", flag: "Ghana"),    // Ghana
    Equipos(name: "HON", flag: "Honduras"),    // Honduras
    Equipos(name: "IRN", flag: "iran"),    // Irán
    Equipos(name: "IRQ", flag: "Iraq"),   // Iraq (asset exacto: "Iraq")
    Equipos(name: "ITA", flag: "italia"),    // Italia
    Equipos(name: "JAM", flag: "Jamaica"),    // Jamaica
    Equipos(name: "JPN", flag: "japon"),    // Japón
    Equipos(name: "KOR", flag: "corea"),    // Corea del Sur
    Equipos(name: "KSA", flag: "arabia"), // Arabia Saudita (asset exacto: "arabia")
    Equipos(name: "MAR", flag: "Mar"),    // Marruecos
    Equipos(name: "MEX", flag: "mex"),    // México
    Equipos(name: "MLI", flag: "mali"),   // Malí (asset exacto: "mali")
    Equipos(name: "NED", flag: "Ned"),    // Países Bajos (asset exacto: "Ned")
    Equipos(name: "NGA", flag: "Nig"),    // Nigeria
    Equipos(name: "NOR", flag: "Noruega"),    // Noruega
    Equipos(name: "NZL", flag: "NuevaZel"),    // Nueva Zelanda
    Equipos(name: "PAN", flag: "Panama"),    // Panamá
    Equipos(name: "PAR", flag: "Paraguay"),    // Paraguay
    Equipos(name: "POL", flag: "Pol"),    // Polonia
    Equipos(name: "POR", flag: "Por"),    // Portugal
    Equipos(name: "QAT", flag: "Catar"),    // Catar
    Equipos(name: "RSA", flag: "Sud"),    // Sudáfrica
    Equipos(name: "SEN", flag: "Sen"),    // Senegal
    Equipos(name: "SRB", flag: "Serbia"),    // Serbia
    Equipos(name: "SUI", flag: "Suiza"),    // Suiza
    Equipos(name: "TUR", flag: "Turquia"),    // Turquía
    Equipos(name: "UKR", flag: "Ucrania"),    // Ucrania
    Equipos(name: "URU", flag: "uruguay"),    // Uruguay
    Equipos(name: "USA", flag: "USA"),    // Estados Unidos
    Equipos(name: "UZB", flag: "usbe")     // Uzbekistán
]
