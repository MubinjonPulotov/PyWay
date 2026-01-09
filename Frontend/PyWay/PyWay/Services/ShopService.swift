//
//  ShopService.swift
//  PyWay
//
//  Created by Mubinjon on 01/01/26.
//


import Foundation
import Combine

class ShopService: ObservableObject {
    private let baseURL = "http://localhost:5234/api/Shop/buy"
    
    @Published var isLoading = false
    @Published var message = ""
    @Published var isSuccess = false
    @Published var showError = false
    
    // Результат покупки
    struct ShopResponse: Decodable {
        let message: String
        let newXP: Int
        let hearts: Int
        let freezes: Int
    }
    
    func buyItem(itemId: String, completion: @escaping (ShopResponse?) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        self.isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: String] = ["itemId": itemId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200, let data = data {
                        // УСПЕХ
                        if let result = try? JSONDecoder().decode(ShopResponse.self, from: data) {
                            self.message = result.message
                            self.isSuccess = true
                            self.showError = true // Используем тот же алерт
                            completion(result)
                            return
                        }
                    } else if let data = data, let errStr = String(data: data, encoding: .utf8) {
                        // ОШИБКА (например "Недостаточно XP")
                        self.message = errStr.replacingOccurrences(of: "\"", with: "") // Убираем кавычки
                        self.isSuccess = false
                        self.showError = true
                        completion(nil)
                        return
                    }
                }
                self.message = "Ошибка соединения"
                self.showError = true
                completion(nil)
            }
        }.resume()
    }
}
