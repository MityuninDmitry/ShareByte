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
    var imageData: Data = UIImage(systemName: "person.circle")!.pngData()!
    @Injected var database: SavableUserModel?
    //@Injected var database: DataBase<SavableUserModel>?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case ready
        case imageData
    }
    
    init() {
        self.name = UIDevice.current.name
        self.role = nil
    }
    
    mutating func save() {
        database!.save(instance: self)
        
    }
    
    mutating func load() {
        let users = database!.loadInstances()
        if users.count > 0 {
            self = users[0] 
        }
    }
    
}
