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
            Image(systemName: "paperplane.circle")
                .font(.title2)
                .foregroundStyle(userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0 ? .gray : .blue)
                .disabled(userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0)
                .onTapGesture {
                    userVM.presentation.nextState()
                    userVM.sendPresentationtToAll()
                }
        case .uploading:
            ProgressView()
        case .presentation:
            Image(systemName: "trash.circle")
                .font(.title2)
                .foregroundStyle(.gray)
                .onTapGesture {
                    self.userVM.presentation.clear()
                    self.userVM.user.ready = false
                    for (key, _) in self.userVM.connectedUsers {
                        self.userVM.connectedUsers[key]!.ready = false
                    }
                    self.userVM.sendClearPresentation()
                    userVM.presentation.nextState()
                }
        case .none:
            Image(systemName: "paperplane.circle")
                .font(.title2)
                .foregroundStyle(.gray)
        }
        
    }
}

