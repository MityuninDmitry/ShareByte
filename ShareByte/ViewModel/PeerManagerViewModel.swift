//
//  PeerManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
import MultipeerConnectivity

class PeerManagerViewModel: NSObject, ObservableObject {
    var session: MCSession!
    var myPeerId = MCPeerID(displayName: UIDevice.current.name)
    @Published var foundPeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var user: User
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!

    private var serviceType = "share-byte"
    
    override init() {
        
        user = .init(name: "SOME NAME")
        
        session = .init(peer: myPeerId)
        serviceAdvertiser = .init(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = .init(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        
    }
    
    func invitePeer(_ peerId: MCPeerID) {
        if self.user.type == .viewer {
            
        } else {
            serviceBrowser.invitePeer(peerId, to: self.session, withContext: nil, timeout: 10)
            self.user.type = .presenter
        }
        
    }
    
    func removePeer(_ peerId: MCPeerID) {
        if let isFoundIndex = self.isFound(peerId) {
            foundPeers.remove(at: isFoundIndex)
        }
        
    }
    
    func disconnect() {
        session.disconnect()
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
        
        DispatchQueue.main.async {
            self.user.type = nil
            self.connectedPeers = []
            self.foundPeers = []
        }
        
    }
    
    func discover() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    func isConnected(_ peerId: MCPeerID) -> Int? {
        var index = 0
        for peer in connectedPeers {
            if peer == peerId {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func isFound(_ peerId: MCPeerID) -> Int? {
        var index = 0
        for peer in foundPeers {
            if peer == peerId {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func lostPeer(_ peerId: MCPeerID) {
        if let isFoundIndex = isFound(peerId) {
            DispatchQueue.main.async {
                self.foundPeers.remove(at: isFoundIndex)
            }
        }
        if let isConnectedIndex = isConnected(peerId) {
            DispatchQueue.main.async {
                self.connectedPeers.remove(at: isConnectedIndex)
            }
        }
        DispatchQueue.main.async {
            if self.user.type == .viewer {
                self.user.type = nil
            }
            if self.connectedPeers.isEmpty || self.connectedPeers.count == 0 {
                self.user.type = nil
            }
        }
    }
}

extension PeerManagerViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(session) : \(peerID) : ")
        switch state {
        case .notConnected:
            print("Not connected \(peerID)")
            self.lostPeer(peerID)
        case .connecting:
            print("Connectin \(peerID)")
        case .connected:
            print("Connected \(peerID)")
            DispatchQueue.main.async {
                self.connectedPeers.append(peerID)
                self.removePeer(peerID)
            }
        @unknown default:
            print("ERROR")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieve data")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Recieve stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("NOT SUPPORTED OPERATION")
    }
    
    
}

extension PeerManagerViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("DID RECIEVE INVITATION FROM \(peerID)")
        
        if self.user.type == nil {
            invitationHandler(true, self.session)
            self.user.type = .viewer
        } else {
            invitationHandler(false, self.session)
        }
    }
}

extension PeerManagerViewModel: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FOUND PEER \(peerID)")
        DispatchQueue.main.async {
            if self.isFound(peerID) == nil {
                self.foundPeers.append(peerID)
            }
            
        }
        
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("LOST PEER \(peerID)")
        self.lostPeer(peerID)
        
    }
    
    
}
