//
//  User.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
import MultipeerConnectivity



protocol UserDelegate {
    func notConnectedPeer(_ peerID: MCPeerID)
    func lostPeer(_ peerID: MCPeerID)
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID)
    func canAcceptInvitation() -> Bool
    func gotMessage(from: MCPeerID, data: Data)
    func addFoundPeer(_ peerID: MCPeerID)
    func connectedPeer(_ peerID: MCPeerID)
}

struct UserInfo: Identifiable, Hashable, Codable {
    var id: UUID? = nil
    var name: String? = nil
    var type: UserType?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
    }
}

struct Message: Codable {
    enum MessageType: Codable {
        case askInfo
        case userInfo
        case reconnect
    }
    
    var messageType: MessageType = .askInfo
    var message: String? = nil
    var userInfo: UserInfo? = nil
}

enum DiscoverableStatus: String {
    case stopped = "STOPPED"
    case running = "RUNNING"
}

class UserViewModel: ObservableObject {
    
    static var shared = UserViewModel()
    
    @Published var foundUsers: [MCPeerID: UserInfo] = .init()
    @Published var connectedUsers: [MCPeerID: UserInfo] = .init()
    @Published var userInfo: UserInfo // инфа о пользователе
    @Published var disoverableStatus: DiscoverableStatus = .stopped
    
    var peerManager: PeerManager = .init() // менеджер управления соединением
    private let encoder = PropertyListEncoder() // для энкодинга сообщений
    private let decoder = PropertyListDecoder() // для декодинга сообщений
    
    private init(name: String) {
        self.userInfo = .init(id: UUID(), name: UIDevice.current.name, type: nil)
        peerManager.userDelegate = self
        
    }
    
    private init() {
        self.userInfo = .init(id: UUID(), name: UIDevice.current.name, type: nil)
        peerManager.userDelegate = self
        
    }
    
    func updateUserName(_ name: String) {
        self.userInfo.name = name
        self.sendUserInfoTo(peers: self.peerManager.session.connectedPeers)
    }
    /// Есть ли в переданном массиве объект с таким peerID
    /// Если есть. то возращает индекс. Иначе возращает нул.
    static func hasIn(dict: [MCPeerID: UserInfo], peerID: MCPeerID) -> Bool {
        if dict[peerID] != nil {
            return true
        }
        return false
    }
    
    func reconnect() {
        DispatchQueue.main.async {
            self.disconnectAndStopDiscover()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.makeDiscoverable()
            }
        }
    }
    
    func disconnectAndStopDiscover() {
        print("[disconnectAndStopDiscover]")
        self.updateUserType(nil)
        self.connectedUsers = .init()
        self.foundUsers = .init()
        peerManager.disconnect()
        self.disoverableStatus = .stopped
        
    }
    
    func makeDiscoverable() {
        print("[makeDiscoverable]")
        self.peerManager.discover()
        self.disoverableStatus = .running
    }
    
    // шлем приглашение пользователю
    func inviteUser(_ peerId: MCPeerID) {
        if self.userInfo.type != .viewer {
            self.peerManager.serviceBrowser.invitePeer(peerId, to: peerManager.session, withContext: nil, timeout: 10)
        }
    }
    
    /// добавить peerID
    func addToConnectedPeer(_ peerID: MCPeerID) -> UserInfo? {
        // если пир есть в списке найденных(но еще не подключенных) пользователей, то
        if UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
            let user = self.foundUsers.removeValue(forKey: peerID) // удаляем его из этого списка найденных и
            // если нет пользователя в списке подключенных пользователей, то
            if !UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerID) {
                self.connectedUsers[peerID] = user
                return user
            }
        }
        return nil
    }
    
    ///  Отправить сообщение пиру
    func sendMessageTo(peers: [MCPeerID], message: Message) {
        do {
            if let data = try? self.encoder.encode(message) {
                try self.peerManager.session.send(data, toPeers: peers, with: .reliable)
            }
        } catch {
            print("Error for sending: \(String(describing: error))")
        }
    }
    
    func sendUserInfoTo(peers: [MCPeerID]) {
        if peers.count > 0 {
            let message = Message(messageType: .userInfo, userInfo: self.userInfo)
            self.sendMessageTo(peers: peers, message: message)
        }
    }
    
    func sendReconnectTo(peers: [MCPeerID]) {
        let message = Message(messageType: .reconnect)
        self.sendMessageTo(peers: peers, message: message)
    }
    
    func printSessionConnectedPeersInfo() {
        for peer in self.peerManager.session.connectedPeers {
            print(connectedUsers[peer] ?? "")
        }
    }
    
    /// апдейтим инфу о пользователе
    func updateConnectedUserInfo(for peerId: MCPeerID, userInfo: UserInfo) {
        if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerId) {
            self.connectedUsers[peerId] = .init()
            self.connectedUsers[peerId]!.name = userInfo.name
            self.connectedUsers[peerId]!.id = userInfo.id
            self.connectedUsers[peerId]!.type = userInfo.type
        }
    }
    
    func updateUserType(_ userType: UserType?) {
        self.userInfo.type = userType
    }
    
    /// Запрашиваем информацию о пользователе
    func askUserInfo(_ peerId: MCPeerID) {
        if self.connectedUsers[peerId]!.id == nil {
            let newMessage = Message(messageType: .askInfo)
            sendMessageTo(peers: [peerId], message: newMessage)
        }
    }
}


