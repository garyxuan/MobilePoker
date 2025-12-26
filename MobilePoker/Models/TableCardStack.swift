//
//  TableCardStack.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

struct TableCardStack: Identifiable, Codable {
    let id: String
    let playerID: String
    let cards: [Card]
    let timestamp: Date
    
    init(playerID: String, cards: [Card]) {
        self.id = UUID().uuidString
        self.playerID = playerID
        self.cards = cards
        self.timestamp = Date()
    }
}

