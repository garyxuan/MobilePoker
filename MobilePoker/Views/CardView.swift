//
//  CardView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let isSelected: Bool
    
    // 牌宽高比固定：宽:高 = 2.5:3.5
    // 基准高度：160pt（小屏自动缩放到 140pt，下限 128pt）
    private var cardHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight < 700 {
            return max(128, 140) // 小屏
        }
        return 160 // 标准屏
    }
    
    private var cardWidth: CGFloat {
        cardHeight * 2.5 / 3.5
    }
    
    private let cornerRadius: CGFloat = 12
    private let borderWidth: CGFloat = 1
    
    private var suitColor: Color {
        card.suit == .hearts || card.suit == .diamonds ? .red : .primary
    }
    
    var body: some View {
        ZStack {
            // 白底卡片
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
                .frame(width: cardWidth, height: cardHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(isSelected ? Color.primary : Color(.separator), 
                               lineWidth: isSelected ? 3 : borderWidth)
                )
                .shadow(color: Color.black.opacity(0.08), 
                       radius: isSelected ? 3 : 2, 
                       x: 0, 
                       y: isSelected ? 2 : 1)
            
            // 牌面内容
            ZStack {
                // 左上角：点数 + 花色
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.rank.displayName)
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(suitColor)
                    Text(card.suit.displayName)
                        .font(.system(.title3))
                        .foregroundColor(suitColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(8)
                
                // 中央：大花色图标
                Text(card.suit.displayName)
                    .font(.system(size: 56))
                    .foregroundColor(suitColor)
                
                // 右下角：点数 + 花色（旋转 180°）
                VStack(alignment: .trailing, spacing: 2) {
                    Text(card.rank.displayName)
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(suitColor)
                    Text(card.suit.displayName)
                        .font(.system(.title3))
                        .foregroundColor(suitColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(8)
                .rotationEffect(.degrees(180))
            }
        }
        .offset(y: isSelected ? -18 : 0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    HStack(spacing: -22) {
        CardView(card: Card(suit: .spades, rank: .ace), isSelected: false)
        CardView(card: Card(suit: .hearts, rank: .king), isSelected: true)
        CardView(card: Card(suit: .diamonds, rank: .queen), isSelected: false)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
