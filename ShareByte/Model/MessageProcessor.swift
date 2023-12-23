//
//  PeerRequestResponseProcessor.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/2/23.
//

import Foundation
import MultipeerConnectivity

protocol BusinessProcessorProtocol {
    func processMessage(_ message: Message, from: MCPeerID) async -> Message? // обработать сообщение и дать ответ сообщение
}

protocol MessageProcessorProtocol {
    var businessProcessor: BusinessProcessorProtocol {get set}
    var peerManager: PeerManager? { get set }
    
    func sendRequestTo(peers: [MCPeerID], message: Message)
    func processResponse(from peer: MCPeerID, with data: Data) async
    func processResponse(from peer: MCPeerID, with data: Data, invitationHandler: @escaping (Bool, MCSession?) -> Void) async
    func decodeMessageFrom(_ data: Data) -> Message?
}

struct MessageProcessor: MessageProcessorProtocol {
    var businessProcessor: BusinessProcessorProtocol
    var peerManager: PeerManager?
    
    init(businessProcessor: BusinessProcessorProtocol, userName: String) {
        self.businessProcessor = businessProcessor
        peerManager = .init(userName: userName)
        peerManager!.messageProcessor = self
    }
    
    func sendRequestTo(peers: [MCPeerID], message: Message) {
        var safePeers = self.peerManager!.session.connectedPeers // по дефолту подключенные пиры
        if peers.count > 0 {
            safePeers = peers // если переданы конкретные, то юзай их
        }
        if safePeers.count > 0 { // отправляй, если список пиров не пустой
            if let data = message.encode() {
                if message.messageType == .invitation {
                    self.peerManager!.serviceBrowser.invitePeer(safePeers[0], to: peerManager!.session, withContext: data, timeout: 10)
                } else {
                    for safePeer in safePeers {
                        Task {
                            try? self.peerManager!.session.send(data, toPeers: [safePeer], with: .reliable)
                        }
                    }
                    
                    
                }
                
            }
            
        }

    }
    func processResponse(from peer: MCPeerID, with data: Data) async {
        // парс данных
        let message = decodeMessageFrom(data)
        
        if let safeMessage = message {
            // обработка данных с помщью businessProcessor
            let responseMessage = await businessProcessor.processMessage(safeMessage, from: peer)
            
            // сделать запрос обратно, если надо
            if let safeResponseMessage = responseMessage {
                sendRequestTo(peers: [peer], message: safeResponseMessage)
            }
        }
    }
    
    func processResponse(from peer: MCPeerID, with data: Data, invitationHandler: @escaping (Bool, MCSession?) -> Void) async {
        // парс данных
        let message = decodeMessageFrom(data)
        
        if let safeMessage = message {
            // обработка данных с помщью businessProcessor
            let responseMessage = await businessProcessor.processMessage(safeMessage, from: peer)
            
            // сделать запрос обратно, если надо
            if let safeResponseMessage = responseMessage {
                let messageType = safeResponseMessage.messageType
                if messageType != .acceptInvitation && messageType != .notAcceptInvitation {
                    sendRequestTo(peers: [peer], message: safeResponseMessage)
                } else {
                    
                    if messageType == .acceptInvitation {
                        invitationHandler(true, self.peerManager?.session)
                    } else {
                        invitationHandler(false, self.peerManager?.session)
                    }
                    
                }
                
            }
        }
    }
    
    func decodeMessageFrom(_ data: Data) -> Message? {
        let decoder = PropertyListDecoder() // для декодинга сообщений
        if let message = try? decoder.decode(Message.self, from: data) {
            return message
        }
        return nil
    }
    
    func startRecieveMessages() {
        self.peerManager!.discover()
    }
    
    func stopRecieveMessages() {
        peerManager!.disconnect()
    }
}


