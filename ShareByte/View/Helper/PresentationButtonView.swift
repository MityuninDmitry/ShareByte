//
//  PresentationButtonView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/5/23.
//

import SwiftUI
import PhotosUI

struct PresentationButtonView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedItems: [PhotosPickerItem] 
    var body: some View {
        switch userVM.presentation.state {
        case .selecting:
            CircleButtonView(systemImageName: "paperplane.circle", imageColor: (userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0 || userVM.presentation.imageFiles.count == 0) ? .gray : .white)
                .onTapGesture {
                    userVM.presentation.nextState()
                    userVM.sendPresentationtToAll()
                }
                .disabled(userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0 || userVM.presentation.imageFiles.count == 0)
        case .uploading:
            ProgressView()
                .background {
                    CircleButtonView()
                }
        case .presentation:
            CircleButtonView(systemImageName: "trash.circle")
               .onTapGesture {
                    self.userVM.presentation.clear()
                    self.userVM.user.ready = false
                    for (key, _) in self.userVM.users {
                        self.userVM.users[key]!.ready = false
                    }
                    self.userVM.sendClearPresentation()
                    userVM.presentation.nextState()
                }
        case .none:
            CircleButtonView(systemImageName: "paperplane.circle", imageColor: .gray)
        }
        
    }
}

