//
//  GameStore.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation
import Combine
import MultipeerConnectivity

class GameStore: ObservableObject {
    @Published var gameState: GameStateSnapshot?
    @Published var myPlayerID: String?
    @Published var isHost: Bool = false
    
    private let multipeerManager: MultipeerManager
    private var hostEngine: HostEngine?
    private var cancellables = Set<AnyCancellable>()
    
    init(multipeerManager: MultipeerManager) {
        self.multipeerManager = multipeerManager
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        multipeerManager.onReceiveEvent = { [weak self] event in
            self?.handleEvent(event)
        }
        
        multipeerManager.$isHost
            .assign(to: &$isHost)
    }
    
    private func handleEvent(_ event: ServerEvent) {
        switch event {
        case .stateSnapshot(let snapshot):
            DispatchQueue.main.async {
                self.gameState = snapshot
            }
        case .error(let message):
            print("收到错误: \(message)")
        }
    }
    
    // MARK: - Host 操作
    func becomeHost() {
        guard let myPeerID = multipeerManager.myPeerID else { return }
        
        let hostPlayer = Player(
            id: UUID().uuidString,
            name: myPeerID.displayName,
            deviceID: myPeerID.displayName
        )
        
        hostEngine = HostEngine(
            hostID: hostPlayer.id,
            hostPlayer: hostPlayer,
            multipeerManager: multipeerManager
        )
        
        myPlayerID = hostPlayer.id
        
        hostEngine?.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                if let myID = self?.myPlayerID {
                    self?.gameState = state.snapshot(for: myID)
                }
            }
        }
        
        multipeerManager.startHosting()
        
        // 立即更新 Host 自己的状态
        if let engine = hostEngine {
            let initialState = engine.gameState
            DispatchQueue.main.async {
                self.gameState = initialState.snapshot(for: hostPlayer.id)
            }
        }
    }
    
    func stopHosting() {
        hostEngine = nil
        multipeerManager.stopHosting()
    }
    
    // MARK: - Client 操作
    func joinAsClient() {
        guard let myPeerID = multipeerManager.myPeerID else { return }
        
        let player = Player(
            id: UUID().uuidString,
            name: myPeerID.displayName,
            deviceID: myPeerID.displayName
        )
        
        myPlayerID = player.id
        let savedPlayer = player
        
        // 等待连接后发送 joinTable
        multipeerManager.onPeerConnected = { [weak self] _ in
            guard let self = self else { return }
            // 延迟一下确保连接稳定
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.multipeerManager.sendAction(.joinTable(player: savedPlayer))
            }
        }
        
        multipeerManager.startBrowsing()
    }
    
    func stopClient() {
        multipeerManager.stopBrowsing()
    }
    
    // MARK: - 游戏操作
    func requestDeal(cardsPerPlayer: Int = 5) {
        if isHost {
            hostEngine?.handleAction(.requestDeal(cardsPerPlayer: cardsPerPlayer), from: multipeerManager.myPeerID!)
        } else {
            multipeerManager.sendAction(.requestDeal(cardsPerPlayer: cardsPerPlayer))
        }
    }
    
    func playCards(_ cardIDs: [String]) {
        guard let playerID = myPlayerID else { return }
        
        if isHost {
            hostEngine?.handleAction(.playCards(playerID: playerID, cardIDs: cardIDs), from: multipeerManager.myPeerID!)
        } else {
            multipeerManager.sendAction(.playCards(playerID: playerID, cardIDs: cardIDs))
        }
    }
    
    func resetGame() {
        hostEngine?.resetGame()
    }
    
    // MARK: - 获取数据
    var myHand: [Card] {
        guard let playerID = myPlayerID,
              let state = gameState,
              let hand = state.hands[playerID] else {
            return []
        }
        return hand
    }
    
    var connectedPlayersCount: Int {
        gameState?.players.count ?? 0
    }
}

