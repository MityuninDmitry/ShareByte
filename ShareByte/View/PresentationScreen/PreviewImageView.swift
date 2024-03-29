//
//  PreviewImageView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/28/23.
//

import SwiftUI
import PhotosUI

struct PreviewImageView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var previewImage: UIImage?
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var index: Int
    var actualizeTools: () -> ()
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            if selectedItems.count == 0 && self.userVM.user.role == .presenter {
                if userVM.user.role == .presenter {
                    Text("Select images for uploading it to users.")
                        .multilineTextAlignment(.center)
                        .frame(width: size.width, height: size.height)
                }
            } else {
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                }
            }
            
        }
        .onChange(of: index) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                self.previewImage = userVM.presentation.imageFiles[newValue].uiImage
                if self.userVM.user.role == .presenter {
                    self.userVM.sendIndexToShow(index)
                }
               
                self.userVM.presentation.indexToShow = newValue
            }
        }
        .onChange(of: userVM.presentation.imageFiles.count) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                if userVM.presentation.imageFiles.count > 0 {
                    self.previewImage = userVM.presentation.imageFiles[0].uiImage
                } else {
                    self.previewImage = nil
                    
                }
            }
            actualizeTools()
        }
        .onAppear {
            if userVM.user.role == .viewer {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if userVM.presentation.imageFiles.count > 0 {
                        self.previewImage = userVM.presentation.imageFiles[0].uiImage
                    } else {
                        self.previewImage = nil
                    }
                }
            }
            
        }
        .padding(.vertical, 15)
    }
}
