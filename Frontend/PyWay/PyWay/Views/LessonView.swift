import SwiftUI

struct LessonView: View {
    let moduleTitle: String
    let lessons: [Lesson]
    
    @Environment(\.dismiss) var dismiss
    @StateObject var lessonService = LessonService()
    
    // Состояния
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var consoleOutput = ""
    // ... другие @State ...
        @State private var showErrorAlert = false
        @State private var errorMessage = ""
    
    // Анимация и Результаты
    @State private var showResult = false
    @State private var showSuccess = false
    @State private var xpEarned = 0
    @State private var shakeAmount: CGFloat = 0
    
    var currentLesson: Lesson? {
        if lessons.isEmpty || currentIndex >= lessons.count { return nil }
        return lessons[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if lessons.isEmpty {
                VStack {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.yellow)
                    Text("Уроков нет").foregroundColor(.gray)
                }
            } else if let lesson = currentLesson {
                VStack {
                    // Прогресс
                    ProgressView(value: Double(currentIndex + 1), total: Double(lessons.count))
                        .accentColor(.green).padding()
                    
                    Text(lesson.title).font(.title2).bold().foregroundColor(.white).padding(.bottom)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 1. ТЕОРИЯ
                            if lesson.lessonType == "Theory", let content = getTheory(from: lesson) {
                                Text(content.markdown.replacingOccurrences(of: "\\n", with: "\n"))
                                    .foregroundColor(.white).font(.body)
                            }
                            
                            // 2. ТЕСТ (Исправленная зона нажатия)
                            else if lesson.lessonType == "Quiz", let content = getQuiz(from: lesson) {
                                Text(content.question).font(.headline).foregroundColor(.white).padding(.bottom, 10)
                                
                                VStack(spacing: 12) {
                                    ForEach(content.options) { option in
                                        let isSelected = (userAnswer == String(option.id))
                                        let isCorrect = option.is_correct
                                        
                                        Button(action: {
                                            if !showResult {
                                                userAnswer = String(option.id)
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                            }
                                        }) {
                                            HStack(alignment: .center, spacing: 15) {
                                                // Иконка
                                                ZStack {
                                                    Circle()
                                                        .stroke(iconBorderColor(isSelected: isSelected, isCorrect: isCorrect), lineWidth: 2)
                                                        .frame(width: 24, height: 24)
                                                    
                                                    if showResult {
                                                        if isCorrect {
                                                            Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundColor(.green)
                                                        } else if isSelected {
                                                            Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(.red)
                                                        }
                                                    } else if isSelected {
                                                        Circle().fill(Color.yellow).frame(width: 14, height: 14)
                                                    }
                                                }
                                                
                                                // Текст
                                                Text(option.text)
                                                    .font(.body)
                                                    .fontWeight(isSelected ? .medium : .regular)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.leading)
                                                
                                                Spacer() // Растягивает кнопку на всю ширину
                                            }
                                            .padding(.vertical, 16)
                                            .padding(.horizontal, 20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(cardBackgroundColor(isSelected: isSelected, isCorrect: isCorrect))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(cardBorderColor(isSelected: isSelected, isCorrect: isCorrect), lineWidth: isSelected || (showResult && isCorrect) ? 2 : 1)
                                            )
                                            // 🔥 САМОЕ ВАЖНОЕ ИСПРАВЛЕНИЕ:
                                            // Делает всю область (включая Spacer) кликабельной
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle()) // Убирает стандартный эффект нажатия
                                    }
                                }
                            }
                            
                            // 3. КОД
                            else if lesson.lessonType == "Code", let content = getCode(from: lesson) {
                                Text(content.task_description).foregroundColor(.white)
                                
                                TextEditor(text: $userAnswer)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.green)
                                    .background(Color(UIColor.systemGray6).opacity(0.2))
                                    .cornerRadius(8)
                                    .frame(height: 200)
                                    .modifier(ShakeEffect(animatableData: shakeAmount))
                                    .onAppear {
                                        if userAnswer.isEmpty {
                                            userAnswer = content.starter_code?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
                                        }
                                    }
                                
                                // Панель
                                CodingToolbar(text: $userAnswer).padding(.bottom, 5)
                                
                                if !consoleOutput.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("Натиҷа:").font(.caption).foregroundColor(.gray)
                                        Text(consoleOutput).font(.system(.caption, design: .monospaced)).foregroundColor(.white)
                                    }
                                    .padding().background(Color.black).cornerRadius(5).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Кнопка действия (Проверить)
                    Button(action: { submitLesson(lesson: lesson) }) {
                        if lessonService.isSending {
                            ProgressView().foregroundColor(.black)
                        } else {
                            Text(lesson.lessonType == "Theory" ? "Ба пеш" : (showResult && lesson.lessonType == "Quiz" ? "Ба пеш" : "Ок"))
                                .bold().frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle()) // Тоже делаем всю кнопку кликабельной
                    .modifier(ShakeEffect(animatableData: shakeAmount))
                }
            }
            
