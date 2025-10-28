//
//  PlayersDatabase.swift
//  WorldPass
//
//  Created by Assistant on 23/10/25.
//

import Foundation

/// Base de datos de jugadores por selección (clave = código del equipo, ej. "MEX").
/// Los códigos deben coincidir con `Equipos.name` en tu lista `equiposDetails`.
enum PlayersDatabase {
    /// Roster “típico” (11 jugadores) por selección.
    /// Puedes ajustar/actualizar los nombres cuando quieras.
    static let rosters: [String: [String]] = [
        // Argelia
        "ALG": [
            "Rais M'Bolhi",
            "Youcef Atal",
            "Aïssa Mandi",
            "Djamel Benlamri",
            "Ramy Bensebaini",
            "Ismaël Bennacer",
            "Sofiane Feghouli",
            "Hichem Boudaoui",
            "Riyad Mahrez",
            "Islam Slimani",
            "Yacine Brahimi"
        ],
        // Argentina
        "ARG": [
            "Emiliano Martínez",
            "Nahuel Molina",
            "Cristian Romero",
            "Nicolás Otamendi",
            "Marcos Acuña",
            "Rodrigo De Paul",
            "Enzo Fernández",
            "Alexis Mac Allister",
            "Lionel Messi",
            "Lautaro Martínez",
            "Ángel Di María"
        ],
        // Australia
        "AUS": [
            "Mathew Ryan",
            "Fran Karacic",
            "Harry Souttar",
            "Kye Rowles",
            "Aziz Behich",
            "Aaron Mooy",
            "Jackson Irvine",
            "Ajdin Hrustic",
            "Mathew Leckie",
            "Jamie Maclaren",
            "Awer Mabil"
        ],
        // Brasil
        "BRA": [
            "Alisson Becker",
            "Danilo",
            "Marquinhos",
            "Éder Militão",
            "Alex Sandro",
            "Casemiro",
            "Bruno Guimarães",
            "Lucas Paquetá",
            "Raphinha",
            "Richarlison",
            "Vinícius Jr."
        ],
        // Canadá
        "CAN": [
            "Milan Borjan",
            "Alistair Johnston",
            "Kamal Miller",
            "Steven Vitória",
            "Alphonso Davies",
            "Stephen Eustáquio",
            "Ismaël Koné",
            "Jonathan Osorio",
            "Tajon Buchanan",
            "Jonathan David",
            "Cyle Larin"
        ],
        // Chile
        "CHI": [
            "Claudio Bravo",
            "Mauricio Isla",
            "Gary Medel",
            "Guillermo Maripán",
            "Eugenio Mena",
            "Arturo Vidal",
            "Charles Aránguiz",
            "Erick Pulgar",
            "Alexis Sánchez",
            "Eduardo Vargas",
            "Ben Brereton Díaz"
        ],
        // Camerún
        "CMR": [
            "André Onana",
            "Collins Fai",
            "Jean-Charles Castelletto",
            "Nicolas Nkoulou",
            "Nouhou Tolo",
            "André-Frank Zambo Anguissa",
            "Martin Hongla",
            "Pierre Kunde",
            "Bryan Mbeumo",
            "Eric Maxim Choupo-Moting",
            "Vincent Aboubakar"
        ],
        // Colombia
        "COL": [
            "David Ospina",
            "Santiago Arias",
            "Davinson Sánchez",
            "Yerry Mina",
            "Johan Mojica",
            "Wilmar Barrios",
            "Mateus Uribe",
            "Juan Cuadrado",
            "James Rodríguez",
            "Luis Díaz",
            "Rafael Santos Borré"
        ],
        // Costa Rica
        "CRC": [
            "Keylor Navas",
            "Keysher Fuller",
            "Óscar Duarte",
            "Francisco Calvo",
            "Bryan Oviedo",
            "Celso Borges",
            "Yeltsin Tejeda",
            "Jewison Bennette",
            "Joel Campbell",
            "Anthony Contreras",
            "Bryan Ruiz"
        ],
        // Croacia
        "CRO": [
            "Dominik Livaković",
            "Josip Juranović",
            "Dejan Lovren",
            "Joško Gvardiol",
            "Borna Sosa",
            "Marcelo Brozović",
            "Luka Modrić",
            "Mateo Kovačić",
            "Andrej Kramarić",
            "Bruno Petković",
            "Ivan Perišić"
        ],
        // República Checa
        "CZE": [
            "Jindřich Staněk",
            "Vladimír Coufal",
            "Tomáš Kalas",
            "Jakub Brabec",
            "Jaroslav Zelený",
            "Tomáš Souček",
            "Antonín Barák",
            "Alex Král",
            "Lukáš Provod",
            "Patrik Schick",
            "Adam Hložek"
        ],
        // Dinamarca
        "DEN": [
            "Kasper Schmeichel",
            "Joakim Mæhle",
            "Simon Kjær",
            "Andreas Christensen",
            "Rasmus Kristensen",
            "Pierre-Emile Højbjerg",
            "Thomas Delaney",
            "Christian Eriksen",
            "Mikkel Damsgaard",
            "Jonas Wind",
            "Rasmus Højlund"
        ],
        // Ecuador
        "ECU": [
            "Hernán Galíndez",
            "Ángelo Preciado",
            "Félix Torres",
            "Piero Hincapié",
            "Pervis Estupiñán",
            "Carlos Gruezo",
            "Moisés Caicedo",
            "Gonzalo Plata",
            "Ángel Mena",
            "Michael Estrada",
            "Enner Valencia"
        ],
        // Egipto
        "EGY": [
            "Mohamed El Shenawy",
            "Ahmed Hegazi",
            "Mahmoud Hamdy",
            "Ahmed Fathi",
            "Ahmed Elmohamady",
            "Tarek Hamed",
            "Mohamed Elneny",
            "Abdallah Said",
            "Mohamed Salah",
            "Mostafa Mohamed",
            "Trezeguet"
        ],
        // Inglaterra
        "ENG": [
            "Jordan Pickford",
            "Kyle Walker",
            "John Stones",
            "Harry Maguire",
            "Luke Shaw",
            "Declan Rice",
            "Jude Bellingham",
            "Phil Foden",
            "Bukayo Saka",
            "Harry Kane",
            "Marcus Rashford"
        ],
        // España
        "ESP": [
            "Unai Simón",
            "Dani Carvajal",
            "Aymeric Laporte",
            "Robin Le Normand",
            "Alejandro Balde",
            "Rodri",
            "Gavi",
            "Pedri",
            "Ferran Torres",
            "Álvaro Morata",
            "Nico Williams"
        ],
        // Francia
        "FRA": [
            "Mike Maignan",
            "Jules Koundé",
            "Dayot Upamecano",
            "Ibrahima Konaté",
            "Theo Hernández",
            "Aurélien Tchouaméni",
            "Adrien Rabiot",
            "Antoine Griezmann",
            "Ousmane Dembélé",
            "Olivier Giroud",
            "Kylian Mbappé"
        ],
        // Alemania
        "GER": [
            "Marc-André ter Stegen",
            "Joshua Kimmich",
            "Antonio Rüdiger",
            "Jonathan Tah",
            "David Raum",
            "Ilkay Gündogan",
            "Toni Kroos",
            "Jamal Musiala",
            "Leroy Sané",
            "Kai Havertz",
            "Florian Wirtz"
        ],
        // Ghana
        "GHA": [
            "Lawrence Ati-Zigi",
            "Denis Odoi",
            "Daniel Amartey",
            "Mohammed Salisu",
            "Gideon Mensah",
            "Thomas Partey",
            "Iddrisu Baba",
            "Mohammed Kudus",
            "Jordan Ayew",
            "Inaki Williams",
            "Andre Ayew"
        ],
        // Honduras
        "HON": [
            "Luis López",
            "Maynor Figueroa",
            "Denil Maldonado",
            "Marcelo Pereira",
            "Diego Rodríguez",
            "Boniek García",
            "Bryan Acosta",
            "Alexander López",
            "Romell Quioto",
            "Antony Lozano",
            "Alberth Elis"
        ],
        // Irán
        "IRN": [
            "Alireza Beiranvand",
            "Ramin Rezaeian",
            "Morteza Pouraliganji",
            "Hossein Kanaani",
            "Milad Mohammadi",
            "Saeid Ezatolahi",
            "Ahmad Noorollahi",
            "Mehdi Torabi",
            "Alireza Jahanbakhsh",
            "Mehdi Taremi",
            "Sardar Azmoun"
        ],
        // Iraq
        "IRQ": [
            "Jalal Hassan",
            "Rebin Sulaka",
            "Ahmad Ibrahim",
            "Ali Adnan",
            "Hussein Ali",
            "Osama Rashid",
            "Bashar Resan",
            "Aymen Hussein",
            "Mohannad Ali",
            "Humam Tariq",
            "Amjad Attwan"
        ],
        // Italia
        "ITA": [
            "Gianluigi Donnarumma",
            "Giovanni Di Lorenzo",
            "Alessandro Bastoni",
            "Francesco Acerbi",
            "Federico Dimarco",
            "Jorginho",
            "Nicolò Barella",
            "Lorenzo Pellegrini",
            "Federico Chiesa",
            "Giacomo Raspadori",
            "Domenico Berardi"
        ],
        // Jamaica
        "JAM": [
            "Andre Blake",
            "Alvas Powell",
            "Damion Lowe",
            "Ethan Pinnock",
            "Amari'i Bell",
            "Ravel Morrison",
            "Daniel Johnson",
            "Bobby Decordova-Reid",
            "Leon Bailey",
            "Michail Antonio",
            "Shamar Nicholson"
        ],
        // Japón
        "JPN": [
            "Shuichi Gonda",
            "Hiroki Sakai",
            "Maya Yoshida",
            "Takehiro Tomiyasu",
            "Yuto Nagatomo",
            "Wataru Endo",
            "Hidemasa Morita",
            "Daichi Kamada",
            "Takefusa Kubo",
            "Daizen Maeda",
            "Kaoru Mitoma"
        ],
        // Corea del Sur
        "KOR": [
            "Kim Seung-gyu",
            "Kim Min-jae",
            "Kim Young-gwon",
            "Kim Moon-hwan",
            "Kim Jin-su",
            "Hwang In-beom",
            "Jung Woo-young",
            "Lee Jae-sung",
            "Hwang Hee-chan",
            "Cho Gue-sung",
            "Son Heung-min"
        ],
        // Arabia Saudita
        "KSA": [
            "Mohammed Al-Owais",
            "Sultan Al-Ghannam",
            "Abdulelah Al-Amri",
            "Ali Al-Bulayhi",
            "Yasser Al-Shahrani",
            "Abdulellah Al-Malki",
            "Salman Al-Faraj",
            "Mohamed Kanno",
            "Fahad Al-Muwallad",
            "Saleh Al-Shehri",
            "Salem Al-Dawsari"
        ],
        // Marruecos
        "MAR": [
            "Yassine Bounou",
            "Achraf Hakimi",
            "Romain Saïss",
            "Nayef Aguerd",
            "Noussair Mazraoui",
            "Sofyan Amrabat",
            "Azzedine Ounahi",
            "Hakim Ziyech",
            "Sofiane Boufal",
            "Youssef En-Nesyri",
            "Abdelhamid Sabiri"
        ],
        // México
        "MEX": [
            "Guillermo Ochoa",
            "Jorge Sánchez",
            "César Montes",
            "Johan Vásquez",
            "Jesús Gallardo",
            "Edson Álvarez",
            "Luis Chávez",
            "Héctor Herrera",
            "Hirving Lozano",
            "Raúl Jiménez",
            "Alexis Vega"
        ],
        // Malí
        "MLI": [
            "Ibrahim Mounkoro",
            "Hamari Traoré",
            "Boubakar Kouyaté",
            "Moussa Diarra",
            "Massadio Haïdara",
            "Yves Bissouma",
            "Amadou Haidara",
            "Mohamed Camara",
            "Adama Traoré",
            "Ibrahima Koné",
            "Moussa Djenepo"
        ],
        // Países Bajos
        "NED": [
            "Justin Bijlow",
            "Denzel Dumfries",
            "Virgil van Dijk",
            "Matthijs de Ligt",
            "Nathan Aké",
            "Frenkie de Jong",
            "Marten de Roon",
            "Teun Koopmeiners",
            "Steven Bergwijn",
            "Memphis Depay",
            "Cody Gakpo"
        ],
        // Nigeria
        "NGA": [
            "Francis Uzoho",
            "Ola Aina",
            "William Troost-Ekong",
            "Calvin Bassey",
            "Zaidu Sanusi",
            "Wilfred Ndidi",
            "Alex Iwobi",
            "Joe Aribo",
            "Samuel Chukwueze",
            "Victor Osimhen",
            "Moses Simon"
        ],
        // Noruega
        "NOR": [
            "Ørjan Nyland",
            "Omar Elabdellaoui",
            "Andreas Hanche-Olsen",
            "Kristoffer Ajer",
            "Birger Meling",
            "Sander Berge",
            "Martin Ødegaard",
            "Morten Thorsby",
            "Mohamed Elyounoussi",
            "Erling Haaland",
            "Alexander Sørloth"
        ],
        // Nueva Zelanda
        "NZL": [
            "Oli Sail",
            "Tim Payne",
            "Winston Reid",
            "Tommy Smith",
            "Liberato Cacace",
            "Joe Bell",
            "Clayton Lewis",
            "Sarpreet Singh",
            "Callum McCowatt",
            "Chris Wood",
            "Kosta Barbarouses"
        ],
        // Panamá
        "PAN": [
            "Luis Mejía",
            "Michael Murillo",
            "Fidel Escobar",
            "Andrés Andrade",
            "Eric Davis",
            "Aníbal Godoy",
            "Adalberto Carrasquilla",
            "Alberto Quintero",
            "Edgar Bárcenas",
            "José Fajardo",
            "Gabriel Torres"
        ],
        // Paraguay
        "PAR": [
            "Antony Silva",
            "Robert Rojas",
            "Gustavo Gómez",
            "Junior Alonso",
            "Blas Riveros",
            "Mathías Villasanti",
            "Andrés Cubas",
            "Miguel Almirón",
            "Ángel Romero",
            "Gabriel Ávalos",
            "Alejandro Romero Gamarra"
        ],
        // Polonia
        "POL": [
            "Wojciech Szczęsny",
            "Matty Cash",
            "Jan Bednarek",
            "Kamil Glik",
            "Bartosz Bereszyński",
            "Grzegorz Krychowiak",
            "Piotr Zieliński",
            "Przemysław Frankowski",
            "Sebastian Szymański",
            "Robert Lewandowski",
            "Arkadiusz Milik"
        ],
        // Portugal
        "POR": [
            "Diogo Costa",
            "João Cancelo",
            "Rúben Dias",
            "Pepe",
            "Nuno Mendes",
            "João Palhinha",
            "Bruno Fernandes",
            "Bernardo Silva",
            "Diogo Jota",
            "Cristiano Ronaldo",
            "Rafael Leão"
        ],
        // Catar
        "QAT": [
            "Saad Al Sheeb",
            "Pedro Miguel",
            "Boualem Khoukhi",
            "Tarek Salman",
            "Abdelkarim Hassan",
            "Karim Boudiaf",
            "Abdulaziz Hatem",
            "Akram Afif",
            "Hasan Al-Haydos",
            "Almoez Ali",
            "Mohammed Muntari"
        ],
        // Sudáfrica
        "RSA": [
            "Ronwen Williams",
            "Thapelo Morena",
            "Siyanda Xulu",
            "Mothobi Mvala",
            "Terrence Mashego",
            "Teboho Mokoena",
            "Thibang Phete",
            "Percy Tau",
            "Themba Zwane",
            "Lyle Foster",
            "Evidence Makgopa"
        ],
        // Senegal
        "SEN": [
            "Édouard Mendy",
            "Youssouf Sabaly",
            "Kalidou Koulibaly",
            "Abdou Diallo",
            "Fodé Ballo-Touré",
            "Idrissa Gana Gueye",
            "Pape Sarr",
            "Cheikhou Kouyaté",
            "Ismaïla Sarr",
            "Boulaye Dia",
            "Sadio Mané"
        ],
        // Serbia
        "SRB": [
            "Vanja Milinković-Savić",
            "Nikola Milenković",
            "Miloš Veljković",
            "Strahinja Pavlović",
            "Filip Kostić",
            "Sergej Milinković-Savić",
            "Nemanja Gudelj",
            "Dušan Tadić",
            "Andrija Živković",
            "Dušan Vlahović",
            "Aleksandar Mitrović"
        ],
        // Suiza
        "SUI": [
            "Yann Sommer",
            "Silvan Widmer",
            "Manuel Akanji",
            "Nico Elvedi",
            "Ricardo Rodríguez",
            "Remo Freuler",
            "Granit Xhaka",
            "Xherdan Shaqiri",
            "Ruben Vargas",
            "Breel Embolo",
            "Haris Seferović"
        ],
        // Turquía
        "TUR": [
            "Uğurcan Çakır",
            "Zeki Çelik",
            "Merih Demiral",
            "Çağlar Söyüncü",
            "Ferdi Kadıoğlu",
            "Okay Yokuşlu",
            "Hakan Çalhanoğlu",
            "Orkun Kökçü",
            "Cengiz Ünder",
            "Cenk Tosun",
            "Arda Güler"
        ],
        // Ucrania
        "UKR": [
            "Andriy Lunin",
            "Oleksandr Karavaev",
            "Illia Zabarnyi",
            "Mykola Matviyenko",
            "Vitaliy Mykolenko",
            "Taras Stepanenko",
            "Mykola Shaparenko",
            "Ruslan Malinovskyi",
            "Andriy Yarmolenko",
            "Roman Yaremchuk",
            "Mykhailo Mudryk"
        ],
        // Uruguay
        "URU": [
            "Sergio Rochet",
            "Nahitan Nández",
            "Ronald Araújo",
            "José María Giménez",
            "Matías Viña",
            "Federico Valverde",
            "Manuel Ugarte",
            "Rodrigo Bentancur",
            "Facundo Pellistri",
            "Darwin Núñez",
            "Giorgian de Arrascaeta"
        ],
        // Estados Unidos
        "USA": [
            "Matt Turner",
            "Sergiño Dest",
            "Walker Zimmerman",
            "Tim Ream",
            "Antonee Robinson",
            "Tyler Adams",
            "Weston McKennie",
            "Gio Reyna",
            "Christian Pulisic",
            "Folarin Balogun",
            "Tim Weah"
        ],
        // Uzbekistán
        "UZB": [
            "Eldor Shomurodov",
            "Abdulla Abdujaparov",
            "Khojiakbar Alijonov",
            "Islom Kobilov",
            "Abbosbek Fayzullaev",
            "Jaloliddin Masharipov",
            "Odil Ahmedov",
            "Otabek Shukurov",
            "Shukhrat Mukhammadiev",
            "Igor Sergeev",
            "Dostonbek Khamdamov"
        ]
    ]

