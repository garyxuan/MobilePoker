//
//  MainView.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var store: GameStore
    
    var body: some View {
        Group {
            if let state = store.gameState, state.phase == .playing {
                HandView(store: store)
            } else {
                LobbyView(store: store)
            }
        }
    }
}

