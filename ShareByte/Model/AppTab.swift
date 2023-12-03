//
//  AppTabs.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/3/23.
//

import Foundation

enum AppTab: String, CaseIterable {
    case presentation = "Presentation"
    case peers = "Peers"
    case me = "Me"
        
    var systemImage: String {
        switch self {
        case .presentation:
            return "tv"
        case .peers:
            return "person.3"
        case .me:
            return "person"
        }
    }
    
    var index: Int {
        return AppTab.allCases.firstIndex(of: self) ?? 0
    }
}
