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
                        .frame(height: geometry.size.height * 0.42)
                }
                
                Divider()
                
                // 手牌视图（底部）
                VStack(spacing: 0) {
                    // 标题栏
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("我的手牌")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !selectedCardIDs.isEmpty {
                            Text("已选择 \(selectedCardIDs.count) 张")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    Divider()
                    
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
                        .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(store.myHand) { card in
                                    CardView(card: card, isSelected: selectedCardIDs.contains(card.id))
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                if selectedCardIDs.contains(card.id) {
                                                    selectedCardIDs.remove(card.id)
                                                    HapticFeedback.selection()
                                                } else {
                                                    selectedCardIDs.insert(card.id)
                                                    HapticFeedback.light()
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    
                    // 操作按钮区域
                    if !selectedCardIDs.isEmpty {
                        VStack(spacing: 12) {
                            Divider()
                            
                            HStack(spacing: 12) {
                                // 取消选择按钮
                                Button(action: {
                                    withAnimation {
                                        selectedCardIDs.removeAll()
                                    }
                                    HapticFeedback.light()
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                        Text("取消")
                                    }
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                
                                // 出牌按钮
                                Button(action: {
                                    store.playCards(Array(selectedCardIDs))
                                    withAnimation {
                                        selectedCardIDs.removeAll()
                                    }
                                    HapticFeedback.medium()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.circle.fill")
                                        Text("出牌 (\(selectedCardIDs.count) 张)")
                                    }
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                        .background(Color(.systemBackground))
                    }
                }
                .frame(height: geometry.size.height * 0.58)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemGroupedBackground))
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.height < -50 {
                        // 上滑出牌
                        if !selectedCardIDs.isEmpty {
                            store.playCards(Array(selectedCardIDs))
                            withAnimation {
                                selectedCardIDs.removeAll()
                            }
                            HapticFeedback.success()
                        }
                    } else if value.translation.height > 50 {
                        // 下滑取消选择
                        if !selectedCardIDs.isEmpty {
                            withAnimation {
                                selectedCardIDs.removeAll()
                            }
                            HapticFeedback.light()
                        }
                    }
                }
        )
    }
}

