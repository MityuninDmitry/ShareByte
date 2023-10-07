//
//  PersonScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/15/23.
//

import SwiftUI

struct PersonScreen: View {
    @State var userName: String = ""
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack() {
            Text("User id is: \(userVM.user.id ?? "")")
            Text("Your current name is: \(userVM.user.name ?? "")")
            
            TextField("Enter your name", text: $userName)
            
            Spacer()
            
            Button {
                userVM.updateUserName(userName)
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
            .environmentObject(UserViewModel())
    }
}
