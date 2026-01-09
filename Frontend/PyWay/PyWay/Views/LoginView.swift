import SwiftUI

struct LoginView: View {
    // Доступ к переключателю экранов через RootView
    @EnvironmentObject var authService: AuthService
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showRegistration = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // 1. Черный фон
            
            VStack(spacing: 20) {
                Spacer()
                
                // 2. Логотип терминала (Вернули!)
                Image(systemName: "terminal.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 10)
                
                Text("PyWay")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Хуш омадед!")
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                // 3. Темные поля ввода (Вернули!)
                VStack(spacing: 15) {
                    TextField("Номи истифодабаранда", text: $username)
                        .padding()
                        .background(Color(UIColor.systemGray6)) // Темно-серый цвет
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                    SecureField("Рамз", text: $password)
                        .padding()
                        .background(Color(UIColor.systemGray6)) // Темно-серый цвет
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Ошибка
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // 4. Желтая кнопка "Войти"
                Button(action: performLogin) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Логин")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.yellow)
                .foregroundColor(.black)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
                
                Spacer()
                
               
            }
        }
        .sheet(isPresented: $showRegistration) {
            AuthScreen()
        }
    }
    
    func performLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Ҳамаи маълумотро пурра дароред"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // УБЕДИСЬ, ЧТО ПОРТ ПРАВИЛЬНЫЙ!
        guard let url = URL(string: "http://localhost:5234/api/Auth/login") else { return }
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Хатоги алоқа: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else { return }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Успешный вход
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        
                        // Сохраняем токен
                        UserDefaults.standard.set(token, forKey: "authToken")
                        
                        // !!! ВАЖНО: Сообщаем RootView, что мы вошли !!!
                        self.authService.isAuthenticated = true
                        
                    } else {
                        self.errorMessage = "Хатогии хондани токен"
                    }
                } else {
                    self.errorMessage = "Логин ё рамз хато!"
                }
            }
        }.resume()
    }
}
