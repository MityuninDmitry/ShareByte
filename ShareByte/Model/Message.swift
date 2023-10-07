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
    
    
}
