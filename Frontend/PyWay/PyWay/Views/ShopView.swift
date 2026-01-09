//
//  ShopView.swift
//  PyWay
//
//  Created by Mubinjon on 01/01/26.
//


import SwiftUI

struct ShopView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var shopService = ShopService()
    @StateObject var profileService = ProfileService() // Чтобы знать свой баланс XP
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let user = profileService.profile {
                VStack(spacing: 20) {
                    
                    // --- ШАПКА ---
                    HStack {
                        Text("Мағоза 🛒")
                            .font(.largeTitle).bold().foregroundColor(.white)
                        Spacer()
                        // Баланс
                        HStack {
                            Image(systemName: "bolt.fill").foregroundColor(.yellow)
                            Text("\(user.totalXP)").bold().foregroundColor(.yellow)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                    // --- ИНВЕНТАРЬ ---
                    HStack(spacing: 20) {
                        InfoBadge(icon: "heart.fill", value: "\(user.hearts)/5", color: .red)
                        InfoBadge(icon: "snowflake", value: "\(user.streak) шт", color: .cyan) // Используем streak поле пока как заглушку, потом добавим freezes
                    }
                    .padding(.bottom)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            
                            // ТОВАР 1: ЖИЗНИ
                            ShopItemCard(
                                title: "Барқарор",
                                description: "Пуркунии ҳаёт то 5",
                                price: 50,
                                icon: "heart.fill",
                                color: .red,
                                action: {
                                    shopService.buyItem(itemId: "heart_refill") { res in
                                        if res != nil { profileService.fetchProfile() } // Обновляем баланс
                                    }
                                }
                            )
                            
                            // ТОВАР 2: ЗАМОРОЗКА
                            ShopItemCard(
                                title: "Яхкунӣ",
                                description: "Страйкро ба як рӯз қафо мон",
                                price: 200,
                                icon: "snowflake",
                                color: .cyan,
                                action: {
                                    shopService.buyItem(itemId: "streak_freeze") { res in
                                        if res != nil { profileService.fetchProfile() }
                                    }
                                }
                            )
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView().tint(.white).onAppear { profileService.fetchProfile() }
            }
            
            // Алерт с результатом
            if shopService.isLoading {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                }
            }
        }
        .alert(isPresented: $shopService.showError) {
            Alert(
                title: Text(shopService.isSuccess ? "Муваффақ!" : "Хатогӣ"),
                message: Text(shopService.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// --- КОМПОНЕНТЫ ---
struct ShopItemCard: View {
    let title: String
    let description: String
    let price: Int
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                    .padding()
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 35)
                }
                
                HStack {
                    Image(systemName: "bolt.fill").foregroundColor(.yellow).font(.caption)
                    Text("\(price)").bold().foregroundColor(.yellow)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6).opacity(0.3))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let value: String
    let color: Color
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(color)
            Text(value).bold().foregroundColor(.white)
        }
        .padding(10)
        .background(Color(UIColor.systemGray6).opacity(0.5))
        .cornerRadius(10)
    }
}
