import Foundation

// MARK: - Course
struct Course: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    // В JSON может не быть иконки, поэтому опционально
    let iconUrl: String?
    let modules: [Module]
    
    // CodingKeys нужны, если названия отличаются, но тут всё стандартно
    // Swift сам поймет camelCase, но для надежности оставим явные
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case iconUrl // Swift ждет iconUrl, и в JSON скорее всего будет iconUrl (или null)
        case modules
    }
}

// MARK: - Module
struct Module: Decodable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let lessons: [Lesson]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case lessons
    }
}

// MARK: - Lesson
struct Lesson: Decodable, Identifiable {
    let id: Int
    let title: String
    let lessonType: String
    let xpReward: Int
    
    // contentData приходит как строка JSON (видно на скрине),
    // нам она понадобится внутри урока
    let contentData: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        
        // ВНИМАНИЕ: Исправлено под твой скриншот!
        case lessonType = "lessonType" // Было "lessontype", стало как на скрине
        case xpReward = "xpReward"     // Было "xpreward", стало как на скрине
        
        case contentData // Добавили поле с контентом
    }
}
