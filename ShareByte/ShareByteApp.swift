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
        Dict.AppUserDefaults.increaseRunAppCount()
        
        if Dict.AppUserDefaults.getRunAppCount() == 1 {
            Dict.AppUserDefaults.setDefaultValues()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserViewModel.shared)
                .environmentObject(SearchAvatar.shared)
                .environmentObject(NotificationManager.shared)
                .environmentObject(PurchasedStatus.shared)
                .preferredColorScheme(.dark)
        }
    }
}
