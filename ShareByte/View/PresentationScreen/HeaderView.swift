//
//  HeaderView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/28/23.
//

import SwiftUI
import PhotosUI

struct HeaderView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var index: Int
    var actualizeTools: () -> ()
    @State private var showPremiumView: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(userVM.user.role == .presenter ? "GALLERY \(userVM.presentation.imageFiles.count) / \(selectedItems.count)" : "Image \(index + 1)")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .center) {
                    switch userVM.presentation.state {
                    case .selecting, .prepared:
                        HStack {
                            Spacer()
                            PhotosPicker(selection: $selectedItems, maxSelectionCount: Dict.AppUserDefaults.getImageLimit() , matching: .images) {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.gray)
                            }
                            .opacity(userVM.user.role != .presenter ? 0.0 : 1.0)
                        }
                    case .preparing:
                        HStack {
                            Spacer()
                            ProgressView()
                        }
                    case .uploading:
                        HStack {
                            Spacer()
                            EmptyView()
                        }
                    case .presentation:
                        HStack {
                            ShareLink(items: userVM.presentation.imageFiles) { imageFile in
                                return SharePreview("Images", image: Image(uiImage: UIImage(data: userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0].imageData!)!))
                            } label: {
                                Label("All",systemImage: "square.and.arrow.up")
                                    .foregroundStyle(.indigo)
                            }
                            Spacer()
                            ShareLink(
                                item: userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0],
                                preview:
                                    SharePreview("Image", image: Image(uiImage: UIImage(data: userVM.presentation.imageFiles[userVM.presentation.indexToShow ?? 0].imageData!)!))) {
                                        Label("Image \((userVM.presentation.indexToShow ?? 1) + 1)", systemImage: "square.and.arrow.up")
                                            .foregroundStyle(.indigo)
                                    }
                        }
                    }
                    
                }
                .id(self.userVM.presentation.state)
                .padding([.horizontal, .bottom], 15)
                .padding(.top, 10)
                .onChange(of: selectedItems) { newItems in
                    guard newItems.count != 0 else {return}
                    
                    Task { @MainActor in
                        userVM.presentation.setState(.preparing)
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data)?.fixedOrientation {
                                    let data = uiImage.reducedDataForUploading(uiImage: uiImage)
                                    await userVM.appendImageToPresentation(data)
                                }
                            }
                        }
                        index = 0
                        userVM.presentation.setState(.prepared)
                        actualizeTools()
                    }
                    
                }
            
            if !purchasedStatus.isPremium {
                if userVM.user.role == .presenter {
                    Text("You can select only \(Dict.imageLimitDefault) images in Default app version.\nPremium app version supports \(Dict.imageLimitPremium) images.")
                        .font(.caption)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .onTapGesture {
                            showPremiumView = true
                        }
                        .padding([.horizontal], 15)
                } else {
                    Text("You can view only first \(Dict.imageLimitDefault) images in Default app version.\nPremium app version supports \(Dict.imageLimitPremium) images.")
                        .font(.caption)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .onTapGesture {
                            showPremiumView = true
                        }
                        .padding([.horizontal], 15)
                }
               
            }
            
        }
        .sheet(isPresented: $showPremiumView, onDismiss: {
            showPremiumView = false
        }) {
            BuyPremiumView()
        }
        
    }
}
