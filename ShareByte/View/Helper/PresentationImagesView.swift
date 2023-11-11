//
//  PresentationImagesView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/10/23.
//

import SwiftUI
import QuickLook

struct PresentationImagesView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    var images: [Image]
    var tapImageAction: ((_ index: Int) -> ())?
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    var cellWidth: CGFloat {
        UIScreen.main.bounds.size.width / CGFloat(columns.count)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<images.count, id: \.self) { i in
                    images[i]
                        .resizable()
                        .frame(width: cellWidth, height: cellWidth, alignment: .center)
                        .scaledToFill()
                        .onTapGesture {
                            if tapImageAction != nil {
                                self.tapImageAction!(i)
                            }
                        }
                }
            }
        }
        .onChange(of: userVM.presentation.imageURL, perform: { value in
            if value == nil {
                userVM.presentation.indexToShow = nil
            }
        })
        .quickLookPreview($userVM.presentation.imageURL)
        
    }
}

#Preview {
    PresentationImagesView(
        images: [
            Image(systemName: "pencil"),
            Image(systemName: "pencil"),
            Image(systemName: "pencil"),
            Image(systemName: "pencil"),
        ],
        tapImageAction: {index in }
    )
}
