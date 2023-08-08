//
//  PresentationView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var user: UserViewModel
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
                    ForEach(0..<user.user.presentation.images().count, id: \.self) { i in
                        user.user.presentation.images()[i]
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                self.user.sendIndexToShow(i)
                            }
                    }
                }
            }
            Spacer()
            Button {
                self.user.user.presentation.clear()
                self.user.sendClearPresentation()
                presentationTabManager.nextTab()
            } label: {
                Text("CREATE NEW PRESENTATION")
            }
        }
        .onChange(of: self.user.user.presentation.readyToShow) { newValue in
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
