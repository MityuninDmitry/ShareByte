//
//  ViewerView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI


struct ViewerView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    private var hasImages: Bool {
        userVM.presentation.images().count > 0
    }
    
    var body: some View {
        VStack {
            if hasImages {
                PresentationImagesView(
                    images: userVM.presentation.images(),
                    tapImageAction: { index in
                        userVM.changePresentationIndexToShow(index)
                    }
                )
            }
            else {
                VStack {
                    Spacer()
                    Text("Waiting for presenter uploads content")
                    ProgressView()
                    Spacer()
                }
            }
        }
        
    }
}

struct ViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewerView()
            .environmentObject(UserViewModel.shared)
    }
}
