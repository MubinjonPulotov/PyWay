//
//  CodingToolbar.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import SwiftUI

struct CodingToolbar: View {
    @Binding var text: String
    
    // Список кнопок, которые нам нужны
    let symbols = ["Tab", "print", "(", ")", "\"", "=", ":", "+", "-", "[", "]", "#"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(symbols, id: \.self) { symbol in
                    Button(action: {
                        insertText(symbol)
                    }) {
                        Text(symbol == "Tab" ? "⇥" : symbol)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.black)) // Серый фон подложки
        .cornerRadius(10)
    }
    
    func insertText(_ symbol: String) {
        // Простая логика вставки в конец (для MVP)
        // В идеале тут нужен доступ к курсору (UITextView), но в SwiftUI это сложно
        if symbol == "Tab" {
            text += "    " // 4 пробела
        } else if symbol == "print" {
            text += "print()"
        } else {
            text += symbol
        }
    }
}

struct CodingToolbar_Previews: PreviewProvider {
    static var previews: some View {
        CodingToolbar(text: .constant(""))
            .background(Color.black)
    }
}
