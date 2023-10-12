//
//  User.swift
//  ShareByte
//
//  Created by Дмитрий on 17.09.2023.
//

import Foundation
import UIKit
import SwiftUI
import RealmSwift

struct User: Identifiable, Codable {
    var id: String = ObjectId.generate().stringValue
    var name: String? = nil
    var role: Role? = nil
    var ready: Bool = false
    var image: UIImage =  .init(systemName: "person.circle")!
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case ready
    }
    
    init() {
        self.name = UIDevice.current.name
        self.role = nil
    }
    
    func save() {
        SavableUser.save(user: self)
    }
    
    mutating func load() -> Bool {
        let users = SavableUser.loadInstances()
        if users.count > 0 {
            self = users[0]
            return true
        }
        return false 
    }
    
}
