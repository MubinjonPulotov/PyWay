//
//  AuthService.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import Foundation
import Combine

class AuthService: ObservableObject {
    // ЗАМЕНИ ПОРТ НА СВОЙ!
    // Для Симулятора localhost работает.
    // Если будешь запускать на реальном iPhone, нужно будет писать IP компьютера (например 192.168.1.5)
    private let baseURL = "http://localhost:5234/api/Auth" 
    
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    init() {
            // Проверяем, есть ли сохраненный токен при запуске
            self.isAuthenticated = UserDefaults.standard.string(forKey: "authToken") != nil
        }
    // ... внутри class AuthService ...

        // Функция регистрации
        // completion: @escaping (Bool) -> Void — это чтобы экран узнал, успешно мы зарегистрировались или нет
        func register(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
            // Убедись, что URL правильный (register)
            guard let url = URL(string: "\(baseURL)/register") else { return }
            
            let body = RegisterRequest(username: username, email: email, password: password)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                        completion(false)
                        return
                    }
                    
                    // Если сервер ответил 200 OK
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        print("Бақайдгирӣ муваффақ!")
                        completion(true) // Сообщаем экрану, что все ок
                    } else {
                        // Пытаемся прочитать ошибку от сервера
                        if let data = data, let errString = String(data: data, encoding: .utf8) {
                            self.errorMessage = "Хатогӣ: \(errString)"
                        } else {
                            self.errorMessage = "Хатогии бақайдгирӣ"
                        }
                        completion(false)
                    }
                }
            }.resume()
        }
    
    
    // Сохраняем токен в памяти телефона
    func login(username: String, password: String) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        let body = LoginRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Хатогии сет: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else { return }
                
                // Если сервер вернул 200 OK
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        // Сохраняем токен (по-простому в UserDefaults)
                        UserDefaults.standard.set(decodedResponse.token, forKey: "authToken")
                        self.isAuthenticated = true
                        print("Токен получен: \(decodedResponse.token)")
                    }
                } else {
                    self.errorMessage = "Парол ё логини хато"
                }
            }
        }.resume()
    }
    
    
    
        func logout() {
            // 1. Удаляем токен из памяти телефона
            UserDefaults.standard.removeObject(forKey: "authToken")
            
            // 2. Переключаем состояние (приложение само сменит экран)
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
        }
        
        // В методе login (успешном) не забудь добавить:
        // self.isAuthenticated = true
    }

