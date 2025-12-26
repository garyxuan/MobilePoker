//
//  LobbyView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var store: GameStore
    @State private var showingRoleSelection = true
    
    var body: some View {
        NavigationView {
            Group {
                if showingRoleSelection {
                    roleSelectionView
                } else {
                    lobbyContentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "suit.spade.fill")
                            .font(.title3)
                        Text("MobilePoker")
                            .font(.headline)
                    }
                }
                
                // 返回/取消按钮（仅在等待状态时显示，游戏进行中不显示）
                if !showingRoleSelection, 
                   let state = store.gameState,
                   state.phase == .waiting {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            HapticFeedback.light()
                            if store.isHost {
                                store.stopHosting()
                            } else {
                                store.stopClient()
                            }
                            // 重置状态
                            store.gameState = nil
                            store.myPlayerID = nil
                            withAnimation {
                                showingRoleSelection = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("返回")
                            }
                            .font(.body)
                        }
                    }
                } else if !showingRoleSelection, store.gameState == nil {
                    // 搜索/等待连接时显示取消按钮
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            HapticFeedback.light()
                            if store.isHost {
                                store.stopHosting()
                            } else {
                                store.stopClient()
                            }
                            // 重置状态
                            store.gameState = nil
                            store.myPlayerID = nil
                            withAnimation {
                                showingRoleSelection = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                Text("取消")
                            }
                            .font(.body)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var roleSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                    .symbolRenderingMode(.hierarchical)
                
                Text("选择角色")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("创建牌桌或加入已有牌桌")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 40)
            
            VStack(spacing: 16) {
                // 创建牌桌按钮
                Button(action: {
                    HapticFeedback.medium()
                    store.becomeHost()
                    withAnimation {
                        showingRoleSelection = false
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("创建牌桌")
                                .font(.headline)
                            Text("作为 Host")
                                .font(.subheadline)
                                .opacity(0.8)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .opacity(0.6)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // 加入牌桌按钮
                Button(action: {
                    HapticFeedback.medium()
                    store.joinAsClient()
                    withAnimation {
                        showingRoleSelection = false
                    }
                }) {
                    HStack {
                        Image(systemName: "person.2.circle.fill")
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("加入牌桌")
                                .font(.headline)
                            Text("作为 Client")
                                .font(.subheadline)
                                .opacity(0.8)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .opacity(0.6)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGreen))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var lobbyContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let state = store.gameState {
                    // 玩家数量卡片
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("已加入")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(state.players.count) / 3 人")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        
                        Divider()
                        
                        // 玩家列表
                        VStack(spacing: 12) {
                            ForEach(state.players) { player in
                                HStack {
                                    Image(systemName: player.id == store.myPlayerID ? "person.circle.fill" : "person.circle")
                                        .font(.title3)
                                        .foregroundColor(player.id == store.myPlayerID ? .accentColor : .secondary)
                                    
                                    Text(player.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if player.id == state.hostID {
                                        Label("Host", systemImage: "crown.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if player.id == store.myPlayerID {
                                        Text("我")
                                            .font(.caption)
                                            .foregroundColor(.accentColor)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.accentColor.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                }
                                .padding(.vertical, 4)
                                
                                if player.id != state.players.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    // 操作区域
                    if store.isHost {
                        if state.phase == .waiting {
                            Button(action: {
                                HapticFeedback.medium()
                                store.requestDeal(cardsPerPlayer: 5)
                            }) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                    Text("开始发牌")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(state.players.count >= 2 ? Color.accentColor : Color(.systemGray3))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .disabled(state.players.count < 2)
                            .padding(.horizontal)
                        } else {
                            statusCard(
                                icon: "gamecontroller.fill",
                                title: "游戏进行中",
                                subtitle: "请查看手牌"
                            )
                        }
                    } else {
                        if state.phase == .waiting {
                            statusCard(
                                icon: "clock.fill",
                                title: "等待 Host 发牌",
                                subtitle: "请耐心等待"
                            )
                        } else {
                            statusCard(
                                icon: "gamecontroller.fill",
                                title: "游戏进行中",
                                subtitle: "请查看手牌"
                            )
                        }
                    }
                } else {
                    // 空状态 - 等待连接
                    VStack(spacing: 24) {
                        if store.isHost {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            VStack(spacing: 8) {
                                Text("等待其他玩家加入...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("其他玩家可以通过「加入牌桌」连接到你的牌桌")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            VStack(spacing: 8) {
                                Text("正在搜索牌桌...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("请确保附近有设备创建了牌桌")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        // 取消按钮
                        Button(action: {
                            HapticFeedback.light()
                            if store.isHost {
                                store.stopHosting()
                            } else {
                                store.stopClient()
                            }
                            // 重置状态
                            store.gameState = nil
                            store.myPlayerID = nil
                            withAnimation {
                                showingRoleSelection = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("取消")
                            }
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(40)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func statusCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }
}

