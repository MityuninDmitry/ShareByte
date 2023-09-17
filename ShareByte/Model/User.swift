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
    var presentation: Presentation
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case presentation
    }
    
    init(id: UUID? = nil, name: String? = nil, role: Role? = nil, presentation: Presentation) {
        self.id = id
        self.name = name
        self.role = role
        self.presentation = presentation
    }
    
    init() {
        self.id = UUID()
        self.name = UIDevice.current.name
        self.role = nil
        self.presentation = .init()
    }
    
    
        
}
