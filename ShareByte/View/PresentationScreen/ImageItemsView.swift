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
            HeaderView(selectedItems: $selectedItems, index: $index) {
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
        .onChange(of: userVM.users.count) { _ in
            actualizeTools()
        }
        
                          
        

    }
    
    func actualizeTools() {
        if userVM.user.role == .presenter {
            switch userVM.presentation.state {
            case .selecting, .preparing:
                tools = [
                    .init(
                        icon: "paperplane.circle",
                        name: NSLocalizedString("Upload images to peers", comment: "Отправить картинки пользователям") ,
                        color: Dict.appIndigo,
                        action: {},
                        ignoreAction: true,
                        position: .left
                    )
                ]
            case .prepared:
                tools = [
                    .init(
                        icon: "paperplane.circle",
                        name: NSLocalizedString("Upload images to peers", comment: "Отправить картинки пользователям") ,
                        color: Dict.appIndigo,
                        action: {
                            userVM.presentation.nextState()
                            userVM.sendPresentationtToAll()},
                        ignoreAction: userVM.connectedUsersCount == 0,
                        position: .left
                    )
                ]
            case .uploading:
                tools = [
                    .init(
                        icon: "arrow.clockwise.icloud",
                        name: NSLocalizedString("Uploading images to peers", comment: "Загрузка картинок пользователям"),
                        color: Dict.appIndigo,
                        action: {},
                        ignoreAction: true,
                        position: .left)
                ]
            case .presentation:
                tools = [
                    .init(
                        icon: "trash.circle",
                        name: NSLocalizedString("Start new presentation", comment: "Начать новую презентацию") ,
                        color: Dict.appIndigo,
                        action: {
                            self.userVM.presentation.nextState()
                            self.userVM.user.ready = false
                            for (key, _) in self.userVM.users {
                                self.userVM.users[key]!.ready = false
                            }
                            self.userVM.sendClearPresentation()
                            self.selectedItems = .init()
                        },
                        position: .left)
                ]
            }
        }
    }
}

#Preview {
    ImageItemsView()
        .preferredColorScheme(.dark)
}
