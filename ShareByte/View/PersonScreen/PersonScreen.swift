//
//  PersonScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/15/23.
//

import SwiftUI
import PhotosUI

struct PersonScreen: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var isChangingAvatar: Bool = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showNetworkAlert = false
    
    @State var radius: CGFloat = 15
    
    @State private var showImagePicker: Bool = false
    @State private var croppedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            EditNameView()
            
            Spacer()
            
            ImageView(
                imageData: userVM.user.imageData,
                width: 300,
                height: 300)
            .shadow(color: Color("Indigo"), radius: radius)
            .onAppear {
                withAnimation(.linear.repeatForever(autoreverses: true).speed(0.1)) {
                    radius = 30
                }
            }
            
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button {
                        isChangingAvatar = true
                    } label: {
                        CircleButtonView(systemImageName: "bonjour")
                    }
                    .disabled(!networkMonitor.isConnected)
                    
                    Spacer()
                    
                    
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        CircleButtonView(systemImageName: "folder")
                    }
                    .croppImagePicker(show: $showImagePicker, croppedImage: $croppedImage)
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
            .padding(.top, 50)
            
            Spacer()
            
        }
        .sheet(isPresented: $isChangingAvatar) {
            VStack {
                Text("Select your new avatar...")
                    .padding()
                SelectAvatarView()
                    .onDisappear {
                        userVM.saveUser()
                    }
                Spacer()
            }
        }
        .onChange(of: croppedImage) { _ in
            if let croppedImage {
                userVM.user.imageData = croppedImage.fixedOrientation.reduceImageDataRecursively(uiImage: croppedImage, limitSizeInMB: 0.5)
                userVM.saveUser()
            }
            
        }
        .onChange(of: networkMonitor.isConnected) { connection in
            showNetworkAlert = connection == false
        }
        .alert("No internet connection.", isPresented: $showNetworkAlert) {}
    }
}

struct PersonScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonScreen()
            .environmentObject(UserViewModel.shared)
    }
}
