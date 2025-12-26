//
//  Phase.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

enum Phase: String, Codable {
    case waiting = "waiting"
    case dealing = "dealing"
    case playing = "playing"
    case finished = "finished"
}

