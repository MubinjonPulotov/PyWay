//
//  LeaderboardModels.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//

import Foundation

struct LeaderboardUser: Decodable, Identifiable {
    let id: Int
    let username: String
    let totalXP: Int
    let leagueName: String
    
    // Подстраховка для регистра букв (C# vs Swift)
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case totalXP = "totalXP" // Или totalxp, если сервер шлет маленькими
        case leagueName = "leagueName"
    }
}
