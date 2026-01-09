import SwiftUI

struct HomeView: View {
    @StateObject var dataService = DataService()
    
    // Состояние для открытия Рейтинга
    @State private var showLeaderboard = false
    // В самом начале HomeView:
        @State private var showShop = false

        
    var body: some View {
        // ВАЖНО: NavigationView должен быть здесь!
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if dataService.isLoading {
                    ProgressView("Боргирии курсҳо...")
                        .foregroundColor(.white)
                } else {
                    ScrollView {
                        // --- ВЕРХНЯЯ ПАНЕЛЬ ---
                        HStack {
                            Text("Сафари Питонист 🐍")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            
                                
                                // Кнопка Магазина (НОВАЯ)
                                Button(action: {
                                    // Тут нужно состояние showShop, добавь @State private var showShop = false в начале HomeView
                                    showShop = true
                                }) {
                                    Image(systemName: "cart.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.cyan) // Голубой цвет для магазина
                                }
                                .padding(.trailing, 10)
                            // Кнопка Рейтинга
                            Button(action: { showLeaderboard = true }) {
                                Image(systemName: "trophy.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.orange)
                            }
                            .padding(.trailing, 10)
                            
                            // Кнопка Профиля
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding()
                        
                        // --- СПИСОК КУРСОВ ---
                        VStack(spacing: 20) {
                            ForEach(dataService.courses) { course in
                                CourseCard(course: course)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true) // Скрываем стандартный заголовок
            .onAppear {
                dataService.fetchCourses()
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            // Внизу, после .sheet(Leaderboard):
            .sheet(isPresented: $showShop) {
                ShopView()
            }
        }
    }
}

// --- КАРТОЧКА КУРСА ---
struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.yellow)
                    .font(.title)
                Text(course.title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text(course.description ?? "")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Divider().background(Color.gray)
            
            // --- СПИСОК МОДУЛЕЙ (КНОПКИ) ---
            ForEach(course.modules) { module in
                // Вот эта ссылка заставляет кнопки работать:
                NavigationLink(destination: ModuleLoaderView(moduleId: module.id, moduleTitle: module.title)) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        
                        Text(module.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12) // Увеличил зону нажатия
                    .contentShape(Rectangle()) // Чтобы нажималось по всей строке
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.15))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// --- ModuleLoaderView (Вспомогательный, оставляем как был) ---
// (Если нужно, могу продублировать код ModuleLoaderView, но он у тебя уже есть правильный с черным фоном)
// Вставь сюда код ModuleLoaderView из прошлого ответа, если он пропал.
struct ModuleLoaderView: View {
    let moduleId: Int
    let moduleTitle: String
    @State private var lessons: [Lesson] = []
    @State private var isLoading = true
    @State private var debugMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.white)
            } else if !debugMessage.isEmpty {
                ScrollView {
                    Text(debugMessage).foregroundColor(.red).padding()
                }
            } else {
                LessonView(moduleTitle: moduleTitle, lessons: lessons)
            }
        }
        .task {
            // ПРОВЕРЬ СВОЙ URL!
            let urlString = "http://localhost:5234/api/courses/module/\(moduleId)"
            guard let url = URL(string: urlString) else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let module = try JSONDecoder().decode(Module.self, from: data)
                self.lessons = module.lessons ?? []
                self.isLoading = false
            } catch {
                self.debugMessage = "Error: \(error)"
                self.isLoading = false
            }
        }
    }
}
