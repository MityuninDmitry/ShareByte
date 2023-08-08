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
    
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var presentationTabManager: PresentationTabManager
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<user.user.presentation.images().count, id: \.self) { i in
                        user.user.presentation.images()[i]
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .toolbar {
                PhotosPicker("Select images", selection: $selectedItems, matching: .images)
            }
            .onChange(of: selectedItems) { _ in
                Task {
                    user.user.presentation.clear()
                    
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                let data = uiImage.pngData()!
                                user.user.presentation.imagesData.append(data)
                            }
                        }
                    }
                }
            }
            
            HStack {
                
                    Button {
                        user.sendImagesData()
                        presentationTabManager.nextTab()
                    } label: {
                        Text("Upload data to peers")
                    }
                    .disabled(user.user.presentation.imagesData.count == 0)
                
                
            }
        }
    }
}

struct SelectingImageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingImageView()
            .environmentObject(UserViewModel.shared)
            .environmentObject(PresentationTabManager.shared)
    }
}
