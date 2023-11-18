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

struct User: Identifiable, Codable, SavableProtocol {
    
    var id: String = ObjectId.generate().stringValue
    var name: String? = nil
    var role: Role? = nil
    var ready: Bool = false
    var imageData: Data = UIImage(systemName: "person.circle")!.pngData()!
    @Injected var db: DataBase<UserLoadable, User>? 
    
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
        db!.save(instance: self)
    }
    
    mutating func load() {
        let users = db!.load()
        if users.count > 0 {
                   self = users[0]
        }
               
    }
    
    
    func mapToLoadable() -> LoadableProtocol {
        let loadableUser = UserLoadable()
        loadableUser._id = try! ObjectId(string: self.id)
        loadableUser.name = self.name ?? ""
        loadableUser.imageData = self.imageData
        return loadableUser
    }
}
