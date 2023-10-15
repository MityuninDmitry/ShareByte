//
//  ShareByteApp.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI

@main
struct ShareByteApp: App {
    
    init() {
        Configurator.shared.registerServices()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TabManager.shared)
                .environmentObject(UserViewModel.shared)
                .environmentObject(PresentationTabManager.shared)
                .environmentObject(SearchAvatar.shared)
            
        }
    }
}
