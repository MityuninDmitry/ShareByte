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
            ImageView(imageData: userVM.user.imageData)
                .onTapGesture {
                    isChangingAvatar = true
                }
                
                
            Text("User id is: \(userVM.user.id)")
            Text("Your current name is:")
            
            TextField("Enter your name", text: $userName)
                .disableAutocorrection(true)
            
            Spacer()
            
            Button {
                userVM.user.name = userName
                userVM.updateUser()
            } label: {
                Text("SAVE")
            }
        }
        .onAppear(perform: {
            userName = userVM.user.name ?? ""
        })
        .padding()
        .sheet(isPresented: $isChangingAvatar) {
            VStack {
                Text("Select your new avatar...")
                    .padding()
                SelectAvatarView()
                    .onDisappear {
                        userName = userVM.user.name ?? "Default name"
                    }
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
            .environmentObject(UserViewModel.shared)
    }
}
