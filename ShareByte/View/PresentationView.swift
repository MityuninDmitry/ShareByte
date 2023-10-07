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
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<userVM.presentation.images().count, id: \.self) { i in
                        userVM.presentation.images()[i]
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                self.userVM.sendIndexToShow(i)
                            }
                    }
                }
            }
            Spacer()
            Button {
                self.userVM.presentation.clear()
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