    /// Formación preferida por selección (ej. "4-3-3", "4-2-3-1", "3-5-2"...).
    /// Puedes ajustarla libremente.
    static let formations: [String: String] = [
        "ALG": "4-3-3",
        "ARG": "4-3-3",
        "AUS": "4-2-3-1",
        "BRA": "4-3-3",
        "CAN": "4-4-2",
        "CHI": "4-3-3",
        "CMR": "4-3-3",
        "COL": "4-2-3-1",
        "CRC": "5-4-1",
        "CRO": "4-3-3",
        "CZE": "4-2-3-1",
        "DEN": "4-3-3",
        "ECU": "4-4-2",
        "EGY": "4-3-3",
        "ENG": "4-2-3-1",
        "ESP": "4-3-3",
        "FRA": "4-2-3-1",
        "GER": "4-2-3-1",
        "GHA": "4-3-3",
        "HON": "4-4-2",
        "IRN": "4-2-3-1",
        "IRQ": "4-3-3",
        "ITA": "4-3-3",
        "JAM": "4-3-3",
        "JPN": "4-2-3-1",
        "KOR": "4-2-3-1",
        "KSA": "4-3-3",
        "MAR": "4-1-4-1",
        "MEX": "4-3-3",
        "MLI": "4-3-3",
        "NED": "3-4-1-2",
        "NGA": "4-3-3",
        "NOR": "4-4-2",
        "NZL": "4-4-2",
        "PAN": "4-4-2",
        "PAR": "4-2-3-1",
        "POL": "4-2-3-1",
        "POR": "4-3-3",
        "QAT": "5-3-2",
        "RSA": "4-4-2",
        "SEN": "4-3-3",
        "SRB": "3-5-2",
        "SUI": "4-2-3-1",
        "TUR": "4-2-3-1",
        "UKR": "4-3-3",
        "URU": "4-3-3",
        "USA": "4-3-3",
        "UZB": "4-4-2"
    ]

