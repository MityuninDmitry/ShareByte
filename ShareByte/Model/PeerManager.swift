//
//  PeerManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/9/23.
//

import Foundation

import MultipeerConnectivity

class PeerManager: NSObject, ObservableObject {
    var session: MCSession!
    var myPeerId: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    var messageProcessor: MessageProcessorProtocol?

    private var serviceType = "share-byte"
    
    override init() {
        session = .init(peer: myPeerId)
        serviceAdvertiser = .init(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = .init(peer: myPeerId, serviceType: serviceType)
        
        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
    
    init(userName: String) {
        myPeerId = MCPeerID(displayName: userName)
        
        session = .init(peer: myPeerId)
        
        serviceAdvertiser = .init(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = .init(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }
   
    func invitePeer(_ peerId: MCPeerID) {
        serviceBrowser.invitePeer(peerId, to: self.session, withContext: nil, timeout: 10)
    }
    
    
    func disconnect() {
        session.disconnect()
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func discover() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        
    }

    func setMyPeerName(_ name: String) {
        myPeerId = MCPeerID(displayName: name)
    }
    
}

extension PeerManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(session) : \(peerID) : ")
        switch state {
        case .notConnected:
            print("Not connected \(peerID)")
            Task {
                // эмулируем, что получили сообщение о смене статуса
                if let messageData = Message(messageType: .notConnected).encode() {
                    await self.messageProcessor?.processResponse(from: peerID, with: messageData)
                }
                
            }
        case .connecting:
            print("Connecting \(peerID)")
        case .connected:
            print("Connected \(peerID)")
            Task {
                // эмулируем, что получили сообщение о смене статуса
                if let messageData = Message(messageType: .connected).encode() {
                   await self.messageProcessor?.processResponse(from: peerID, with: messageData)
                }
            }
        @unknown default:
            print("ERROR")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieve data")
        Task {
            await self.messageProcessor?.processResponse(from: peerID, with: data)
        }
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

extension PeerManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if context != nil {
            Task {
               await self.messageProcessor?.processResponse(from: peerID, with: context!, invitationHandler: invitationHandler)
            }
        }
    }
}

extension PeerManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FOUND PEER \(peerID)")
        Task {
            if let messageData = Message(messageType: .foundPeer).encode() {
               await self.messageProcessor?.processResponse(from: peerID, with: messageData)
            }
        }
        
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("LOST PEER \(peerID)")
        Task {
            if let messageData = Message(messageType: .lostPeer).encode() {
               await self.messageProcessor?.processResponse(from: peerID, with: messageData)
            }
        }
    }
    
    
}
