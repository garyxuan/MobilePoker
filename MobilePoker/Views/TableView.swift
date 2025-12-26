//
//  TableView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct TableView: View {
    let stacks: [TableCardStack]
    let players: [Player]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题
            HStack {
                Image(systemName: "rectangle.stack")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("桌面")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            
            Divider()
            
            if stacks.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("暂无出牌")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(stacks.reversed()) { stack in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(playerName(for: stack.playerID))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(stack.cards) { card in
                                            CardView(card: card, isSelected: false)
                                                .scaleEffect(0.75)
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func playerName(for playerID: String) -> String {
        players.first(where: { $0.id == playerID })?.name ?? "未知玩家"
    }
}

#Preview {
    TableView(
        stacks: [
            TableCardStack(playerID: "1", cards: [
                Card(suit: .spades, rank: .ace),
                Card(suit: .spades, rank: .king)
            ])
        ],
        players: [Player(id: "1", name: "玩家1", deviceID: "device1")]
    )
}

