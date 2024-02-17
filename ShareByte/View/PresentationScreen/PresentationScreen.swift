//
//  PresentationScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI



struct PresentationScreen: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack {
            if userVM.user.role == .presenter {
                PresenterView()
            } else if userVM.user.role == .viewer {
                ViewerView()
            } else {
                VStack {
                    Spacer()
                    Text("If you want to demonstrate your images, tap users to become presenter.")
                        .multilineTextAlignment(.center)
                    Text("If you want to view somebody presentation, accept invitation from another user.")
                        .multilineTextAlignment(.center)
                        .padding(.top, 15)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
            }
        }
        
        
        
        
    }
}

struct PresentationScreen_Previews: PreviewProvider {
    static var previews: some View {
        PresentationScreen()
            .environmentObject(UserViewModel.shared)
    }
}
