//
//  ContentModel.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//

import Foundation

// 1. Для ТЕОРИИ
struct TheoryContent: Decodable {
    let markdown: String
}

// 2. Для ТЕСТА (QUIZ)
struct QuizContent: Decodable {
    let question: String
    let options: [QuizOption]
}

struct QuizOption: Decodable, Identifiable {
    let id: Int
    let text: String
    let is_correct: Bool
}

// 3. Для КОДА
struct CodeContent: Decodable {
    let task_description: String // В базе написано через подчеркивание
    let starter_code: String?
    let expected_output: String?
}
