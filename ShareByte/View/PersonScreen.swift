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
    @State var isChangingAvatar: Bool = false
    
    var body: some View {
        VStack() {
            Image(uiImage: userVM.user.image)
                .resizable()
                .padding()
                .frame(width: 100, height: 100)
                .onTapGesture {
                    isChangingAvatar = true
                }
                
                
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
        .sheet(isPresented: $isChangingAvatar) {
            VStack {
                Text("Select your new avatar...")
                    .padding()
                SelectAvatarView()
                Spacer()
                Button {
                    isChangingAvatar = false
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

struct PersonScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonScreen()
            .environmentObject(UserViewModel())
    }
}
