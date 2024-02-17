//
//  User.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation
import MultipeerConnectivity

class PurchasedStatus: ObservableObject {
    static var shared = PurchasedStatus()
    @Published var isPremium: Bool
    
    private init() {
        isPremium = Dict.AppUserDefaults.getIsPremium()
    }
    
    
    
    

}

class UserViewModel: ObservableObject {
    static var shared = UserViewModel()
    
    @Published var users: [MCPeerID: User] = .init() {
        didSet {
            Task { @MainActor in
                connectedUsersCount = users.filter{ (key: MCPeerID, value: User) in
                    if value.connected == true {
                        return true
                    }
                    else {
                        return false
                    }
                }.count
            }
        }
    }
    @Published var connectedUsersCount: Int = 0
    @Published var user: User // инфа о пользователе
    @Published var presentation: Presentation = .init()
    @Published var disoverableStatus: DiscoverableStatus = .stopped
    var messageProcessor: MessageProcessor?
    
    @Published var newNotification: NotificationView?
    
    private init() {
        self.user = .init()
        self.user.load() // загружаем пользователя из БД, если он есть
        messageProcessor = .init(businessProcessor: self, userName: user.name ?? "NO_NAME")
        
        self.makeDiscoverable()
    }
    func getUserMCPeerIDBy(id: String) -> MCPeerID? {
        for key in users.keys {
            if self.users[key]!.id == id {
                return key
            }
        }
        return nil
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
            //messageProcessor?.peerManager = .init(userName: user.name ?? "NO_NAME")
            //messageProcessor?.renamePeerName(user.name ?? "NO_NAME")
            
            makeDiscoverable()
            
            
            //reconnect()
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
        print("[DISCONNECT AND STOP DISCOVER]")
        self.updateUserRole(nil)
        self.users = .init()
        self.clearPresentation()
        self.messageProcessor?.stopRecieveMessages()
        self.disoverableStatus = .stopped
        
    }
    func clearPresentation() {
        self.presentation.clear()
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
    func sendAskPresentationId(peers: [MCPeerID]) {
        self.messageProcessor?.sendRequestTo(peers: peers, message: Message.askPresentationIdMessage())
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
    
    func setNotificationNewUser(user: User) {
        Task { @MainActor in
            if self.presentation.state == .presentation {
                if !user.connected {
                    if self.connectedUsersCount >= Dict.AppUserDefaults.getUserLimit() && !PurchasedStatus.shared.isPremium {
                        
                        newNotification =  NotificationView(
                            header: NSLocalizedString("Found new user ", comment: "") + "\(user.name ?? "")",
                            text:  NSLocalizedString("Limit users in session is exceed. Buy Premium App version.",comment: "")
                        )
                    } else if self.connectedUsersCount == Dict.AppUserDefaults.getUserLimit() && PurchasedStatus.shared.isPremium{
                        newNotification = NotificationView(
                            header: NSLocalizedString("Found new user ", comment: "") + "\(user.name ?? "")",
                            text: NSLocalizedString("App Premium limit users in session is exceed.",comment: "")
                        )
                    }
                    else {
                        let newMCPeerId = self.getUserMCPeerIDBy(id: user.id)
                        guard newMCPeerId != nil else {return}
                        newNotification = NotificationView(
                            header: NSLocalizedString("Found new user ", comment: "") + "\(user.name ?? "")",
                            text: NSLocalizedString("Do you want to invite him to session and share current presentation?",comment: ""),
                            accept: {
                                self.inviteUser(newMCPeerId!)
                            },
                            decline: {
                                
                            }
                        )
                    }
                }
                
            }
        }
    }
    
    func setNotificationBadVersion(peer: MCPeerID) {
        Task { @MainActor in
            newNotification = NotificationView(
                header: NSLocalizedString("Found", comment: "") + " \(peer.displayName)",
                text: NSLocalizedString("You can't communicate because of app version difference. User won't be shown in list of users.", comment: "")
            )
        }
    }
    
    func setInvitationNotification(from: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        Task { @MainActor in
            newNotification = NotificationView(
                header: NSLocalizedString("Got invitation from", comment: "") + " \(from.displayName)",
                text: NSLocalizedString("Do you want to accept invitation?", comment: ""),
                accept: {
                    self.updateUserRole(.viewer)
                    invitationHandler(true, self.messageProcessor?.peerManager?.session)
                },
                decline: {
                    invitationHandler(false, self.messageProcessor?.peerManager?.session)
                }, onSwipe: {
                    invitationHandler(false, self.messageProcessor?.peerManager?.session)
                })
        }
    }
    
    func setNotificationUserDisconnect(user: User) {
        Task { @MainActor in
            newNotification = NotificationView(
                header: "\(user.name ?? "") " + NSLocalizedString("left presentation.", comment: ""),
                text: NSLocalizedString("You can Invite him again when he will be discoverable.", comment: "")
                )
        }
    }
    
    func isValidUserLimit(peer: MCPeerID) -> Bool {
        if self.user.role == .presenter && self.connectedUsersCount > Dict.AppUserDefaults.getUserLimit() {
            print("SENT RECCONNECT \(self.connectedUsersCount) AND LIMIT IS \(Dict.AppUserDefaults.getUserLimit())")
            self.sendReconnectTo(peers: [peer])
            return false
        }
        return true
    }
}


extension UserViewModel: BusinessProcessorProtocol {
    
    func processInvitation(_ message: Message, from: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void) async -> Message? {
        let messageType = message.messageType
        if messageType == .invitation {
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
                    self.setInvitationNotification(from: from, invitationHandler: invitationHandler)
                    return Message.waitUserResponseMessage()
                }
                else if self.user.role == .viewer {
                    if let presentationId = message.presentationId {
                        if self.presentation.id == presentationId { // челик вьюер, презентер сворачивал приложение и сейчас восстанавливает сессию
                            // если ИД презентаций совпадает, то автоматическое согласие - тчобы продолжить презу
                            return Message.acceptInvitation()
                        }
//                        else { // иначе опрос вьюера хочет ли он попасть в другую презентацию
//                            self.setInvitationNotification(from: from, invitationHandler: invitationHandler)
//                            return Message.waitUserResponseMessage()
//                        }
                    }
                    
                    
                }
                
                return Message.notAcceptInvitation()
            }
            return await task.value
        }
        return nil
    }
    
