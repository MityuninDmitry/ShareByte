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
    private var hasImageFiles: Bool {
        userVM.presentation.imageFiles.count > 0
    }
    
    var body: some View {
        VStack {
            if hasImageFiles {
                ScreenShotPreventView {
                    ImageItemsView()
                }
                
            }
            else {
                VStack {
                    Spacer()
                    Text("Waiting for presenter uploads content")
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
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
