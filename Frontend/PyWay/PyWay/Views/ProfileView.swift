import SwiftUI

struct ProfileView: View {
    @StateObject var profileService = ProfileService()
    
    // Мы убрали кнопку выхода, но сервис все равно нужен для имени и т.д.
    @EnvironmentObject var authService: AuthService
    
    // Для смены иконки
    @State private var showIconPicker = false
    @State private var selectedIcon = "person.crop.circle.fill"
    
    let availableIcons = ["person.crop.circle.fill", "person.fill", "star.circle.fill", "bolt.circle.fill", "heart.circle.fill", "gamecontroller.fill"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if profileService.isLoading {
                ProgressView("Боргирӣ...")
                    .foregroundColor(.white)
            } else if let user = profileService.profile {
                VStack(spacing: 20) {
                    
                    // --- АВАТАРКА ---
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: selectedIcon)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                        
                        Button(action: { showIconPicker = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.yellow)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        .offset(x: 5, y: 5)
                    }
                    .padding(.top, 40)
                    
                    // ИМЯ И ЛИГА
                    Text(user.username)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(user.league?.name ?? "Без лиги")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    Divider().background(Color.gray)
                    
                    // СТАТИСТИКА
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatCard(title: "Ҳамагӣ XP", value: "\(user.totalXP)", icon: "bolt.fill", color: .yellow)
                        StatCard(title: "Ҳаётча", value: "\(user.hearts)/5", icon: "heart.fill", color: .red)
                        StatCard(title: "Страйк", value: "\(user.streak) дней", icon: "flame.fill", color: .orange)
                        StatCard(title: "Курсҳо", value: "\(user.coursesCount)", icon: "book.fill", color: .blue)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
        // --- ВЫБОР ИКОНКИ ---
        .sheet(isPresented: $showIconPicker) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Text("Аватари худро интихоб кунед")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                                showIconPicker = false
                            }) {
                                Image(systemName: icon)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(selectedIcon == icon ? .yellow : .gray)
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            profileService.fetchProfile()
        }
    }
}

// Карточка статистики
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .padding(.bottom, 5)
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6).opacity(0.2))
        .cornerRadius(15)
    }
}
