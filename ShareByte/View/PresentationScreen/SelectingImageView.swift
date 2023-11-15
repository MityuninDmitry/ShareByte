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
            PresentationImagesView(
                images: userVM.presentation.images(),
                tapImageAction: {index in userVM.changePresentationIndexToShow(index)}
            )
            .toolbar {
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
            }
            .onChange(of: selectedItems) { _ in
                Task {
                    userVM.presentation.clear()
                    
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data)?.fixedOrientation {
                                let data = uiImage.pngData()!
                                userVM.appendImageToPresentation(data)
                            }
                        }
                    }
                    
                }
            }
            
            HStack {
                    Button {
                        userVM.presentation.nextState()
                        userVM.sendPresentation(to: [])
                    } label: {
                        Text("Upload data to peers")
                    }
                    .disabled(userVM.presentation.imagesData.count == 0)
                
                
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
