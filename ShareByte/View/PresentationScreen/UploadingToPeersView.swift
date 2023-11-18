//
//  UploadingToPeersView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct UploadingToPeersView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Text("UPLOADING")
            ProgressView()
            Spacer()
            Button {
                self.userVM.presentation.clear()
                self.userVM.sendClearPresentation()
                userVM.presentation.nextState()
            } label: {
                Text("CREATE NEW PRESENTATION")
            }
            .strockedCapsule()
        }
        .onChange(of: userVM.user.ready) { newValue in
            if newValue == true {
                userVM.presentation.nextState()
            }
        }
        
    }
}

struct UploadingToPeersView_Previews: PreviewProvider {
    static var previews: some View {
        UploadingToPeersView()
            .environmentObject(UserViewModel.shared)
    }
}
