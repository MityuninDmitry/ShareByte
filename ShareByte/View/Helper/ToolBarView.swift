//
//  ToolBarView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/12/23.
//

import SwiftUI
import PhotosUI

struct ToolBarView: View {
    @Binding var tools: [Tool]
    @State var activeTool: Tool?
    @State var startedToolPosition: CGRect = .zero
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach($tools) { $tool in
                ToolView(activeTool: $activeTool, tool: $tool) {
                    if $tool.wrappedValue.name == "Uploading images to peers" {
                        ProgressView()
                    } else {
                        Image(systemName: $tool.wrappedValue.icon)
                    }
                    
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .coordinateSpace(name: "AREA")
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    guard let firstTool = tools.first else {return}
                    if startedToolPosition == .zero {
                        startedToolPosition = firstTool.toolPosition
                    }
                    let location = CGPoint(x: startedToolPosition.midX, y: value.location.y)
                    
                    if let index = tools.firstIndex(where: { tool in
                        tool.toolPosition.contains(location)
                    }), activeTool?.id != tools[index].id {
                        withAnimation(.interpolatingSpring(stiffness: 230, damping: 22)) {
                            activeTool = tools[index]
                        }
                    }
                }).onEnded({ value in
                    if let index = tools.firstIndex(where: { tool in
                        tool.toolPosition.contains(CGPoint(x: value.location.x, y: value.location.y))
                    }), activeTool?.id == tools[index].id {
                        if !(activeTool?.ignoreAction ?? false) {
                            activeTool?.action()
                        }
                    }
                    
                    withAnimation(.interpolatingSpring(stiffness: 230, damping: 22)) {
                        activeTool = nil
                        startedToolPosition = .zero
                    }
                })
        )
    }
}


