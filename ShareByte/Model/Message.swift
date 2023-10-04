//
//  Message.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 8/1/23.
//

import Foundation

struct Message: Codable {
    enum MessageType: Codable {
        case askInfo
        case userInfo
        case reconnect
        case image
        case ready
        case indexToShow
        case clearPresentation
    }
    
    var messageType: MessageType = .askInfo
    var message: String? = nil
    var userInfo: User? = nil
    var imagesData: [Data]? = nil
    var indexToShow: Int? = nil
    
    func preparedToSendFully() -> (Bool, String?) {
        switch self.messageType {
        case .askInfo:
            return (true,nil)
        case .clearPresentation:
            return (true,nil)
        case .image:
            if imagesData == nil {
                return (false, "need filled imagesData")
            } else {
                return (true,nil)
            }
        case .ready:
            return (true,nil)
        case .reconnect:
            return (true,nil)
        case .indexToShow:
            if indexToShow == nil {
                return (false, "need filled indexToShow")
            } else {
                return (true,nil)
            }
        case .userInfo:
            if self.userInfo == nil {
                return (false, "need filled userInfo")
            } else {
                return (true,nil)
            }
        }
    }
    
}
