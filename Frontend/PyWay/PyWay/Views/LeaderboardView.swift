//
//  LeaderboardView.swift
//  PyWay
//
//  Created by Mubinjon on 31/12/25.
//


import SwiftUI

struct LeaderboardView: View {
    @StateObject var service = LeaderboardService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Заголовок
                HStack {
                    Text("Топ Питонистҳо 🏆")
                        .font(.title)
                        .bold()
                        .foregroundColor(.yellow)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                if service.isLoading {
                    Spacer()
                    ProgressView("Боргирии титанҳло...")
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            // Перебираем пользователей с индексом (чтобы знать место)
                            ForEach(Array(service.users.enumerated()), id: \.element.id) { index, user in
                                UserRow(rank: index + 1, user: user)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            service.fetchLeaderboard()
        }
    }
}

// Строка одного пользователя
struct UserRow: View {
    let rank: Int
    let user: LeaderboardUser
    
    var body: some View {
        HStack {
            // Место (1, 2, 3...)
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 40, height: 40)
                        .shadow(color: rankColor.opacity(0.5), radius: 5)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                }
                
                Text("\(rank)")
                    .bold()
                    .foregroundColor(rank <= 3 ? .black : .white)
            }
            
            // Имя и Лига
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(user.leagueName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 5)
            
            Spacer()
            
            // XP
            Text("\(user.totalXP) XP")
                .font(.system(.body, design: .monospaced))
                .bold()
                .foregroundColor(.yellow)
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.15))
        .cornerRadius(15)
        // Выделяем топ-3 рамкой
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(rank <= 3 ? rankColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
    
    // Цвет в зависимости от места
    var rankColor: Color {
        switch rank {
        case 1: return Color.yellow // Золото
        case 2: return Color(white: 0.8) // Серебро
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Бронза
        default: return .gray
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
