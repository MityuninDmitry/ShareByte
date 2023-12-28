//
//  SelectingImageItemsView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/4/23.
//

import SwiftUI
import PhotosUI

struct ImageItemsView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var index: Int = 0
    @State private var selectedItems: [PhotosPickerItem] = .init()
    @State var tools: [Tool] = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(selectedItems: $selectedItems) {
                actualizeTools()
            }
            
            PreviewImageView(selectedItems: $selectedItems, index: $index) {
                actualizeTools()
            }
            
            CarouselView(selectedItems: $selectedItems, index: $index)
            
        }
        .overlay {
            OverlayImageItemsView(tools: $tools)
        }
        .onAppear {
            actualizeTools()
        }
        .onChange(of: userVM.presentation.state) { _ in
            actualizeTools()
        } 

    }
    
    func actualizeTools() {
        if userVM.user.role == .presenter {
            switch userVM.presentation.state {
            case .selecting:
                tools = [
                    .init(
                        icon: "paperplane.circle",
                        name: "Upload images to peers",
                        color: Color("Indigo"),
                        action: {
                            userVM.presentation.nextState()
                            userVM.sendPresentationtToAll()},
                        ignoreAction: userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0 || userVM.presentation.imageFiles.count == 0,
                        position: .left
                    )
                ]
            case .uploading:
                tools = [
                    .init(
                        icon: "arrow.clockwise.icloud",
                        name: "Uploading images to peers",
                        color: Color("Indigo"),
                        action: {},
                        ignoreAction: true,
                        position: .left)
                ]
            case .presentation:
                tools = [
                    .init(
                        icon: "trash.circle",
                        name: "Start new presentation",
                        color: Color("Indigo"),
                        action: {
                            self.userVM.presentation.clear()
                            self.userVM.user.ready = false
                            for (key, _) in self.userVM.users {
                                self.userVM.users[key]!.ready = false
                            }
                            self.userVM.sendClearPresentation()
                            userVM.presentation.nextState()
                        },
                        position: .left)
                ]
            default:
                tools = .init()
            }
        }
    }
}

#Preview {
    ImageItemsView()
        .preferredColorScheme(.dark)
}
