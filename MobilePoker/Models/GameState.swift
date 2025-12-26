//
//  GameState.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

struct GameState: Codable {
    var players: [Player]
    var hostID: String
    var deck: [Card]
    var hands: [String: [Card]] // playerID: [Card]
    var table: [TableCardStack]
    var currentTurnPlayerID: String?
    var phase: Phase
    var revision: Int
    
    init(hostID: String, hostPlayer: Player) {
        self.players = [hostPlayer]
        self.hostID = hostID
        self.deck = Card.createDeck().shuffled()
        self.hands = [:]
        self.table = []
        self.currentTurnPlayerID = nil
        self.phase = .waiting
        self.revision = 0
    }
    
    // 创建裁剪版 GameState（用于发送给客户端）
    func snapshot(for playerID: String?) -> GameStateSnapshot {
        var visibleHands: [String: [Card]] = [:]
        if let playerID = playerID {
            visibleHands[playerID] = hands[playerID] ?? []
        }
        
        return GameStateSnapshot(
            players: players,
            hostID: hostID,
            hands: visibleHands,
            table: table,
            currentTurnPlayerID: currentTurnPlayerID,
            phase: phase,
            revision: revision
        )
    }
}

// 裁剪版的 GameState，用于网络传输
struct GameStateSnapshot: Codable {
    let players: [Player]
    let hostID: String
    let hands: [String: [Card]] // 只包含接收者自己的手牌
    let table: [TableCardStack]
    let currentTurnPlayerID: String?
    let phase: Phase
    let revision: Int
}

