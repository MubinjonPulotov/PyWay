import SwiftUI

@main
struct PyWayApp: App {
    // ВАЖНО: StateObject (Создает), а не ObservedObject
    @StateObject var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            AuthScreen()
                .environmentObject(authService) // Передаем сервис вниз
        }
    }
}
