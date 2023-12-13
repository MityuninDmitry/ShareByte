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
    
    @State var nameInEditMode = false
    @State var name = "Mr. Foo Bar"
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(userName)")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    Button {
                        userVM.user.name = userName
                        userVM.saveUser()
                    } label: {
                        Image.init(systemName: "arrow.down.doc")
                            .font(.title2)
                            .foregroundStyle(.indigo)
                    }
                }
                .padding([.horizontal], 15)
                .padding(.top, 10)
            
            
            
            ImageView(
                imageData: userVM.user.imageData,
                width: 200,
                height: 200)
            .padding(.top, 15)
            
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
            .padding(.top, 15)
             
            Spacer()
            
            HStack {
                if nameInEditMode {
                    TextField("Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 5)
                        .fontWeight(.semibold)
                        .disableAutocorrection(true)
                } else {
                    Text(userName)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button(action: {
                    self.nameInEditMode.toggle()
                }) {
                    Text(nameInEditMode ? "Done" : "Edit")
                        .fontWeight(.semibold)
                        .foregroundColor(Color.blue)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
            .animation(.easeInOut, value: nameInEditMode)
            
        }
        .onAppear(perform: {
            userName = userVM.user.name ?? ""
        })
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
