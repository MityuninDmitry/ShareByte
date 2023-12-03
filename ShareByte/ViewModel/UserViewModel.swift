//
//  User.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
import MultipeerConnectivity

class UserViewModel: ObservableObject {
    static var shared = UserViewModel()
    
    @Published var foundUsers: [MCPeerID: User] = .init()
    @Published var connectedUsers: [MCPeerID: User] = .init()
    @Published var user: User // инфа о пользователе
    @Published var presentation: Presentation = .init()
    @Published var disoverableStatus: DiscoverableStatus = .stopped
    var messageProcessor: MessageProcessor?
    
    private init() {
        self.user = .init()
        self.user.load() // загружаем пользователя из БД, если он есть
        
        messageProcessor = .init(businessProcessor: self, userName: user.name ?? "NO_NAME")
        
        self.makeDiscoverable()
    }
    func appendImageToPresentation(_ data: Data) {
        self.presentation.appendImageData(data)
    }
    func saveUser() {
        self.user.save()
        self.messageProcessor?.sendRequestTo(peers: [], message: Message(messageType: .userInfo, userInfo: self.user))
    }
    /// Есть ли в переданном массиве объект с таким peerID
    /// Если есть. то возращает индекс. Иначе возращает нул.
    static func hasIn(dict: [MCPeerID: User], peerID: MCPeerID) -> Bool {
        if dict[peerID] != nil {
            return true
        }
        return false
    }
    
    /// Дисконнект, а через какое-то время коннект
    func reconnect() {
        Task { @MainActor in
            self.disconnectAndStopDiscover()
            try await Task.sleep(for: .seconds(1))
            self.makeDiscoverable()
        }
    }
    
    /// Отключиться и перестать искать других
    /// До отключения надо обнулиться
    
    func disconnectAndStopDiscover() {
        // прежде чем отключиться
        print("[disconnectAndStopDiscover]")
        self.updateUserRole(nil)
        self.connectedUsers = .init()
        self.foundUsers = .init()
        self.messageProcessor?.stopRecieveMessages()
        self.disoverableStatus = .stopped
        
    }
    
    func makeDiscoverable() {
        self.messageProcessor?.startRecieveMessages()
        self.disoverableStatus = .running
    }
    
    func inviteUser(_ peerId: MCPeerID) {
        if self.user.role != .viewer {
            self.messageProcessor?.sendRequestTo(peers: [peerId], message: Message.invitationMessage(presentationId: self.presentation.id))
        }
        
    }
    func sendPresentationtToAll() {
        self.messageProcessor?.sendRequestTo(peers: [], message: Message.presentationMessage(presentation: self.presentation))
    }
    func sendIndexToShow(_ index: Int) {
        self.messageProcessor?.sendRequestTo(peers: [], message: Message.indexToShowMessage(index: index))
    }
    func sendClearPresentation() {
        self.messageProcessor?.sendRequestTo(peers: [], message: Message.clearPresentationMessage())
    }
    func sendReconnectTo(peers: [MCPeerID]) {
        self.messageProcessor?.sendRequestTo(peers: peers, message: Message.reconnectMessage())
    }
    func sendReadyToStartPresentation(peers: [MCPeerID]) {
        self.messageProcessor?.sendRequestTo(peers: peers, message: Message.readyMessage())
    }
    
}


