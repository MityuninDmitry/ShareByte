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
    
    //@Published var foundUsers: [MCPeerID: User] = .init()
    //@Published var connectedUsers: [MCPeerID: User] = .init()
    
    @Published var users: [MCPeerID: User] = .init()
    
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
    func appendImageToPresentation(_ data: Data) async {
        Task { @MainActor in
            await self.presentation.appendImageFile(data)
        }
    }
    func saveUser() {
        self.user.save()
        if let count = messageProcessor?.peerManager?.session.connectedPeers.count, count > 0 {
            self.messageProcessor?.sendRequestTo(peers: [], message: Message(messageType: .userInfo, userInfo: self.user))
        } else {
            disconnectAndStopDiscover()
            messageProcessor = .init(businessProcessor: self, userName: user.name ?? "NO_NAME")
            makeDiscoverable()
        }
        
        
        
    }
    /// Есть ли в переданном массиве объект с таким peerID
    /// Если есть. то возращает индекс. Иначе возращает нул.
    static func hasIn(dict: [MCPeerID: User], peerID: MCPeerID) -> Bool {
        if dict[peerID] != nil {
            return true
        }
        return false
    }
    
    func hasPeer(_ peerID: MCPeerID) -> Bool {
        if self.users[peerID] != nil {
            print("Has peer \(peerID)")
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
        self.users = .init()
        print("self.users.count = \(self.users.count)")
        //self.connectedUsers = .init()
        //self.foundUsers = .init()
        self.presentation.clear()
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
    
    func sendLikeMessage(id: UUID) {
        for peer in users.keys {
            if users[peer]?.role  == .presenter {
                self.messageProcessor?.sendRequestTo(peers: [peer], message: Message.likeImage(id))
                let index = self.presentation.imageFiles.firstIndex(where: {$0.id == id})!
                self.presentation.imageFiles[index].processLikeFrom(self.user)
                
                break
            }
        }
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
                //if !UserViewModel.hasIn(dict: self.users, peerID: peer) {
                if !hasPeer(peer) {
                    var user: User = .init()
                    user.name = peer.displayName
                    self.users[peer] = user
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
            if UserViewModel.hasIn(dict: self.users, peerID: peer) {
                Task { @MainActor in
                    
                    self.users[peer]!.connected = true
                }
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
            return Message.askInfoMessage()
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
                        let task = Task { @MainActor in
                            self.updateUserRole(.presenter)
                            return Message.userInfoMessage(user: self.user)
                        }
                        return await task.value
                    }
                    else if safeGottenUserRole == .presenter {
                        let task = Task { @MainActor in
                            self.updateUserRole(.viewer)
                            return Message.userInfoMessage(user: self.user)
                        }
                        return await task.value
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
                if UserViewModel.hasIn(dict: self.users, peerID: peer) {
                    self.users[peer]!.ready = true
                }
                self.user.ready = self.isAllConnectedUsersReadyToWatchPresentation()
                if self.user.ready && self.presentation.state == .uploading {
                    self.presentation.nextState()
                }
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
            return await Task { @MainActor in
                let presentation = message.presentation!
                self.presentation = .init()
                self.presentation.id = presentation.id
                for imageFile in presentation.imageFiles {
                    var nImageFile = imageFile
                    nImageFile.setimage()
                    nImageFile.setThumbnail()
                    self.presentation.imageFiles.append(nImageFile)
                }
                self.user.ready = true
                return Message.readyMessage()
            }.value
            //return await task.value
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
        case .likeImageFile:
            Task { @MainActor in
                let imageID = message.imageFileID
                var user = self.users[peer]
                var index = 0
                var found = false
                for image in self.presentation.imageFiles {
                    if image.id == imageID {
                        found = true
                        break
                    }
                    index += 1
                }
                
                
                if found {
                    print("FOUND IMAGE WITH INDEX \(index)")
                    if let user {
                        print("HAS USER WITH ID \(user.id)")
                        
                        if self.presentation.imageFiles[index].likedUsers.count > 0 {
                            self.presentation.imageFiles[index].processLikeFrom(user)
                        } else {
                            self.presentation.imageFiles[index].likedUsers.append(user)
                        }
                        print(self.presentation.imageFiles[index].likedUsers.count)
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
        if hasPeer(peerID) {
            self.users.removeValue(forKey: peerID)
        }
        var readyPeer = 0
        for (key, _) in self.users {
            if self.users[key]!.ready {
                readyPeer += 1
            }
        }
        if self.presentation.state == .uploading {
            if readyPeer == self.messageProcessor?.peerManager?.session.connectedPeers.count {
                self.user.ready = true
                self.presentation.nextState()
            }
        }
        //notConnectedPeer(peerID)
    }
    
    func notConnectedPeer(_ peerID: MCPeerID) {
        print("[notConnectedPeer] \(peerID)")
        if hasPeer(peerID) {
            let connected = self.users[peerID]?.connected ?? false
            guard connected else { return }
            
            let user = self.users.removeValue(forKey: peerID)
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
        for (key, _) in self.users {
            lostPeer(key)
        }
    }
    
   
    
    func changePresentationIndexToShow(_ index: Int) {
        self.presentation.indexToShow = index
    }
    
    func isAllConnectedUsersReadyToWatchPresentation() -> Bool {
        let count = self.users.filter { (key: MCPeerID, value: User) in
            if value.connected {
                return true
            }
            return false
        }.count
        
        var countToReady = 0
        for peer in self.users.keys {
            if self.users[peer]!.connected {
                if self.users[peer]!.ready {
                    countToReady += 1
                }
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
        if UserViewModel.hasIn(dict: self.users, peerID: peerId) {
            Task { @MainActor in
                let connected = self.users[peerId]!.connected
                let ready = self.users[peerId]!.ready
                
                self.users[peerId]! = user
                self.users[peerId]!.connected = connected
                self.users[peerId]!.ready = ready
            }
        }
    }
}
