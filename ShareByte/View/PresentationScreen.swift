//
//  PresentationScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI



struct PresentationScreen: View {
 
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        VStack {
            // hello
            //if user.user.role != .viewer {
            if user.user.role == .presenter {
                PresenterView()
            } else if user.user.role == .viewer {
                ViewerView()
            } else {
                Text("NO DATA TO SHOW")
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
