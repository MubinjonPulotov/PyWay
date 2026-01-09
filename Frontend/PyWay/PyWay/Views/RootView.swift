import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView()
            } else {
                AuthScreen()
            }
        }
        // 🔥 ВОТ ЭТА МАГИЯ. Добавь эту строчку:
        .id(authService.isAuthenticated)
        // Это заставляет SwiftUI "убить" старый экран и создать новый
        
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}