extension UserViewModel: UserDelegate {
    
    /// инициализация пользователя с таким-то peerID и добавление этого пользователя в список найденных пользователей
    func addFoundPeer(_ peerID: MCPeerID) {
        print("[addFoundPeer] \(peerID)")
        DispatchQueue.main.async {
            if !UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
                let user: UserInfo = .init()
                self.foundUsers[peerID] = user
            }
        }
    }
    
    /// подключился пир
    /// перемещаем его в список(кастомный) подключенных пользователей и запрашиваем инфу
    func connectedPeer(_ peerID: MCPeerID) {
        let user = self.addToConnectedPeer(peerID)
        if user != nil {
            self.askUserInfo(peerID)
        }
        
    }
        
    /// Получить сообщение от пира
    func gotMessage(from peer: MCPeerID, data: Data) {
        if let message = try? decoder.decode(Message.self, from: data) {
            DispatchQueue.main.async {
                switch message.messageType {
                case .askInfo: // если пир запросил инфо обо мне, то предоставить эту инфу
                    self.sendUserInfoTo(peers: [peer])
                case .userInfo: // получили инфу от пользователя
                    let userInfo = message.userInfo!
                    self.updateConnectedUserInfo(for: peer, userInfo: userInfo)
                    
                    if self.userInfo.type == nil { // если мой тип пустой, то
                        if let safeGottenUserType = userInfo.type {
                            if safeGottenUserType == .viewer { // если он вьюер, то я презентер
                                self.updateUserType(.presenter)
                                self.sendUserInfoTo(peers: [peer])
                            }
                        }
                    }
                case .reconnect:
                    self.reconnect()
                }
            }
        }
    }
    
    
    
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID) {
        if isAccepted {
            self.updateUserType(.viewer)
            self.sendUserInfoTo(peers: [peerID])
        }
    }
    
    func canAcceptInvitation() -> Bool {
        if self.userInfo.type == nil {
            return true
        }
        return false
    }
    
    func lostPeer(_ peerID: MCPeerID) {
        print("[lostPeer] \(peerID)")
        if UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
            self.foundUsers.removeValue(forKey: peerID)
        }
        notConnectedPeer(peerID)
    }
    
    func notConnectedPeer(_ peerID: MCPeerID) {
        print("[notConnectedPeer] \(peerID)")
        if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerID) {
            let user = self.connectedUsers.removeValue(forKey: peerID)
            if let disconnectedUser = user {
                if disconnectedUser.type == .presenter {
                    self.disconnectAndStopDiscover()
                    self.makeDiscoverable()
                }
            }
        }
    }
}
