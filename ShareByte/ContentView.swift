//
//  ContentView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI
import MultipeerConnectivity


struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var activeTab: AppTab = .presentation
    @State private var selectedPage: AppTab = .presentation
    @Namespace private var animation
    @State private var tabShapePosition: CGPoint = .zero
    
    init() {
        UITabBar.appearance().isHidden = true // баг, из-за которого при переключении табов вьюха с анимацией выезжала снизу
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                PresentationScreen()
                    .tag(AppTab.presentation)
                
                PeersScreen()
                    .tag(AppTab.peers)
                
                PersonScreen()
                    .tag(AppTab.me)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))  
            .ignoresSafeArea()
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
            .onAppear {
                  UIScrollView.appearance().isScrollEnabled = false
            }
            
            CustomTabBar()
        }
        .background {
            Rectangle()
                .fill(Color("BG").opacity(0.6).gradient)
                .rotationEffect(.init(degrees: -180))
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase, perform: { value in
            switch value {
            case .background:
                userVM.lostAllPeers()
            case .active:
                return
            case .inactive:
                return
            @unknown default:
                return
            }
        })
    }
    
    @ViewBuilder
    func CustomTabBar(_ tint: Color = Color("Indigo"), _ inactiveTint: Color = .indigo) -> some View {
        HStack(alignment: .bottom ,spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) {
                TabItemView (
                    tint: tint,
                    inactiveTint: inactiveTint,
                    tab: $0,
                    animation: animation,
                    activeTab: $activeTab,
                    position: $tabShapePosition
                )
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(content: {
            TabShape(midpoint: tabShapePosition.x)
                .fill(Color("BG"))
                .ignoresSafeArea()
                .shadow(color: tint.opacity(0.2), radius: 5, x: 0, y: -5)
                .blur(radius: 1)
                .padding(.top, 25)  
        })
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: activeTab)
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserViewModel.shared)
    }
}
