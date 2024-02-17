//
//  PresenterView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI
import PhotosUI

struct PresenterView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        ImageItemsView()
            
            
    }
}

struct PresenterView_Previews: PreviewProvider {
    static var previews: some View {
        PresenterView()
            .environmentObject(UserViewModel.shared)
    }
}


