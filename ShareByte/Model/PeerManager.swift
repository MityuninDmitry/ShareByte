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
    var userDelegate: UserDelegate?
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!

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

    
    
}

extension PeerManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(session) : \(peerID) : ")
        switch state {
        case .notConnected:
            print("Not connected \(peerID)")
            Task { @MainActor in
                self.userDelegate?.notConnectedPeer(peerID)
            }
        case .connecting:
            print("Connecting \(peerID)")
        case .connected:
            print("Connected \(peerID)")
            Task { @MainActor in
                self.userDelegate?.connectedPeer(peerID)
            }
        @unknown default:
            print("ERROR")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieve data")
        Task {
            self.userDelegate?.gotMessage(from: peerID, data: data)
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
        print("DID RECIEVE INVITATION FROM \(peerID)")
        if context != nil {
            Task {
                
                if self.userDelegate!.canAcceptInvitation(AppDecoder.dataToString(context!)) {
                    invitationHandler(true, self.session)
                    self.userDelegate?.peerAcceptInvitation(isAccepted: true, from: peerID)
                } else {
                    invitationHandler(false, self.session)
                    self.userDelegate?.peerAcceptInvitation(isAccepted: false, from: peerID)
                }
                
            }
        }
        else {
            Task {
                if self.userDelegate!.canAcceptInvitation() {
                    invitationHandler(true, self.session)
                    self.userDelegate?.peerAcceptInvitation(isAccepted: true, from: peerID)
                } else {
                    invitationHandler(false, self.session)
                    self.userDelegate?.peerAcceptInvitation(isAccepted: false, from: peerID)
                }
                
            }
        }
        
    }
}

extension PeerManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FOUND PEER \(peerID)")
        Task {
            self.userDelegate?.addFoundPeer(peerID)
        }
        
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("LOST PEER \(peerID)")
        Task {
            self.userDelegate?.lostPeer(peerID)
        }
    }
    
    
}