    /// Devuelve el listado de nombres (XI) para un equipo concreto (por código).
    static func roster(forTeamCode code: String) -> [String]? {
        rosters[code]
    }

    /// Devuelve el listado de nombres (XI) para un `Equipos`.
    static func roster(for team: Equipos) -> [String]? {
        rosters[team.name]
    }

    /// Devuelve la formación preferida (ej. "4-3-3") para un código de equipo.
    static func preferredFormation(forTeamCode code: String) -> String {
        formations[code] ?? "4-3-3"
    }

    /// Devuelve la formación preferida para un `Equipos`.
    static func preferredFormation(for team: Equipos) -> String {
        preferredFormation(forTeamCode: team.name)
    }
}

// MARK: - Conversión a Player con posiciones según formación

extension PlayersDatabase {
    /// Convierte una lista de nombres en `Player` asignando posiciones según una formación.
    /// Soporta 3 o 4 bloques (p.ej., "4-3-3", "4-2-3-1", "3-5-2", "3-4-1-2").
    /// Reglas:
    /// - 1 Portero (GK)
    /// - Primer bloque = Defensas (DF)
    /// - Bloques intermedios (si hay más de 2) suman como Mediocampistas (MF)
    /// - Último bloque = Delanteros (FW)
    static func playersFromRoster(_ names: [String], formation: String) -> [Player] {
        let blocks = formation
            .split(separator: "-")
            .compactMap { Int($0) }
        let defenders = blocks.first ?? 4
        let forwards = blocks.last ?? 3
        let midfielders: Int = {
            if blocks.count <= 2 { return blocks.dropFirst().first ?? 3 }
            // suma de los bloques intermedios
            let middle = blocks.dropFirst().dropLast()
            return middle.reduce(0, +)
        }()

        // Construimos la lista de posiciones en orden GK, DF..., MF..., FW...
        var positions: [PlayerPosition] = [.GK]
        positions += Array(repeating: .DF, count: max(0, defenders))
        positions += Array(repeating: .MF, count: max(0, midfielders))
        positions += Array(repeating: .FW, count: max(0, forwards))

        // Si el roster no coincide en tamaño, truncamos o completamos con MF
        let count = min(names.count, positions.count)
        var result: [Player] = []

        for i in 0..<count {
            let name = names[i]
            let pos = i < positions.count ? positions[i] : .MF
            let number = min(i + 1, 99)
            result.append(Player(name: name, number: number, position: pos))
        }

        // Si hay más nombres que posiciones, los restantes como MF
        if names.count > positions.count {
            for i in positions.count..<names.count {
                let name = names[i]
                let number = min(i + 1, 99)
                result.append(Player(name: name, number: number, position: .MF))
            }
        }

        return result
    }

    /// Construye un Lineup completo para un equipo (si hay datos en la base).
    static func buildLineup(for team: Equipos) -> Lineup? {
        guard let names = roster(for: team) else { return nil }
        let formation = preferredFormation(for: team)
        let players = playersFromRoster(names, formation: formation)
        return Lineup(team: team, formation: formation, players: players)
    }
}
