//
//  MessageTypes.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

// MARK: - ClientAction (客户端发送给 Host)
enum ClientAction: Codable {
    case joinTable(player: Player)
    case requestDeal(cardsPerPlayer: Int)
    case playCards(playerID: String, cardIDs: [String])
    case requestResync(lastKnownRevision: Int)
}

// MARK: - ServerEvent (Host 发送给客户端)
enum ServerEvent: Codable {
    case stateSnapshot(GameStateSnapshot)
    case error(message: String)
}

