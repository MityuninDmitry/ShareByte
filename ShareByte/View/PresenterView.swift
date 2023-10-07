//
//  PresenterView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI
import PhotosUI

struct PresenterView: View {
    @EnvironmentObject var presentationTabManager: PresentationTabManager
    
    var body: some View {
        VStack {
            switch presentationTabManager.seletedTabId {
            case .Selecting:
                SelectingImageView()
            case .Uploading:
                UploadingToPeersView()
            case .Presentation:
                PresentationView()
            }
           
        }
    }
}

struct PresenterView_Previews: PreviewProvider {
    static var previews: some View {
        PresenterView()
            .environmentObject(UserViewModel())
            .environmentObject(PresentationTabManager.shared)
    }
}
