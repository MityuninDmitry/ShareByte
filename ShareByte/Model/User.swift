//
//  User.swift
//  ShareByte
//
//  Created by Дмитрий on 17.09.2023.
//

import Foundation
import UIKit


struct User: Identifiable, Codable {
    var id: UUID? = nil
    var name: String? = nil
    var role: Role? = nil
    var ready: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case ready
    }
    
    init(id: UUID? = nil, name: String? = nil, role: Role? = nil) {
        self.id = id
        self.name = name
        self.role = role
        
    }
    
    init() {
        self.id = UUID()
        self.name = UIDevice.current.name
        self.role = nil
    }
    
    
        
}
