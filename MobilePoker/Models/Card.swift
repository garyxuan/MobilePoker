//
//  Card.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

struct Card: Identifiable, Codable, Hashable {
    let id: String
    let suit: Suit
    let rank: Rank
    
    init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
        self.id = "\(suit.rawValue)-\(rank.rawValue)"
    }
    
    static func createDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        return deck
    }
}

