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
    
    var body: some View {
        PresentationImagesView(
            images: userVM.presentation.images(),
            tapImageAction: { index in
                userVM.changePresentationIndexToShow(index)
            }
        )
    }
}

struct ViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewerView()
            .environmentObject(UserViewModel.shared)
    }
}