extension UserViewModel: BusinessProcessorProtocol {
    func processMessage(_ message: Message, from peer: MCPeerID) async -> Message? {
        let messageType = message.messageType
        print("GOT MESSAGE WITH TYPE: \(messageType)")
        switch messageType {
        case .foundPeer:
            // инициализация пользователя с таким-то peerID и добавление этого пользователя в список найденных пользователей
            Task { @MainActor in
                if !UserViewModel.hasIn(dict: self.foundUsers, peerID: peer) {
                    let user: User = .init()
                    self.foundUsers[peer] = user
                }
            }
            return nil
        case .invitation:
            let task = Task { @MainActor in
                if self.user.role == .presenter {
                    if self.presentation.id == message.presentationId! {
                        self.updateUserRole(.viewer)
                        return Message.acceptInvitation()
                    } else {
                        return Message.notAcceptInvitation()
                    }
                }
                else if self.user.role == nil {
                    self.updateUserRole(.viewer)
                    return Message.acceptInvitation()
                }
                
                return Message.notAcceptInvitation()
            }
            return await task.value
        case .connected:
            if await connectedPeer(peer) != nil {
                return Message.askInfoMessage()
            }
            return nil
        case .lostPeer:
            Task { @MainActor in
                lostPeer(peer)
            }
            return nil
        case .notConnected:
            Task { @MainActor in
                notConnectedPeer(peer)
            }
            return nil
        case .userInfo:
            let userInfo = message.userInfo!
            self.updateConnectedUserInfo(for: peer, user: userInfo)
            if self.user.role == nil { // если мой тип пустой, то
                if let safeGottenUserRole = userInfo.role {
                    if safeGottenUserRole == .viewer { // если он вьюер, то я презентер
                        self.updateUserRole(.presenter)
                        return Message.userInfoMessage(user: self.user)
                    }
                    else if safeGottenUserRole == .presenter {
                        self.updateUserRole(.viewer)
                        return Message.userInfoMessage(user: self.user)
                    }
                }
            } else if self.user.role == .presenter {
                if let safeGottenUserRole = userInfo.role {
                    if safeGottenUserRole == .viewer {
                        if self.presentation.state == .presentation {
                            return Message.askPresentationIdMessage()
                        }
                    }
                }
                
            }
            return nil
        case .askInfo:
            return Message.userInfoMessage(user: self.user)
        case .reconnect:
            Task { @MainActor in
                self.reconnect()
            }
            return nil
        case .ready:
            Task { @MainActor in
                if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peer) {
                    self.connectedUsers[peer]!.ready = true
                }
                self.user.ready = self.isAllConnectedUsersReadyToWatchPresentation()
            }
            return nil
        case .indexToShow:
            Task { @MainActor in
                self.changePresentationIndexToShow(message.indexToShow!)
            }
            return nil
        case .clearPresentation:
            Task { @MainActor in
                self.presentation.clear()
            }
            return nil
        case .presentation:
            let task = Task { @MainActor in
                self.presentation = message.presentation!
                self.presentation.moveImagesToTMPDirectory()
                self.user.ready = true
                
                return Message.readyMessage()
            }
            return await task.value
        case .askPresentationId:
            return Message.presentationIdMessage(presentationId: self.presentation.id)
        case .presentationId:
            if self.user.role == .presenter {
                if self.presentation.state == .presentation {
                    if self.presentation.id != message.presentationId! {
                        return Message.presentationMessage(presentation: self.presentation)
                    }
                }
            }
            return nil
        default:
            return nil
        }
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
                if disconnectedUser.role == .presenter {
                    self.reconnect()
                    //self.makeDiscoverable()
                }
            }
        }
    }
    
    func lostAllPeers() {
        print("[lostAllPeers]")
        for (key, _) in self.connectedUsers {
            lostPeer(key)
        }
    }
    
    /// подключился пир
    /// перемещаем его в список(кастомный) подключенных пользователей и запрашиваем инфу
    func connectedPeer(_ peerID: MCPeerID) async -> User? {
        
        // если пир есть в списке найденных(но еще не подключенных) пользователей, то
        if UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
            let task = Task { @MainActor in
                return self.foundUsers.removeValue(forKey: peerID) // удаляем его из этого списка найденных и
            }
            let user = await task.value
            // если нет пользователя в списке подключенных пользователей, то
            if !UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerID) {
                Task { @MainActor in
                    self.connectedUsers[peerID] = user
                }
                
                
                return user
            }
        }
        return nil
    }
    
    func changePresentationIndexToShow(_ index: Int) {
        self.presentation.indexToShow = index
    }
    
    func isAllConnectedUsersReadyToWatchPresentation() -> Bool {
        let count = self.connectedUsers.count
        var countToReady = 0
        for peer in self.connectedUsers.keys {
            if self.connectedUsers[peer]!.ready {
                countToReady += 1
            }
        }
        if count > 0 && countToReady > 0 && count == countToReady {
            return true
        }
        return false
    }
    
    func updateUserRole(_ role: Role?) {
            let oldRole = self.user.role
            
            if self.user.role == nil {
                self.user.role = role
            }
            
            if role == nil {
                self.user.role = nil
            }
            
            let newRole = self.user.role
            
            if oldRole != newRole && newRole == .presenter { // если сменил роль и стал новым презентером, то поменяй ИД презентации
                // для защиты от ситуации, когда презентер отключился и один из оставшихся двух захотел стать презентером
                self.presentation.clear()
            }
    }
    
    /// апдейтим инфу о пользователе
    func updateConnectedUserInfo(for peerId: MCPeerID, user: User) {
        if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerId) {
            Task { @MainActor in
                self.connectedUsers[peerId]! = user
            }
            
        }
    }
}
