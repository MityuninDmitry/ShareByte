//
//  UploadingToPeersView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct UploadingToPeersView: View {
    @EnvironmentObject var user: UserViewModel
    @EnvironmentObject var presentationTabManager: PresentationTabManager
    
    var body: some View {
        VStack {
            Spacer()
            Text("UPLOADING ... ")
            Spacer()
            Button {
                self.user.user.presentation.clear()
                self.user.sendClearPresentation()
                presentationTabManager.nextTab()
            } label: {
                Text("CREATE NEW PRESENTATION")
            }
        }
        .onChange(of: user.user.presentation.readyToShow) { newValue in
            print("UPLOADED")
            if newValue == true {
                presentationTabManager.nextTab()
            }
        }
        
    }
}

struct UploadingToPeersView_Previews: PreviewProvider {
    static var previews: some View {
        UploadingToPeersView()
            .environmentObject(UserViewModel.shared)
            .environmentObject(PresentationTabManager.shared)
    }
}
