//
//  MobilePokerApp.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

@main
struct MobilePokerApp: App {
    @StateObject private var multipeerManager = MultipeerManager()
    @StateObject private var gameStore: GameStore
    
    init() {
        let manager = MultipeerManager()
        _multipeerManager = StateObject(wrappedValue: manager)
        _gameStore = StateObject(wrappedValue: GameStore(multipeerManager: manager))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView(store: gameStore)
        }
    }
}
