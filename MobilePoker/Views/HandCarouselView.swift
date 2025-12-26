//
//  HandCarouselView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct HandCarouselView: View {
    let cards: [Card]
    @Binding var selectedCardIDs: Set<String>
    let onCardTapped: (String) -> Void
    
    @State private var dragState: DragState = .idle
    @State private var gestureDirection: GestureDirection = .none
    
    private enum DragState {
        case idle
        case dragging(translation: CGSize)
    }
    
    private enum GestureDirection {
        case none
        case horizontal
        case vertical
    }
    
    // 计算重叠距离
    private func calculateReveal(for cardCount: Int, availableWidth: CGFloat) -> CGFloat {
        let baseReveal = availableWidth / max(8, CGFloat(cardCount)) * 0.9
        return clamp(baseReveal, 16, 28)
    }
    
    // 计算卡牌尺寸（与 CardView 保持一致）
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
    
    var body: some View {
        GeometryReader { geometry in
            let cardCount = cards.count
            let availableWidth = geometry.size.width - 40 // 左右 padding
            let reveal = calculateReveal(for: cardCount, availableWidth: availableWidth)
            let totalWidth = cardWidth + CGFloat(max(0, cardCount - 1)) * reveal
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -reveal) {
                    ForEach(cards) { card in
                        CardView(card: card, isSelected: selectedCardIDs.contains(card.id))
                            .onTapGesture {
                                onCardTapped(card.id)
                            }
                    }
                }
                .frame(width: max(totalWidth, geometry.size.width - 40))
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 20)
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        // 手势方向锁定：初始 0~12pt 内不判定
                        if gestureDirection == .none {
                            let dx = abs(value.translation.width)
                            let dy = abs(value.translation.height)
                            
                            // 超过阈值后判断方向
                            if dy > 12 || dx > 12 {
                                gestureDirection = abs(dy) > abs(dx) ? .vertical : .horizontal
                            }
                        }
                        
                        // 仅处理纵向手势
                        if gestureDirection == .vertical && !selectedCardIDs.isEmpty {
                            dragState = .dragging(translation: value.translation)
                        }
                    }
                    .onEnded { value in
                        // 仅当有选中牌且是纵向手势时才处理
                        if !selectedCardIDs.isEmpty && gestureDirection == .vertical {
                            let dx = abs(value.translation.width)
                            let dy = value.translation.height
                            let predictedDy = value.predictedEndTranslation.height
                            
                            // 上滑出牌判定（严格）
                            if dy <= -80 && dx <= 60 && predictedDy <= -120 {
                                // 触发出牌
                                onCardTapped("__PLAY__")
                            }
                            // 下滑取消选择
                            else if dy >= 60 {
                                // 清空选择
                                withAnimation {
                                    selectedCardIDs.removeAll()
                                }
                                HapticFeedback.light()
                            }
                        }
                        
                        // 重置状态
                        dragState = .idle
                        gestureDirection = .none
                    }
            )
        }
    }
}

