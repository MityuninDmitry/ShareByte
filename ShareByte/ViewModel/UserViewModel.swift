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
    func acceptInvitation(isAccepted: Bool, from peerID: MCPeerID)
    func canAcceptInvitation() -> Bool
    func canAcceptInvitation(_ presentationId: String?) -> Bool
    func gotMessage(from: MCPeerID, data: Data)
    func addFoundPeer(_ peerID: MCPeerID)
    func connectedPeer(_ peerID: MCPeerID)
}

class UserViewModel: ObservableObject {
    static var shared = UserViewModel()
    
    @Published var foundUsers: [MCPeerID: User] = .init()
    @Published var connectedUsers: [MCPeerID: User] = .init()
    @Published var user: User // инфа о пользователе
    @Published var presentation: Presentation = .init()
    @Published var disoverableStatus: DiscoverableStatus = .stopped
    var peerManager: PeerManager?  // менеджер управления соединением
    private let encoder = PropertyListEncoder() // для энкодинга сообщений
    private let decoder = PropertyListDecoder() // для декодинга сообщений

    private init() {
        self.user = .init()
        self.user.load() // загружаем пользователя из БД, если он есть

        peerManager = .init(userName: user.name ?? "NO NAME")
        peerManager!.userDelegate = self
        
        self.makeDiscoverable()
    }
    func appendImageToPresentation(_ data: Data) {
        self.presentation.appendImageData(data)
    }
    func saveUser() {
        self.user.save()
        self.sendUserInfoTo(peers: self.peerManager!.session.connectedPeers)
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
        //self.presentation.clear()
        peerManager!.disconnect()
        self.disoverableStatus = .stopped
        
    }
    
    func makeDiscoverable() {
        print("[makeDiscoverable]")
        self.peerManager!.discover()
        self.disoverableStatus = .running
    }
    
    // шлем приглашение пользователю
    func inviteUser(_ peerId: MCPeerID) {
        self.peerManager!.serviceBrowser.invitePeer(peerId, to: peerManager!.session, withContext: AppDecoder.stringToData(self.presentation.id), timeout: 10)
    }
    
    /// добавить peerID
    func addToConnectedPeer(_ peerID: MCPeerID) -> User? {
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
                
                try self.peerManager!.session.send(data, toPeers: peers, with: .reliable)
            }
        } catch {
            print("Error for sending: \(String(describing: error))")
        }
    }
    
    func sendUserInfoTo(peers: [MCPeerID]) {
        if peers.count > 0 {
            let message = Message(messageType: .userInfo, userInfo: self.user)
            self.sendMessageTo(peers: peers, message: message)
        }
    }
    func sendImagesData() {
        Task {
            if self.peerManager!.session.connectedPeers.count > 0 {
                let imagesData = self.presentation.imagesData
                let peers = self.peerManager!.session.connectedPeers
                let message = Message(messageType: .image, imagesData: imagesData)
                self.sendMessageTo(peers: peers, message: message)
            }
        }
    }
    func sendPresentation(to peers: [MCPeerID]) {
        Task {
            if peers.count > 0 {
                let message = Message(messageType: .presentation, presentation: self.presentation)
                self.sendMessageTo(peers: peers, message: message)
            } else {
                if self.peerManager!.session.connectedPeers.count > 0 {
                    let peers = self.peerManager!.session.connectedPeers
                    let message = Message(messageType: .presentation, presentation: self.presentation)
                    self.sendMessageTo(peers: peers, message: message)
                }
            }
            
            
        }
    }
    func sendPresentationId(to peers: [MCPeerID]) {
        Task {
            let message = Message(messageType: .presentationId, presentationId: self.presentation.id)
            self.sendMessageTo(peers: peers, message: message)
        }
    }
    func askPresentationId(to peers: [MCPeerID]) {
        Task {
            let message = Message(messageType: .askPresentationId)
            self.sendMessageTo(peers: peers, message: message)
        }
    }
    
    func sendIndexToShow(_ index: Int) {
        let message = Message(messageType: .indexToShow, indexToShow: index)
        let peers = self.peerManager!.session.connectedPeers
        sendMessageTo(peers: peers, message: message)
    }
    func sendClearPresentation() {
        let message = Message(messageType: .clearPresentation)
        let peers = self.peerManager!.session.connectedPeers
        sendMessageTo(peers: peers, message: message)
    }
    func sendReconnectTo(peers: [MCPeerID]) {
        let message = Message(messageType: .reconnect)
        self.sendMessageTo(peers: peers, message: message)
    }
    func sendReadyToStartPresentation(peers: [MCPeerID]) {
        let message = Message(messageType: .ready)
        self.sendMessageTo(peers: peers, message: message)
    }
    
    /// апдейтим инфу о пользователе
    func updateConnectedUserInfo(for peerId: MCPeerID, user: User) {
        if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peerId) {
            self.connectedUsers[peerId]! = user
        }
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
    
    /// Запрашиваем информацию о пользователе
    func askUserInfo(_ peerId: MCPeerID) {
        print("[askUserInfo] \(peerId)")
        let newMessage = Message(messageType: .askInfo)
        sendMessageTo(peers: [peerId], message: newMessage)
    }
}


