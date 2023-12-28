//
//  HeaderView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/28/23.
//

import SwiftUI
import PhotosUI

struct HeaderView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedItems: [PhotosPickerItem]
    var actualizeTools: () -> ()
    
    var body: some View {
        Text("GALLERY \(userVM.presentation.imageFiles.count) / \(selectedItems.count)")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
                .opacity(userVM.presentation.state != .selecting ? 0.0 : 1.0)
                .opacity(userVM.user.role != .presenter ? 0.0 : 1.0)
            }
            .padding([.horizontal, .bottom], 15)
            .padding(.top, 10)
            .onChange(of: selectedItems) { _ in
                Task(priority: .medium) {
                    userVM.presentation.clear()
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data)?.fixedOrientation {
                                let data = uiImage.reducedDataForUploading(uiImage: uiImage)
                                Task { @MainActor in
                                    await userVM.appendImageToPresentation(data)
                                }
                            }
                        }
                    }
                    Task { @MainActor in
                        actualizeTools()
                    }
                    
                }
            }
    }
}
