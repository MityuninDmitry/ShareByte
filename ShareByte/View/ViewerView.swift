//
//  ViewerView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct ViewerView: View {
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        ScrollView {
            if user.user.presentation.imageToShow != nil {
                user.user.presentation.imageToShow!
                    .resizable()
                    .scaledToFit()
                
            } else {
                VStack {
                    
                    Text("NO DATA TO SHOW")
                    
                }
                
            }
        }
        
        
        
    }
}

struct ViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewerView()
            .environmentObject(UserViewModel.shared)
    }
}
