//
//  UserTypeEnum.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation

enum Role: String, Codable {
    case presenter = "Presenter"
    case viewer = "Viewer"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
