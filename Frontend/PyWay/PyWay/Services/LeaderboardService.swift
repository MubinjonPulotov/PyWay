//
//  LeaderboardService.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import Foundation
import Combine

class LeaderboardService: ObservableObject {
    // ПРОВЕРЬ СВОЙ ПОРТ!
    private let urlString = "http://localhost:5234/api/Leaderboard/top"
    
    @Published var users: [LeaderboardUser] = []
    @Published var isLoading = false
    
    func fetchLeaderboard() {
        guard let url = URL(string: urlString) else { return }
        
        self.isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                guard let data = data else { return }
                
                // Дебаг: посмотрим, что пришло
                if let str = String(data: data, encoding: .utf8) {
                    print("Leaderboard JSON: \(str)")
                }
                
                do {
                    self.users = try JSONDecoder().decode([LeaderboardUser].self, from: data)
                } catch {
                    print("Ошибка рейтинга: \(error)")
                }
            }
        }.resume()
    }
}
