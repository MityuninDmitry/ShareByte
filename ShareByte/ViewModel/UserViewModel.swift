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
    func connectedPeer(_ peerID: MCPeerID)
    func askUserInfo(_ peerId: MCPeerID)
    func gotMessage(from: MCPeerID, data: Data)
    func updateUserType(_ userType: UserType)
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID)
    func canAcceptInvitation() -> Bool
    func disconnectPeer(_ peerID: MCPeerID)
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
    }
    
    var messageType: MessageType = .askInfo
    var message: String? = nil
    
    var userInfo: UserInfo? = nil
}

class UserViewModel: ObservableObject, UserDelegate {

    
    static var shared = UserViewModel()
    
    @Published var foundUsers: [MCPeerID: UserInfo] = .init()
    @Published var connectedUsers: [MCPeerID: UserInfo] = .init()
    @Published var userInfo: UserInfo // инфа о пользователе
    
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
    
    /// Есть ли в переданном массиве объект с таким peerID
    /// Если есть. то возращает индекс. Иначе возращает нул.
    static func hasIn(dict: [MCPeerID: UserInfo], peerID: MCPeerID) -> Bool {
        if dict[peerID] != nil {
            return true
        }
        return false
    }
    
    
    func disconnectAndStopDiscover() {
        peerManager.disconnect()
    }
    
    func makeDiscoverable() {
        peerManager.discover()
    }
    
    // шлем приглашение пользователю
    func inviteUser(_ peerId: MCPeerID) {
        if self.userInfo.type != .viewer {
            self.peerManager.serviceBrowser.invitePeer(peerId, to: peerManager.session, withContext: nil, timeout: 10)
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
    
    /// инициализация пользователя с таким-то peerID и добавление этого пользователя в список найденных пользователей
    func addFoundPeer(_ peerID: MCPeerID) {
        DispatchQueue.main.async {
            if !UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
                let user: UserInfo = .init()
                self.foundUsers[peerID] = user
            }
        }
        
        
    }
    
   
    
    /// Запрашиваем информацию о пользователе
    func askUserInfo(_ peerId: MCPeerID) {
        if self.connectedUsers[peerId]!.id == nil {
            let newMessage = Message(messageType: .askInfo)
            sendMessageTo(peer: peerId, message: newMessage)
        }
    }
    ///  Отправить сообщение пиру
    func sendMessageTo(peer: MCPeerID, message: Message) {
        do {
            if let data = try? self.encoder.encode(message) {
                try self.peerManager.session.send(data, toPeers: [peer], with: .reliable)
            }
        } catch {
            print("Error for sending: \(String(describing: error))")
        }
    }
    
    /// Получить сообщение от пира
    func gotMessage(from peer: MCPeerID, data: Data) {
        if let message = try? decoder.decode(Message.self, from: data) {
            DispatchQueue.main.async {
                switch message.messageType {
                case .askInfo: // если пир запросил инфо обо мне, то предоставить эту инфу
                    let newMessage = Message(messageType: .userInfo, userInfo: self.userInfo)
                    self.sendMessageTo(peer: peer, message: newMessage)
                case .userInfo: // получили инфу от пользователя
                    let userInfo = message.userInfo!
                    self.updateConnectedUserInfo(for: peer, userInfo: userInfo)
                    
                    if self.userInfo.type == nil { // если мой тип пустой, то
                        if let safeGottenUserType = userInfo.type {
                            if safeGottenUserType == .viewer { // если он вьюер, то я презентер
                                self.userInfo.type = .presenter
                            }
                        }
                    }
                    
                }
            }
        }
    }
    /// апдейтим инфу о пользователе
    func updateConnectedUserInfo(for peerId: MCPeerID, userInfo: UserInfo) {
        if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerId) {
            self.connectedUsers[peerId]!.name = userInfo.name
            self.connectedUsers[peerId]!.id = userInfo.id
        }
    }
    
    func updateUserType(_ userType: UserType) {
        self.userInfo.type = userType
    }
    
    func peerAcceptInvitation(isAccepted: Bool, from peerID: MCPeerID) {
        if isAccepted {
            self.userInfo.type = .viewer
        }
    }
    
    func canAcceptInvitation() -> Bool {
        if self.userInfo.type == nil {
            return true
        }
        return false 
    }
    
    func disconnectPeer(_ peerID: MCPeerID) {
        
    }
}
