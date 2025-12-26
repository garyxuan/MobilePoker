//
//  Suit.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

enum Suit: String, Codable, CaseIterable {
    case spades = "spades"
    case hearts = "hearts"
    case diamonds = "diamonds"
    case clubs = "clubs"
    
    var displayName: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        }
    }
}

