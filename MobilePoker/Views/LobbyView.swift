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
        VStack(spacing: 32) {
            Text("MobilePoker")
                .font(.largeTitle)
                .fontWeight(.light)
            
            if showingRoleSelection {
                roleSelectionView
            } else {
                lobbyContentView
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.98))
    }
    
    private var roleSelectionView: some View {
        VStack(spacing: 24) {
            Text("选择角色")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                store.becomeHost()
                showingRoleSelection = false
            }) {
                VStack(spacing: 8) {
                    Text("创建牌桌")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("作为 Host")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            Button(action: {
                store.joinAsClient()
                showingRoleSelection = false
            }) {
                VStack(spacing: 8) {
                    Text("加入牌桌")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("作为 Client")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private var lobbyContentView: some View {
        VStack(spacing: 24) {
            if let state = store.gameState {
                VStack(spacing: 16) {
                    Text("已加入 \(state.players.count) / 3 人")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    // 玩家列表
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(state.players) { player in
                            HStack {
                                Circle()
                                    .fill(player.id == store.myPlayerID ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text(player.name)
                                    .font(.body)
                                if player.id == state.hostID {
                                    Text("(Host)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
                
                if store.isHost {
                    if state.phase == .waiting {
                        Button(action: {
                            store.requestDeal(cardsPerPlayer: 5)
                        }) {
                            Text("开始发牌")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(state.players.count >= 2 ? Color.blue : Color.gray)
                                .cornerRadius(8)
                        }
                        .disabled(state.players.count < 2)
                    } else {
                        Text("游戏进行中")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    if state.phase == .waiting {
                        Text("等待 Host 发牌")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("游戏进行中")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                if store.isHost {
                    Text("等待其他玩家加入...")
                        .foregroundColor(.secondary)
                } else {
                    Text("正在搜索牌桌...")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

