//
//  PersonScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/15/23.
//

import SwiftUI

struct PersonScreen: View {
    @State var userName: String = ""
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        VStack() {
            Text("Your current name is: \(user.user.name ?? "")")
            
            TextField("Enter your name", text: $userName)
            
            Spacer()
            
            Button {
                user.updateUserName(userName)
            } label: {
                Text("SAVE")
            }
        }
        .padding()
    }
}

struct PersonScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonScreen()
            .environmentObject(UserViewModel.shared)
    }
}
