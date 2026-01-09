//
//  DataService.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import Foundation
import Combine

class DataService: ObservableObject {
    // Проверь порт!
    private let baseURL = "http://localhost:5234/api"
    
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func fetchCourses() {
        guard let url = URL(string: "\(baseURL)/Courses") else { return }
        
        self.isLoading = true
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 1. Достаем токен из памяти
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Хатогии боргирӣ: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else { return }
                
                // 2. Превращаем JSON в массив курсов
                do {
                    let decodedCourses = try JSONDecoder().decode([Course].self, from: data)
                    self.courses = decodedCourses
                } catch {
                    print("Хатогии парсинг: \(error)")
                    self.errorMessage = "Не удалось обработать данные"
                }
            }
        }.resume()
    }
}
