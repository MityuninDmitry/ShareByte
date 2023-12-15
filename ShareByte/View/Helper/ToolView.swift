//
//  ToolView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/12/23.
//

import SwiftUI

struct ToolView<Content: View>: View {
    @Binding var activeTool: Tool?
    @Binding var tool: Tool
    @ViewBuilder let content: Content
    
    @State var showName: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            Text($tool.wrappedValue.name)
                .padding([.trailing, .leading], 15)
                .padding(.vertical, 5)
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("Indigo").gradient.opacity(0.7))
                }
                .offset(x: activeTool?.id == $tool.wrappedValue.id ? -10 : 0)
                .opacity(showName ? 1.0 : 0.0)

            content
                .font(activeTool?.id == tool.id ? .title : .title2)
                .foregroundStyle(tool.ignoreAction ? .gray : tool.iconColor)
                .frame(width: activeTool?.id == tool.id ? 60 : 58, height: activeTool?.id == tool.id ? 60 : 58)
                .background {
                    GeometryReader { proxy in
                        ZStack {
                            let frame = proxy.frame(in: .named("AREA"))
                            Color.clear
                                .preference(key: RectKey.self, value: frame)
                                .onPreferenceChange(RectKey.self) { rect in
                                    
                                    $tool.wrappedValue.toolPosition = rect
                                    
                                }
                            
                            Circle()
                                .fill($tool.wrappedValue.color.gradient)
                                .foregroundStyle($tool.wrappedValue.color)
                            
                        }
                        
                    }
                }
                .offset(x: activeTool?.id == $tool.wrappedValue.id ? -10 : 0)
        }
        .onChange(of: activeTool?.id) { newValue in
            if activeTool?.id == $tool.wrappedValue.id {
                withAnimation(.interpolatingSpring(stiffness: 230, damping: 22).delay(0.2) ) {
                    showName = true
                }
            } else if activeTool == nil {
                withAnimation(.interpolatingSpring(stiffness: 230, damping: 22)) {
                    showName = false
                }
            }
            
        }
        
        
        
        
    }
}

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