            if showSuccess {
                FloatingSuccess(xp: xpEarned)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .onChange(of: currentIndex) { _, _ in resetState() }
        // Добавляем тап по фону, чтобы скрывать клавиатуру
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Хатогӣ"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
    }
    
    // --- ПАРСЕРЫ ---
    func getTheory(from lesson: Lesson) -> TheoryContent? {
        guard let d = lesson.contentData?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TheoryContent.self, from: d)
    }
    func getQuiz(from lesson: Lesson) -> QuizContent? {
        guard let d = lesson.contentData?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(QuizContent.self, from: d)
    }
    func getCode(from lesson: Lesson) -> CodeContent? {
        guard let d = lesson.contentData?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CodeContent.self, from: d)
    }
    
    // --- ЛОГИКА ---
    func submitLesson(lesson: Lesson) {
        if lesson.lessonType == "Theory" { nextLesson(); return }
        
        if lesson.lessonType == "Quiz" && showResult { nextLesson(); return }
        
        if lesson.lessonType == "Quiz" && userAnswer.isEmpty { shakeUI(); return }
        
        lessonService.submitAnswer(lessonId: lesson.id, submission: userAnswer) { result in
            guard let result = result else { return }
            
            // Если сервер вернул сообщение об ошибке (например, нет жизней)
                        if !result.isCorrect && result.message.contains("Ҳает ба итмом расид") {
                            self.errorMessage = result.message
                            self.showErrorAlert = true
                            return
                        }
            if let output = result.output { self.consoleOutput = output }
            else if let actual = result.actualOutput { self.consoleOutput = actual }
            
            if result.isCorrect {
                self.xpEarned = result.xp
                withAnimation { self.showResult = true }
                withAnimation(.spring()) { self.showSuccess = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { self.showSuccess = false }
                    self.nextLesson()
                }
            } else {
                if lesson.lessonType == "Quiz" {
                    withAnimation { self.showResult = true }
                    shakeUI()
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                } else {
                    shakeUI()
                }
            }
        }
    }
    
    func nextLesson() {
        if currentIndex < lessons.count - 1 {
            withAnimation { currentIndex += 1 }
        } else {
            dismiss()
        }
    }
    
    func resetState() {
        userAnswer = ""; consoleOutput = ""; showResult = false; showSuccess = false; shakeAmount = 0
    }
    func shakeUI() { withAnimation(.default) { shakeAmount += 1 } }
}

// --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
extension LessonView {
    func cardBackgroundColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if showResult {
            if isCorrect { return Color.green.opacity(0.15) }
            if isSelected && !isCorrect { return Color.red.opacity(0.15) }
        }
        return Color(UIColor.systemGray6).opacity(isSelected ? 0.4 : 0.2)
    }
    func cardBorderColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if showResult {
            if isCorrect { return Color.green }
            if isSelected && !isCorrect { return Color.red }
        }
        if isSelected { return Color.yellow }
        return Color.white.opacity(0.1)
    }
    func iconBorderColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if showResult {
            if isCorrect { return Color.green }
            if isSelected && !isCorrect { return Color.red }
        }
        if isSelected { return Color.yellow }
        return Color.gray.opacity(0.5)
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10; var shakesPerUnit: CGFloat = 3; var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}
struct FloatingSuccess: View {
    let xp: Int
    var body: some View {
        VStack { Spacer(); HStack(spacing: 15) { Image(systemName: "star.fill").foregroundColor(.yellow).font(.largeTitle); Text("+\(xp) XP").font(.title).bold().foregroundColor(.yellow) }.padding().background(Color.black.opacity(0.8)).cornerRadius(30).overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.yellow, lineWidth: 2)).shadow(color: .yellow.opacity(0.5), radius: 20).padding(.bottom, 100) }
    }
}
