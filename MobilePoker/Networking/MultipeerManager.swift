//
//  MultipeerManager.swift
//  MobilePoker
//
//  Created by garyxuan on 2025/12/26.
//

import Foundation
import MultipeerConnectivity
import Combine
import UIKit

class MultipeerManager: NSObject, ObservableObject {
    static let serviceType = "mobilepoker"
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var isHost = false
    @Published var myPeerID: MCPeerID?
    
    private var session: MCSession?
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    var onReceiveAction: ((ClientAction, MCPeerID) -> Void)?
    var onReceiveEvent: ((ServerEvent) -> Void)?
    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?
    
    override init() {
        super.init()
        setupPeerID()
    }
    
    private func setupPeerID() {
        let displayName = UIDevice.current.name
        myPeerID = MCPeerID(displayName: displayName)
    }
    
    // MARK: - Host 功能
    func startHosting() {
        guard let peerID = myPeerID else { return }
        
        isHost = true
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: Self.serviceType)
        serviceAdvertiser?.delegate = self
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func stopHosting() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceAdvertiser = nil
        session?.delegate = nil
        session = nil
        isHost = false
    }
    
    // MARK: - Client 功能
    func startBrowsing() {
        guard let peerID = myPeerID else { return }
        
        isHost = false
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        serviceBrowser?.delegate = self
        serviceBrowser?.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        serviceBrowser?.stopBrowsingForPeers()
        serviceBrowser = nil
        session?.delegate = nil
        session = nil
    }
    
    // MARK: - 发送消息
    func sendAction(_ action: ClientAction) {
        guard let session = session, !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(action)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("发送 Action 失败: \(error)")
        }
    }
    
    func sendEvent(_ event: ServerEvent, to peer: MCPeerID? = nil) {
        guard let session = session else { return }
        
        let targetPeers = peer != nil ? [peer!] : session.connectedPeers
        
        do {
            let data = try JSONEncoder().encode(event)
            try session.send(data, toPeers: targetPeers, with: .reliable)
        } catch {
            print("发送 Event 失败: \(error)")
        }
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.onPeerConnected?(peerID)
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                self.onPeerDisconnected?(peerID)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if self.isHost {
                // Host 接收 ClientAction
                if let action = try? JSONDecoder().decode(ClientAction.self, from: data) {
                    self.onReceiveAction?(action, peerID)
                }
            } else {
                // Client 接收 ServerEvent
                if let event = try? JSONDecoder().decode(ServerEvent.self, from: data) {
                    self.onReceiveEvent?(event)
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // 不使用流
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // 不使用资源传输
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // 不使用资源传输
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 自动接受邀请（最多 3 人）
        if let session = session, session.connectedPeers.count < 2 {
            invitationHandler(true, session)
        } else {
            invitationHandler(false, nil)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // 处理 peer 丢失
    }
}

