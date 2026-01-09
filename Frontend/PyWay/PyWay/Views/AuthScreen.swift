//
//  AuthScreen.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import SwiftUI

struct AuthScreen: View {
    @StateObject var authService = AuthService()
    
    // Переключатель: true = показываем Вход, false = Регистрацию
    @State private var isLoginMode = false 
    
    // Поля ввода
    @State private var username = ""
    @State private var email = "" // Только для регистрации
    @State private var password = ""
    
    var body: some View {
        // Если мы уже авторизованы (есть токен), показываем "Внутренности" приложения
        if authService.isAuthenticated {
            // В будущем здесь будет MainMenuView
            HomeView()
        } else {
            // ЭКРАН АВТОРИЗАЦИИ
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    // 1. Логотип и Заголовок
                    VStack(spacing: 10) {
                        Image(systemName: "terminal.fill") // Временная иконка
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)
                        
                        Text("PyWay")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(isLoginMode ? "Бозгашт муборак!" : "Сафари Python-и худро оғоз кунед!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    // 2. Поля ввода
                    VStack(spacing: 15) {
                        CustomTextField(placeholder: "Логин", text: $username, icon: "person")
                        
                        // Поле Email показываем только при регистрации
                        if !isLoginMode {
                            CustomTextField(placeholder: "Email", text: $email, icon: "envelope")
                                .transition(.opacity.combined(with: .move(edge: .top))) // Анимация появления
                        }
                        
                        CustomSecureField(placeholder: "Парол", text: $password)
                    }
                    .padding(.horizontal)
                    
                    // 3. Сообщение об ошибке
                    if !authService.errorMessage.isEmpty {
                        Text(authService.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // 4. Главная Кнопка (Вход или Регистрация)
                    Button(action: handleAction) {
                        Text(isLoginMode ? "Логин" : "Сохтани аккаунт")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                            .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 5. Кнопка переключения режима
                    Button(action: {
                        withAnimation(.spring()) {
                            isLoginMode.toggle()
                            authService.errorMessage = "" // Очищаем ошибки при переключении
                        }
                    }) {
                        HStack {
                            Text(isLoginMode ? "Aккаунт мавҷуд нест?" : "Аккаунт аллакай хаст?")
                                .foregroundColor(.gray)
                            Text(isLoginMode ? "Бақайдгирӣ" : "Ворид шудан")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // Логика нажатия кнопки
    func handleAction() {
        if isLoginMode {
            // Логика ВХОДА
            authService.login(username: username, password: password)
        } else {
            // Логика РЕГИСТРАЦИИ
            authService.register(username: username, email: email, password: password) { success in
                if success {
                    // Если регистрация прошла успешно, переключаемся на режим Входа
                    // и просим пользователя ввести пароль (или можно сразу логинить)
                    withAnimation {
                        self.isLoginMode = true
                        self.authService.errorMessage = "Аккаунт сохта шуд! Акнун ворид шавед ."
                    }
                }
            }
        }
    }
}

// --- Красивые поля ввода (Компоненты) ---

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthScreen()
    }
}
