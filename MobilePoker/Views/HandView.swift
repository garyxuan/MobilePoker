//
//  HandView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct HandView: View {
    @ObservedObject var store: GameStore
    @State private var selectedCardIDs: Set<String> = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 桌面视图（顶部）
                if let state = store.gameState {
                    TableView(stacks: state.table, players: state.players)
                        .frame(height: geometry.size.height * 0.55)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 点击桌面区域清空选择
                            if !selectedCardIDs.isEmpty {
                                withAnimation {
                                    selectedCardIDs.removeAll()
                                }
                                HapticFeedback.light()
                            }
                        }
                }
                
                Divider()
                
                // 手牌区域（底部，占约 45%）
                VStack(spacing: 0) {
                    // 手牌滚动区域
                    if store.myHand.isEmpty {
                        // 空状态
                        VStack(spacing: 16) {
                            Image(systemName: "hand.raised.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("手牌已出完")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        HandCarouselView(
                            cards: store.myHand,
                            selectedCardIDs: $selectedCardIDs,
                            onCardTapped: { cardID in
                                if cardID == "__PLAY__" {
                                    // 上滑出牌
                                    store.playCards(Array(selectedCardIDs))
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        selectedCardIDs.removeAll()
                                    }
                                    HapticFeedback.medium()
                                } else {
                                    // 切换选中状态
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        if selectedCardIDs.contains(cardID) {
                                            selectedCardIDs.remove(cardID)
                                            HapticFeedback.selection()
                                        } else {
                                            selectedCardIDs.insert(cardID)
                                            HapticFeedback.light()
                                        }
                                    }
                                }
                            }
                        )
                        .frame(height: geometry.size.height * 0.45)
                    }
                    
                    // 提示条
                    VStack(spacing: 0) {
                        HandHintBar(selectedCount: selectedCardIDs.count)
                            .padding(.bottom, 12)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                }
                .frame(height: geometry.size.height * 0.45)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: store.myHand) { _,newHand in
            // 当手牌更新时，清理不存在的 selection
            let newHandIDs = Set(newHand.map { $0.id })
            selectedCardIDs = selectedCardIDs.filter { newHandIDs.contains($0) }
        }
    }
}
