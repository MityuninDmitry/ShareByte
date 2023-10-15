//
//  ContentView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI
import MultipeerConnectivity


struct ContentView: View {
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
        TabView(selection: $tabManager.seletedTabId) {
            PresentationScreen()
                .tabItem {
                    Label("Presentation", systemImage: "tv")
                }
                .tag(0)
            
            PeersScreen()
                .tabItem {
                    Label("Peers", systemImage: "person.3")
                }
                .tag(1)
            
            PersonScreen()
                .tabItem {
                    Label("Me", systemImage: "person")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabManager.shared)
            .environmentObject(UserViewModel.shared)
    }
}
