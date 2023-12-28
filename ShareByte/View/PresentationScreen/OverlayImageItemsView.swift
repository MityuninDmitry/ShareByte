//
//  OverlayImageItemsView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/28/23.
//

import SwiftUI

struct OverlayImageItemsView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var tools: [Tool]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    if userVM.presentation.imageFiles.count > 0 {
                        HStack {
                            Spacer()
                            LikeCounterView(currentLikeCounter: userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0].likedUsers.count) {
                                if userVM.user.role == .viewer {
                                    let imageId = userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0].id
                                    userVM.sendLikeMessage(id: imageId)
                                }
                            }
                            .id(userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0].id)
                        }

                    } else {
                        HStack {
                            Spacer()
                            LikeCounterView(currentLikeCounter: 0) {}
                        }

                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 17)
                
                HStack {
                    ToolBarView(tools: $tools)
                        .padding(.horizontal, 5)
                    Spacer()
                }
                .opacity(userVM.user.role == .presenter ? 1.0 : 0.001)
                
            }
            .padding(.bottom, 133)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

