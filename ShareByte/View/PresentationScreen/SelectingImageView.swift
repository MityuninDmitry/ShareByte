//
//  SelectingImageView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI
import PhotosUI

struct SelectingImageView: View {
    @State var selectedItems: [PhotosPickerItem] = .init()
    
    @EnvironmentObject var userVM: UserViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var cellWidth: CGFloat {
        UIScreen.main.bounds.size.width / CGFloat(columns.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                PresentationImagesView(
                    images: userVM.presentation.images(),
                    tapImageAction: {index in userVM.changePresentationIndexToShow(index)}
                )
                .toolbar {
                    Text("\(userVM.presentation.imagesData.count) / \(selectedItems.count)")
                    PhotosPicker("Select images", selection: $selectedItems, matching: .images)
                }
                .onChange(of: selectedItems) { _ in
                    Task(priority: .medium) {
                        userVM.presentation.clear()
                        for item in selectedItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data)?.fixedOrientation {
                                    Task {
                                        let data = uiImage.reducedDataForUploading(uiImage: uiImage)
                                        Task { @MainActor in
                                            userVM.appendImageToPresentation(data)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Button {
                            userVM.presentation.nextState()
                            userVM.sendPresentationtToAll()
                        } label: {
                            Text("Upload data to peers")
                        }
                        .disabled(userVM.presentation.imagesData.count == 0 || userVM.presentation.imagesData.count != selectedItems.count)
                    }
                    .strockedFilledCapsule()
                    .padding(.bottom, 5)
                }
                
                
            }
            
        }
        
    }
}

struct SelectingImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingImageView()
            .environmentObject(UserViewModel.shared)
    }
}
