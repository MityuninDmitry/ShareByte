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
                    Text("You have no any role at the moment.")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                        .fill(Color("BG").opacity(0.6).gradient)
                        .rotationEffect(.init(degrees: -180))
                        .ignoresSafeArea()
                }
                
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
