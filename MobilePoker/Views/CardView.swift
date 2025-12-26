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
    
    private var suitColor: Color {
        card.suit == .hearts || card.suit == .diamonds ? .red : .primary
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .frame(width: 64, height: 96)
                .shadow(color: isSelected ? Color.accentColor.opacity(0.4) : Color.black.opacity(0.1), 
                       radius: isSelected ? 8 : 4, 
                       x: 0, 
                       y: isSelected ? 4 : 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color(.separator), 
                               lineWidth: isSelected ? 3 : 1)
                )
            
            VStack(spacing: 6) {
                Text(card.rank.displayName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(suitColor)
                
                Text(card.suit.displayName)
                    .font(.system(size: 28))
                    .foregroundColor(suitColor)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    HStack(spacing: 20) {
        CardView(card: Card(suit: .spades, rank: .ace), isSelected: false)
        CardView(card: Card(suit: .hearts, rank: .king), isSelected: true)
        CardView(card: Card(suit: .diamonds, rank: .queen), isSelected: false)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

