//
//  Player.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let deviceID: String
    
    init(id: String, name: String, deviceID: String) {
        self.id = id
        self.name = name
        self.deviceID = deviceID
    }
}

