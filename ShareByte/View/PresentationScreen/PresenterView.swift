//
//  PresenterView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI
import PhotosUI

struct PresenterView: View {
    //@EnvironmentObject var presentationTabManager: PresentationTabManager
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack {
            switch userVM.presentation.state {
            case .selecting:
                SelectingImageView()
            case .uploading:
                UploadingToPeersView()
            case .presentation:
                PresentationView()
            case .none:
                SelectingImageView()
            }
           
        }
    }
}

struct PresenterView_Previews: PreviewProvider {
    static var previews: some View {
        PresenterView()
            .environmentObject(UserViewModel.shared)
    }
}
