//
//  TabItemView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/3/23.
//

import SwiftUI

struct TabItemView: View {
    var tint: Color
    var inactiveTint: Color
    var tab: AppTab
    var animation: Namespace.ID
    @Binding var activeTab: AppTab
    @State private var tabPosition: CGPoint = .zero
    @Binding var position: CGPoint
    var body: some View {
        VStack(spacing: 5) {
            Image.init(systemName: tab.systemImage)
                .font(.title2)
                .foregroundStyle(activeTab == tab ? .white : inactiveTint)
                .frame(width: activeTab == tab ? 58 : 35, height: activeTab == tab ? 58 : 35)
                .background {
                    if activeTab == tab {
                        Circle()
                            .fill(tint.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
            
            Text(tab.localizedString())
                .font(.caption)
                .foregroundStyle(activeTab == tab ? .white : .gray)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .viewPosition(completion: { rect in
            tabPosition.x = rect.midX
            
            if activeTab == tab {
                position.x = rect.midX
            }
        })
        .onTapGesture {
            activeTab = tab
            
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                position.x = tabPosition.x
            }
        }
        
    }
}

