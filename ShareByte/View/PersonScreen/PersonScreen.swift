//
//  PersonScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/15/23.
//

import SwiftUI
import PhotosUI

struct PersonScreen: View {
    @State var userName: String = ""
    @EnvironmentObject var userVM: UserViewModel
    @State var isChangingAvatar: Bool = false
    @State var selectedPhotoItems: [PhotosPickerItem] = .init()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showNetworkAlert = false
    
    var body: some View {
        VStack() {
            ImageView(imageData: userVM.user.imageData)
            
            VStack(spacing: 1) {
                Text("Choose avatar from")
                HStack {
                    Spacer()
                    
                    Button {
                        isChangingAvatar = true
                    } label: {
                        Text("Rick and Morty")
                    }
                    .strockedCapsule()
                    .disabled(!networkMonitor.isConnected)
                    
                    Spacer()
                     
                    PhotosPicker("Gallery", selection: $selectedPhotoItems, maxSelectionCount: 1, matching: .images)
                        .strockedCapsule()

                    Spacer()
                }
                .padding(.horizontal, 5)
            }
                
            Text("Your current name is:")
            TextField("Enter your name", text: $userName)
                .disableAutocorrection(true)
                .multilineTextAlignment(.center)
            
            
            Spacer()
            
            Button {
                userVM.user.name = userName
                userVM.saveUser()
            } label: {
                Text("SAVE")
                    .padding(.horizontal, 10)
            }
            .strockedCapsule()
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
                        .padding(.horizontal, 10)
                }
                .strockedCapsule()
            }
        }
        .onChange(of: selectedPhotoItems) { _ in
            Task(priority: .userInitiated) {
                if selectedPhotoItems.count > 0 {
                    if let data = try? await selectedPhotoItems[0].loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data)?.fixedOrientation {
                            userVM.user.imageData = uiImage.reduceImageDataRecursively(uiImage: uiImage, limitSizeInMB: 0.05)!
                        }
                    }
                }
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
