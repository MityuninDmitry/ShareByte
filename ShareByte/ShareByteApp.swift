//
//  ShareByteApp.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI

@main
struct ShareByteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TabManager.shared)
                .environmentObject(UserViewModel())
                .environmentObject(PresentationTabManager.shared)
            
        }
    }
}
