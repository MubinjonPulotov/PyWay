import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

// Добавляем вот это:
struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let userId: Int
    let username: String
    let role: String
}
