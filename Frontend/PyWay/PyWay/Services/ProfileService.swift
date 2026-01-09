import Foundation
import Combine

// --- МОДЕЛИ ---
struct UserProfile: Decodable {
    let username: String
    let email: String
    let totalXP: Int
    let hearts: Int
    let streak: Int
    let coursesCount: Int
    let league: LeagueInfo?
    
    // CodingKeys для защиты от разного регистра букв
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case totalXP = "totalXP" // Swift ждет totalXP
        case hearts
        case streak
        case coursesCount = "coursesCount"
        case league
    }
}

struct LeagueInfo: Decodable {
    let name: String
    let icon: String?
}

// --- СЕРВИС ---
class ProfileService: ObservableObject {
    // УБЕДИСЬ, ЧТО ПОРТ СОВПАДАЕТ С СЕРВЕРОМ!
    private let baseURL = "http://localhost:5234/api/profile/me"
    
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage = "" // <-- Сюда запишем ошибку
    
    func fetchProfile() {
        guard let url = URL(string: baseURL) else {
            self.errorMessage = "Неверный URL"
            return
        }
        
        self.isLoading = true
        self.errorMessage = "" // Сброс ошибки
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Добавляем токен (Без него сервер вернет 401 Unauthorized)
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Нет токена (нужен вход)"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    return
                }
                
                // Проверяем статус код (например, 401 - не авторизован)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        self.errorMessage = "Ошибка 401: Вы не авторизованы. Перезайдите в приложение."
                        return
                    }
                    if httpResponse.statusCode != 200 {
                        self.errorMessage = "Ошибка сервера: код \(httpResponse.statusCode)"
                        return
                    }
                }
                
                guard let data = data else { return }
                
                // Дебаг: Печатаем JSON в консоль
                if let jsonStr = String(data: data, encoding: .utf8) {
                    print("👤 PROFILE JSON: \(jsonStr)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.profile = try decoder.decode(UserProfile.self, from: data)
                } catch let DecodingError.keyNotFound(key, context) {
                    self.errorMessage = "Нет ключа: '\(key.stringValue)'. Путь: \(context.codingPath)"
                } catch let DecodingError.typeMismatch(type, context) {
                    self.errorMessage = "Не тот тип данных: \(type). Путь: \(context.codingPath)"
                } catch {
                    self.errorMessage = "Ошибка чтения JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
