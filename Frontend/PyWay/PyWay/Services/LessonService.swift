import Foundation
import Combine

class LessonService: ObservableObject {
    // ПРОВЕРЬ, ЧТОБЫ ТУТ БЫЛ URL ИЗ CONSTANTS ИЛИ ПРАВИЛЬНЫЙ АДРЕС
    // Если используешь Constants, напиши: let baseURL = "\(API.baseURL)/Lessons"
    private let baseURL = "http://localhost:5234/api/Lessons"
    
    @Published var isSending = false
    
    struct SubmissionResult: Decodable {
        let isCorrect: Bool
        let message: String
        let xpGained: Int? // Опционально
        let output: String?
        let actualOutput: String?
        
        var xp: Int { return xpGained ?? 0 }
    }
    
    func submitAnswer(lessonId: Int, submission: String, completion: @escaping (SubmissionResult?) -> Void) {
        guard let url = URL(string: "\(baseURL)/complete") else { return }
        
        self.isSending = true
        
        let body: [String: Any] = [
            "lessonId": lessonId,
            "submission": submission
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🚀 Отправляем решение на: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSending = false
                
                if let error = error {
                    print("❌ Ошибка сети: \(error)")
                    completion(nil)
                    return
                }
                
                // 1. ПРОВЕРЯЕМ СТАТУС КОД
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Статус код сервера: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("⛔️ Ошибка 401: Токен протух. Нужно перезайти.")
                        completion(nil)
                        return
                    }
                    if httpResponse.statusCode == 500 {
                        print("💥 Ошибка 500: Сервер упал. Смотри логи в Rider.")
                    }
                }
                
                guard let data = data else { return }
                
                // 2. СМОТРИМ, ЧТО ПРИШЛО (ТЕКСТОМ)
                if let str = String(data: data, encoding: .utf8) {
                    print("📦 Ответ сервера (RAW): \(str)")
                }
                
                // 3. ПЫТАЕМСЯ ПАРСИТЬ
                do {
                    let result = try JSONDecoder().decode(SubmissionResult.self, from: data)
                    completion(result)
                } catch {
                    print("⚠️ Ошибка парсинга JSON: \(error)")
                    // Если это ошибка 400 (неверный ответ), сервер все равно шлет JSON,
                    // но если формат отличается, мы увидим это в RAW выше.
                    completion(nil)
                }
            }
        }.resume()
    }
}
