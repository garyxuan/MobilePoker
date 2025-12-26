//
//  HostEngine.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation
import Combine
import MultipeerConnectivity

class HostEngine: ObservableObject {
    @Published private(set) var gameState: GameState
    private let multipeerManager: MultipeerManager
    
    var onStateChanged: ((GameState) -> Void)?
    
    init(hostID: String, hostPlayer: Player, multipeerManager: MultipeerManager) {
        self.gameState = GameState(hostID: hostID, hostPlayer: hostPlayer)
        self.multipeerManager = multipeerManager
        
        setupMultipeerCallbacks()
    }
    
    private func setupMultipeerCallbacks() {
        multipeerManager.onReceiveAction = { [weak self] action, peerID in
            self?.handleAction(action, from: peerID)
        }
    }
    
    // MARK: - 处理 Action
    func handleAction(_ action: ClientAction, from peerID: MCPeerID) {
        switch action {
        case .joinTable(let player):
            handleJoinTable(player: player, peerID: peerID)
        case .requestDeal(let cardsPerPlayer):
            handleRequestDeal(cardsPerPlayer: cardsPerPlayer)
        case .playCards(let playerID, let cardIDs):
            handlePlayCards(playerID: playerID, cardIDs: cardIDs)
        case .requestResync(let lastKnownRevision):
            handleRequestResync(lastKnownRevision: lastKnownRevision, peerID: peerID)
        }
    }
    
    private func handleJoinTable(player: Player, peerID: MCPeerID) {
        // 检查是否已存在
        if gameState.players.contains(where: { $0.id == player.id }) {
            return
        }
        
        // 最多 3 人
        if gameState.players.count >= 3 {
            multipeerManager.sendEvent(.error(message: "牌桌已满"), to: peerID)
            return
        }
        
        gameState.players.append(player)
        gameState.revision += 1
        broadcastState()
    }
    
    private func handleRequestDeal(cardsPerPlayer: Int) {
        guard gameState.phase == .waiting else { return }
        guard gameState.players.count >= 2 else { return }
        
        gameState.phase = .dealing
        gameState.deck = Card.createDeck().shuffled()
        gameState.hands = [:]
        gameState.table = []
        
        // 发牌给每个玩家
        for player in gameState.players {
            var playerHand: [Card] = []
            for _ in 0..<cardsPerPlayer {
                if let card = gameState.deck.popLast() {
                    playerHand.append(card)
                }
            }
            gameState.hands[player.id] = playerHand
        }
        
        gameState.phase = .playing
        gameState.currentTurnPlayerID = gameState.players.first?.id
        gameState.revision += 1
        broadcastState()
    }
    
    private func handlePlayCards(playerID: String, cardIDs: [String]) {
        guard gameState.phase == .playing else { return }
        guard let playerHand = gameState.hands[playerID] else { return }
        
        // 验证牌是否在玩家手牌中
        let cardsToPlay = playerHand.filter { cardIDs.contains($0.id) }
        guard cardsToPlay.count == cardIDs.count else {
            // 牌不存在或重复，忽略
            return
        }
        
        // 从手牌中移除
        gameState.hands[playerID] = playerHand.filter { !cardIDs.contains($0.id) }
        
        // 添加到桌面
        let stack = TableCardStack(playerID: playerID, cards: cardsToPlay)
        gameState.table.append(stack)
        
        // 更新回合（简单轮转）
        if let currentIndex = gameState.players.firstIndex(where: { $0.id == gameState.currentTurnPlayerID }) {
            let nextIndex = (currentIndex + 1) % gameState.players.count
            gameState.currentTurnPlayerID = gameState.players[nextIndex].id
        }
        
        gameState.revision += 1
        broadcastState()
    }
    
    private func handleRequestResync(lastKnownRevision: Int, peerID: MCPeerID) {
        // 如果客户端版本落后，发送最新状态
        if gameState.revision > lastKnownRevision {
            // 根据 peerID 找到对应的 playerID
            if let player = gameState.players.first(where: { $0.name == peerID.displayName }) {
                let snapshot = gameState.snapshot(for: player.id)
                multipeerManager.sendEvent(.stateSnapshot(snapshot), to: peerID)
            }
        }
    }
    
    // MARK: - 广播状态
    private func broadcastState() {
        // 给每个玩家发送裁剪后的状态
        for player in gameState.players {
            let snapshot = gameState.snapshot(for: player.id)
            
            if player.id == gameState.hostID {
                // Host 自己通过 onStateChanged 更新
                onStateChanged?(gameState)
            } else {
                // 找到对应的 MCPeerID 并发送
                if let peerID = multipeerManager.connectedPeers.first(where: { $0.displayName == player.name }) {
                    multipeerManager.sendEvent(.stateSnapshot(snapshot), to: peerID)
                }
            }
        }
    }
    
    // 重置游戏
    func resetGame() {
        let hostPlayer = gameState.players.first { $0.id == gameState.hostID }!
        gameState = GameState(hostID: gameState.hostID, hostPlayer: hostPlayer)
        gameState.players = gameState.players // 保留所有玩家
        broadcastState()
    }
}

