//
//  Message.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 8/1/23.
//

import Foundation

struct Message: Codable {
    enum MessageType: Codable {
        case invitation // 
        case acceptInvitation // эмуляция сообщения ответа 
        case notAcceptInvitation // эмуляция сообщения ответа 
        case notConnected // эмуляция сообщения
        case connected // эмуляция сообщения 
        case foundPeer // эмуляция сообщения
        case lostPeer // эмуляция сообщения
        case askInfo //
        case userInfo //
        case reconnect //
        case ready //
        case indexToShow //
        case clearPresentation
        case presentation
        case askPresentationId
        case presentationId
    }
    
    var messageType: MessageType = .askInfo
    var message: String? = nil
    var userInfo: User? = nil
    var indexToShow: Int? = nil
    var presentation: Presentation? = nil
    var presentationId: String?
    
    
    func encode() -> Data? {
        let encoder = PropertyListEncoder() // для энкодинга сообщений
        if let data = try? encoder.encode(self) {
            
            return data
        }
        return nil 
    }
    
    static func userInfoMessage(user: User) -> Message {
        return Message(messageType: .userInfo, userInfo: user)
    }
    
    static func askInfoMessage() -> Message {
        return Message(messageType: .askInfo)
    }
    
    static func askPresentationIdMessage() -> Message {
        return Message(messageType: .askPresentationId)
    }
    
    static func invitationMessage(presentationId: String) -> Message {
        return Message(messageType: .invitation, presentationId: presentationId)
    }
    
    static func acceptInvitation() -> Message {
        return Message(messageType: .acceptInvitation)
    }
    
    static func notAcceptInvitation() -> Message {
        return Message(messageType: .notAcceptInvitation)
    }
    
    static func presentationMessage(presentation: Presentation) -> Message {
        return Message(messageType: .presentation, presentation: presentation)
    }
    
    static func readyMessage() -> Message {
        return Message(messageType: .ready)
    }
    
    static func indexToShowMessage(index: Int) -> Message {
        return Message(messageType: .indexToShow, indexToShow: index)
    }
    
    static func clearPresentationMessage() -> Message {
        return Message(messageType: .clearPresentation)
    }
    static func reconnectMessage() -> Message {
        return Message(messageType: .reconnect)
    }
    
    static func presentationIdMessage(presentationId: String) -> Message {
        return Message(messageType: .presentationId, presentationId: presentationId)
    }
}
