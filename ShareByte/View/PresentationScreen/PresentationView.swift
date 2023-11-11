//
//  PresentationView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var presentationTabManager: PresentationTabManager
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    
    var cellWidth: CGFloat {
        UIScreen.main.bounds.size.width / CGFloat(columns.count)
    }
    
    var body: some View {
        VStack {
            PresentationImagesView(
                images: userVM.presentation.images(),
                tapImageAction: {
                    index in self.userVM.sendIndexToShow(index)
                }
            )
            Spacer()
            Button {
                self.userVM.presentation.clear()
                self.userVM.user.ready = false
                self.userVM.sendClearPresentation()
                presentationTabManager.nextTab()
            } label: {
                Text("CREATE NEW PRESENTATION")
            }
        }
        .onChange(of: self.userVM.user.ready) { newValue in
            if newValue == false {
                presentationTabManager.nextTab()
            }
        }
        
    }
}

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationView()
            .environmentObject(UserViewModel.shared)
            .environmentObject(PresentationTabManager.shared)
    }
}