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
    @State private var showNetworkAlert = false
    
    @State var radius: CGFloat = 15
    
    @State private var showImagePicker: Bool = false
    @State private var croppedImage: UIImage?
    @State private var showAppSettings: Bool = false
    @State var tools: [Tool] = .init()
    
    
    var body: some View {
        VStack(spacing: 0) {
            EditNameView()
            
            Spacer()
            
            ImageView(
                imageData: userVM.user.imageData,
                width: 300,
                height: 300)
            .shadow(color: Dict.appIndigo, radius: radius)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.linear.repeatForever(autoreverses: true).speed(0.1)) {
                        radius = 30
                    }
                }
                
            }
            .onTapGesture(perform: {
                showImagePicker.toggle()
            })
            .croppImagePicker(show: $showImagePicker, croppedImage: $croppedImage)
            
            Spacer()
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
        .onAppear {
            actualizeTools()
        }
        .onChange(of: croppedImage) { _ in
            if let croppedImage {
                userVM.user.imageData = croppedImage.fixedOrientation.reduceImageDataRecursively(uiImage: croppedImage, limitSizeInMB: 0.5)
                userVM.saveUser()
            }
        }
        .sheet(isPresented: $showAppSettings) {
            showAppSettings = false
        } content: {
            AppSettingsView()
                .background {
                    Rectangle()
                        .fill(Color("BG").opacity(0.6).gradient)
                        .rotationEffect(.init(degrees: -180))
                        .ignoresSafeArea()
                }
        }

    }
    
    func actualizeTools() {
        tools = [
           .init(icon: "gearshape", name: NSLocalizedString("Show settings", comment: "Открыть настройки") , action: {
               showAppSettings = true
           }, position: .right)
       ]
    }
}

struct PersonScreen_Previews: PreviewProvider {
    static var previews: some View {
        PersonScreen()
            .environmentObject(UserViewModel.shared)
    }
}