extension UserViewModel: UserDelegate {
    
    
    /// инициализация пользователя с таким-то peerID и добавление этого пользователя в список найденных пользователей
    func addFoundPeer(_ peerID: MCPeerID) {
        print("[addFoundPeer] \(peerID)")
        Task { @MainActor in
            if !UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
                let user: User = .init()
                self.foundUsers[peerID] = user
            }
        }
    }
    /// подключился пир
    /// перемещаем его в список(кастомный) подключенных пользователей и запрашиваем инфу
    func connectedPeer(_ peerID: MCPeerID) {
        let user = self.addToConnectedPeer(peerID)
        if user != nil {
            print("[connectedPeer] \(peerID)")
            self.askUserInfo(peerID)
        }
        
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
    
    /// Получить сообщение от пира
    func gotMessage(from peer: MCPeerID, data: Data) {
        Task { @MainActor in
            if let message = try? decoder.decode(Message.self, from: data) {
                print("[gotMessage] \(message.messageType)")
                switch message.messageType {
                case .askInfo: // если пир запросил инфо обо мне, то предоставить эту инфу
                    self.sendUserInfoTo(peers: [peer])
                case .userInfo: // получили инфу от пользователя
                    let userInfo = message.userInfo!
                    self.updateConnectedUserInfo(for: peer, user: userInfo)
                    if self.user.role == nil { // если мой тип пустой, то
                        if let safeGottenUserRole = userInfo.role {
                            if safeGottenUserRole == .viewer { // если он вьюер, то я презентер
                                self.updateUserRole(.presenter)
                                self.sendUserInfoTo(peers: [peer])
                                
                            }
                            else if safeGottenUserRole == .presenter {
                                self.updateUserRole(.viewer)
                                self.sendUserInfoTo(peers: [peer])
                            }
                        }
                    } else if self.user.role == .presenter {
                        if let safeGottenUserRole = userInfo.role {
                            if safeGottenUserRole == .viewer {
                                if self.presentation.state == .presentation {
                                    self.askPresentationId(to: [peer])
                                }
                            }
                        }
                        
                    }
                case .reconnect:
                    self.reconnect()
                case .image:
                    let imageDatas = message.imagesData!
                    for imageData in imageDatas {
                        self.appendImageToPresentation(imageData)
                    }
                    self.user.ready = true
                    
                    self.sendReadyToStartPresentation(peers: [peer])
                case .ready:
                    if UserViewModel.hasIn(dict: self.connectedUsers, peerID: peer) {
                        self.connectedUsers[peer]!.ready = true
                    }
                    self.user.ready = self.isAllConnectedUsersReadyToWatchPresentation()
                case .indexToShow:
                    self.changePresentationIndexToShow(message.indexToShow!)
                case .clearPresentation:
                    self.presentation.clear()
                case .presentation:
                    self.presentation = message.presentation!
                    self.presentation.moveImagesToTMPDirectory()
                    self.user.ready = true
                    self.sendReadyToStartPresentation(peers: [peer])
                case .askPresentationId:
                    self.sendPresentationId(to: [peer])
                case .presentationId:
                    if self.user.role == .presenter {
                        if self.presentation.state == .presentation {
                            if self.presentation.id != message.presentationId! {
                                self.sendPresentation(to: [peer])
                            }
                        }
                    }
                    
                    
                }
            
                
            }
        }
        
    }
    func changePresentationIndexToShow(_ index: Int) {
        self.presentation.indexToShow = index
    }
    
    func acceptInvitation(isAccepted: Bool, from peerID: MCPeerID) {
        if isAccepted {
            Task { @MainActor in
                self.updateUserRole(.viewer)
            }
        }
    }
    
    func canAcceptInvitation() -> Bool {
        if self.user.role == nil {
            return true
        }
        return false
    }
    
    func canAcceptInvitation(_ presentationId: String?) -> Bool {
        if self.user.role == .presenter {
            if self.presentation.id == presentationId! {
                return true
            } else {
                return false
            }
        }
        else if self.user.role == nil {
            return true
        }
        
        return false
    }
    
    func lostPeer(_ peerID: MCPeerID) {
        print("[lostPeer] \(peerID)")
        Task { @MainActor in
            if UserViewModel.hasIn(dict: self.foundUsers, peerID: peerID) {
                self.foundUsers.removeValue(forKey: peerID)
            }
            notConnectedPeer(peerID)
        }
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
}
