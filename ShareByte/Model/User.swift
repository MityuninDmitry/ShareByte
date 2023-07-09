//
//  User.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import Foundation

struct User: Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: UserType? = nil
    
    init(name: String) {
        self.name = UUID().uuidString
    }
    
}
