//
//  PersonScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/15/23.
//

import SwiftUI
import PhotosUI

struct PersonScreen: View {
    enum FocusedField {
        case userName
    }
    
    @State var userName: String = ""
    @EnvironmentObject var userVM: UserViewModel
    @State var isChangingAvatar: Bool = false
    @State var selectedPhotoItems: [PhotosPickerItem] = .init()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showNetworkAlert = false
    
    @State var nameInEditMode = false
    @FocusState private var focusedField: FocusedField?
    
    @State var tools: [Tool] = .init()
    
    var body: some View {
        VStack(spacing: 0) {

            Group {
                if nameInEditMode {
                    TextField("Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .fontWeight(.semibold)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .focused($focusedField, equals: .userName)
                        .onAppear {
                            focusedField = .userName
                        }
                        .onDisappear {
                            focusedField = nil
                        }
                        
                } else {
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 15)
                        //.padding(.top, 10)
                }
            }
            
            

            
            ImageView(
                imageData: userVM.user.imageData,
                width: 250,
                height: 250)
            .padding(.top, 15)
            
            
            VStack(spacing: 1) {
                
                HStack {
                    Spacer()
                    
                    Button {
                        isChangingAvatar = true
                    } label: {
                        CircleButtonView(systemImageName: "bonjour")
                    }
                    .disabled(!networkMonitor.isConnected)
                    
                    Spacer()
                    
                    PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 1, matching: .images) {
                        CircleButtonView(systemImageName: "folder")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
            .padding(.top, 15)
            
            Spacer()
            
        }
        .onAppear(perform: {
            userName = userVM.user.name ?? ""
            actualizeTools()
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
        .overlay {
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                HStack {
                    Spacer()
                    ToolBarView(tools: $tools)
                }
                .padding([.horizontal], 35)
                .padding(.bottom, 15)
            }
        }
        .onChange(of: nameInEditMode) { newValue in
            actualizeTools()
        }
        .onChange(of: networkMonitor.isConnected) { _ in
            actualizeTools()
        }
        
        .alert("No internet connection.", isPresented: $showNetworkAlert) {}
    }
    
    func actualizeTools() {
        if nameInEditMode {
            tools = [
                .init(icon: "pencil.slash", name: "Done edit user name", action: {
                    nameInEditMode = false
                }),
                .init(icon: "arrow.down.doc", name: "Save changes", action: {
                    nameInEditMode = false
                    userVM.user.name = userName
                    userVM.saveUser()
                })
            ]
        } else {
            tools = [
                .init(icon: "pencil", name: "Edit user name", action: {
                    nameInEditMode = true
                }),
                .init(icon: "arrow.down.doc", name: "Save changes", action: {
                    nameInEditMode = false
                    userVM.user.name = userName
                    userVM.saveUser()
                })
            ]
        }
    }
}

struct PersonScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonScreen()
            .environmentObject(UserViewModel.shared)
    }
}
