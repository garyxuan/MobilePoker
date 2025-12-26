//
//  HandHintBar.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct HandHintBar: View {
    let selectedCount: Int
    
    var body: some View {
        Text(selectedCount == 0 ? "点选牌，上滑出牌" : "上滑出牌 · 下滑取消（\(selectedCount)）")
            .font(.system(.caption, design: .default))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        HandHintBar(selectedCount: 0)
        HandHintBar(selectedCount: 3)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

