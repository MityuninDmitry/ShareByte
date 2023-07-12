//
//  User.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
import MultipeerConnectivity


protocol UserDelegate {
    func addFoundPeer(_ peerID: MCPeerID)
    func addToConnectedPeer(_ peerID: MCPeerID) -> UserInfo?
    func askUserInfo(_ userInfo: UserInfo)
    func gotMessage(from: MCPeerID, data: Data)
    func connectedPeer(_ peerID: MCPeerID)
    func updateUserType(_ userType: UserType)
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID)
    func canAcceptInvitation() -> Bool
    func disconnectPeer(_ peerID: MCPeerID)
}

struct UserInfo: Identifiable, Hashable {
    var id: UUID? = nil
    var name: String? = nil
    var mcPeerId: MCPeerID
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mcPeerId
    }
    
    enum AdditionalInfoKeys: String, CodingKey {
        case mcPeerId
    }
}

struct Message: Codable {
    enum MessageType: Codable {
        case askInfo
        case userInfo
    }
    
    var messageType: MessageType = .askInfo
    var message: String? = nil
    var userName: String? = nil
    var userId: UUID? = nil
    var userType: UserType? = nil
}

class UserViewModel: ObservableObject, Identifiable, UserDelegate {
    
    
    
    static var shared = UserViewModel()
    
    @Published var type: UserType? = nil
    @Published var foundUsers: [UserInfo] = .init()
    @Published var connectedUsers: [UserInfo] = .init()
    
    
   var id: UUID = UUID()
    var peerManager: PeerManager = .init()
    var userInfo: UserInfo
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    private init(name: String) {
        
        self.userInfo = .init(id: UUID(), name: UIDevice.current.name, mcPeerId: self.peerManager.myPeerId)
        peerManager.userDelegate = self
    }
    
    private init() {
        self.userInfo = .init(id: UUID(), name: UIDevice.current.name, mcPeerId: self.peerManager.myPeerId)
        peerManager.userDelegate = self
    }
    
    static func hasIn(array: [UserInfo], peerID: MCPeerID) -> Int? {
        var index = 0
        for item in array {
            if item.mcPeerId == peerID {
                return index
            }
            index += 1
        }
        
        return nil
    }
    
    func disconnectAndStopDiscover() {
        peerManager.disconnect()
    }
    
    func makeDiscoverable() {
        peerManager.discover()
    }
    
    func inviteUser(_ user: UserInfo) {
        if self.type != .viewer {
            self.peerManager.serviceBrowser.invitePeer(user.mcPeerId, to: peerManager.session, withContext: nil, timeout: 10)
        }
    }
    
    func connectedPeer(_ peerID: MCPeerID) {
        let user = self.addToConnectedPeer(peerID)
        if user != nil {
            self.askUserInfo(user!)
        }
        
    }
    
    func addFoundPeer(_ peerID: MCPeerID) {
        
        let user: UserInfo = .init(mcPeerId: peerID)
        DispatchQueue.main.async {
            if !self.foundUsers.contains([user]) {
                self.foundUsers.append(user)
            }
        }
        
        
    }
    func addToConnectedPeer(_ peerID: MCPeerID) -> UserInfo? {
        
            if let index = UserViewModel.hasIn(array: self.foundUsers, peerID: peerID) {
                
                let user = foundUsers.remove(at: index)
                if UserViewModel.hasIn(array: self.connectedUsers, peerID: user.mcPeerId) == nil {
                    self.connectedUsers.append(user)
                    return user
                }
            }
            return nil
        
        
        
    }
    
    func askUserInfo(_ userInfo: UserInfo) {
        if userInfo.id == nil {
            let newMessage = Message(messageType: .askInfo)
            sendMessageTo(peer: userInfo.mcPeerId, message: newMessage)
        }
    }
    func sendMessageTo(peer: MCPeerID, message: Message) {
        do {
            if let data = try? self.encoder.encode(message) {
                try self.peerManager.session.send(data, toPeers: [peer], with: .reliable)
            }
        } catch {
            print("Error for sending: \(String(describing: error))")
        }
    }
    func gotMessage(from peer: MCPeerID, data: Data) {
        if let message = try? decoder.decode(Message.self, from: data) {
            DispatchQueue.main.async {
                switch message.messageType {
                case .askInfo:
                    let newMessage = Message(messageType: .userInfo, userName: self.userInfo.name, userId: self.userInfo.id, userType: self.type)
                    self.sendMessageTo(peer: peer, message: newMessage)
                case .userInfo:
                    let userName = message.userName!
                    let userId = message.userId!
                    self.updateConnectedUserInfo(for: peer, userName: userName, userId: userId)
                    
                    if self.type == nil {
                        if let safeGottenUserType = message.userType {
                            if safeGottenUserType == .viewer {
                                self.type = .presenter
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func updateConnectedUserInfo(for peerId: MCPeerID, userName: String, userId: UUID) {
        if let index = UserViewModel.hasIn(array: connectedUsers, peerID: peerId) {
            self.connectedUsers[index].name = userName
            self.connectedUsers[index].id = userId
        }
    }
    
    func updateUserType(_ userType: UserType) {
        self.type = userType
    }
    
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID) {
        if isAccepted {
            self.type = .viewer
        }
    }
    
    func canAcceptInvitation() -> Bool {
        if self.type == nil {
            return true
        }
        return false 
    }
    
    func disconnectPeer(_ peerID: MCPeerID) {
        
    }
}