    func processMessage(_ message: Message, from peer: MCPeerID, info: [String: String]?) async -> Message? {
        let messageType = message.messageType
        print("GOT MESSAGE WITH TYPE: \(messageType) FROM \(peer)")
        switch messageType {
            // MARK: FOUND PEER
        case .showWarningBadVersion:
            Task { @MainActor in
                self.setNotificationBadVersion(peer: peer)
            }
            return nil
        case .foundPeer:
            // инициализация пользователя с таким-то peerID и добавление этого пользователя в список найденных пользователей
            if !hasPeer(peer) {
                
                Task { @MainActor in
                    print("HAS NO SUCH PEER")
                    var user: User = .init()
                    user.name = peer.displayName
                    self.users[peer] = user
                    self.setNotificationNewUser(user: user)
                }
            } else {
                
                Task { @MainActor in
                    print("HAS SUCH PEER")
                    users[peer]!.ready = false
                }
            }
            return nil
            // MARK: invitation
        case .invitation:
            return nil // определено в processInvitation
            // MARK: connected
        case .connected:
            if UserViewModel.hasIn(dict: self.users, peerID: peer) {
                Task { @MainActor in
                    self.users[peer]!.connected = true
                }
                
            }
            try? await Task.sleep(for: .seconds(1))
            if isValidUserLimit(peer: peer) {
                return Message.askInfoMessage()
            } else {
                return nil
            }
            // MARK: askInfo
        case .askInfo:
            return Message.userInfoMessage(user: self.user)
            // MARK: userInfo
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
                
            } else if self.user.role == .viewer {
                if let safeGottenUserRole = userInfo.role {
                    if safeGottenUserRole == .presenter {
                        return Message.askPresentationIdMessage()
                    }
                }
            }
            return nil
            // MARK: reconnect
        case .reconnect:
            Task { @MainActor in
                self.reconnect()
            }
            return nil
            // MARK: ready
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
            // MARK: indexToShow
        case .indexToShow:
            Task { @MainActor in
                self.changePresentationIndexToShow(message.indexToShow!)
            }
            return nil
            // MARK: clearPresentation
        case .clearPresentation:
            Task { @MainActor in
                self.clearPresentation()
            }
            return nil
            // MARK: presentation
        case .askPresentation:
            if self.user.role == .presenter {
                if self.presentation.state == .presentation || self.presentation.state == .uploading {
                    return Message.presentationMessage(presentation: self.presentation)
                }
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
            // MARK: askPresentationId
        case .askPresentationId:
            return Message.presentationIdMessage(presentationId: self.presentation.id)
            // MARK: presentationId
        case .presentationId:
            if self.user.role == .presenter {
                if self.presentation.state == .presentation || self.presentation.state == .uploading {
                    if self.presentation.id != message.presentationId! {
                        Task { @MainActor in
                            self.presentation.state = .uploading
                        }
                        return Message.presentationMessage(presentation: self.presentation)
                    }
                }
            } else if self.user.role == .viewer {
                if self.presentation.id == message.presentationId! {
                    // если ИД презентаций совпадают, значит у вьюера уже есть презентация (например после сворачивания приложения презентера)
                    // потому шлем презентеру, что готовы к просмотру
                    return Message.readyMessage()
                } else {
                    // если ИД презентаций не совпадают (например новый презентер или новая презентация)
                    // то очистить текущую, проставить ей ИД и запрость саму презентацию у презентера
                    Task { @MainActor in
                        self.presentation.clear()
                        self.presentation.id = message.presentationId!
                    }
                    return Message.askPresentationMessage()
                }
                
            }
            return nil
            // MARK: likeImageFile
        case .likeImageFile:
            Task { @MainActor in
                let imageID = message.imageFileID
                let user = self.users[peer]
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
                    if let user {
                        
                        if self.presentation.imageFiles[index].likedUsers.count > 0 {
                            self.presentation.imageFiles[index].processLikeFrom(user)
                        } else {
                            self.presentation.imageFiles[index].likedUsers.append(user)
                        }
                    }
                }
                
            }
            return nil
            // MARK: lostPeer
        case .lostPeer:
            Task { @MainActor in
                lostPeer(peer)
            }
            return nil
            // MARK: notConnected
        case .notConnected:
            Task { @MainActor in
                notConnectedPeer(peer)
            }
            return nil
        default:
            return nil
        }
    }
    
    func lostPeer(_ peerID: MCPeerID) {
        print("[LOST PEER] \(peerID)")
        if hasPeer(peerID) {
            self.users.removeValue(forKey: peerID)
        }
        var readyPeerCount = 0
        for (key, _) in self.users {
            if self.users[key]!.ready {
                readyPeerCount += 1
            }
        }
        if self.presentation.state == .uploading {
            if readyPeerCount == self.messageProcessor?.peerManager?.session.connectedPeers.count {
                self.user.ready = true
                self.presentation.nextState()
            }
        }
        //notConnectedPeer(peerID)
    }
    
    func notConnectedPeer(_ peerID: MCPeerID) {
        print("[NOT_CONNECTED_PEER] \(peerID)")
        if hasPeer(peerID) {
            let connected = self.users[peerID]?.connected ?? false
            guard connected else { return }
            
            let user = self.users.removeValue(forKey: peerID)
            if self.user.role == .presenter && self.presentation.state == .presentation {
                self.setNotificationUserDisconnect(user: user!)
            }
        }
    }
    
    func lostAllPeers() {
        print("[lostAllPeers]")
        for (key, _) in self.users {
            lostPeer(key)
        }
    }
    
    func hasConnectedPresenter() -> Bool {
        for key in users.keys {
            let user = users[key]!
            if user.connected && user.role == .presenter {
                return true
            }
        }
        return false 
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
            self.clearPresentation()
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
