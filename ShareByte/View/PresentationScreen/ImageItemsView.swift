//
//  SelectingImageItemsView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/4/23.
//

import SwiftUI
import PhotosUI

struct ImageItemsView: View {
    @State private var index: Int = 0
    @State private var previewImage: UIImage?
    
    @State var selectedItems: [PhotosPickerItem] = .init()
    @EnvironmentObject var userVM: UserViewModel
    
    @State var tools: [Tool] = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("GALLERY \(userVM.presentation.imageFiles.count) / \(selectedItems.count)")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    PhotosPicker(selection: $selectedItems, matching: .images) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .opacity(userVM.presentation.state != .selecting ? 0.0 : 1.0)
                    .opacity(userVM.user.role != .presenter ? 0.0 : 1.0)
                }
                .padding([.horizontal, .bottom], 15)
                .padding(.top, 10)
                .onChange(of: selectedItems) { _ in
                    Task(priority: .medium) {
                        userVM.presentation.clear()
                        for item in selectedItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data)?.fixedOrientation {
                                    let data = uiImage.reducedDataForUploading(uiImage: uiImage)
                                    Task { @MainActor in
                                        await userVM.appendImageToPresentation(data)
                                    }
                                }
                            }
                        }
                        Task { @MainActor in
                            actualizeTools()
                        }
                        
                    }
                }
            
            GeometryReader {
                let size = $0.size
                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                }
            }
            .onChange(of: index) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.previewImage = userVM.presentation.imageFiles[newValue].image
                    if self.userVM.user.role == .presenter {
                        self.userVM.sendIndexToShow(index)
                    }
                }
            }
            .onChange(of: userVM.presentation.imageFiles.count) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    if userVM.presentation.imageFiles.count > 0 {
                        self.previewImage = userVM.presentation.imageFiles[0].image
                    } else {
                        self.previewImage = nil
                        self.selectedItems = []
                    }
                }
                actualizeTools()
            }
            .onAppear {
                if userVM.user.role == .viewer {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if userVM.presentation.imageFiles.count > 0 {
                            self.previewImage = userVM.presentation.imageFiles[0].image
                        } else {
                            self.previewImage = nil
                        }
                    }
                }
                
            }
            .padding(.vertical, 15)
            
            GeometryReader {
                let size = $0.size
                let pageWidth: CGFloat = size.width / 3
                let imageWidth: CGFloat = 100
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(userVM.presentation.imageFiles) { imageFile in
                            ZStack {
                                if let thumbnail = imageFile.thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: imageWidth, height: size.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .frame(width: pageWidth, height: size.height)
                        }
                    }
                    .padding(.horizontal, (size.width - pageWidth) / 2)
                    .background {
                        SnapCarouselHelperView(pageWidth: pageWidth, pageCount: userVM.presentation.imageFiles.count, index: $index)
                        
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(.white, lineWidth: 3)
                        .frame(width: imageWidth, height: size.height)
                        .allowsHitTesting(false)
                }
                .opacity(userVM.user.role == .presenter && selectedItems.count == 0 ? 0.0 : 1.0)
                .onChange(of: userVM.presentation.indexToShow ?? 0) { index in
                    if index < userVM.presentation.imageFiles.count && self.userVM.user.role != .presenter {
                        self.index = index
                    }
                }
                
                
            }
            .frame(height: 120)
            .padding(.bottom, 10)
        }
        .overlay {
            if userVM.user.role == .presenter {
                VStack {
                    ToolBarView(tools: $tools)
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 133)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            } else {
                Color.clear
            }
        }
        .onAppear {
            actualizeTools()
        }
        .onChange(of: userVM.presentation.state) { _ in
            actualizeTools()
        } 

    }
    
    func actualizeTools() {
        if userVM.user.role == .presenter {
            switch userVM.presentation.state {
            case .selecting:
                tools = [
                    .init(
                        icon: "paperplane.circle",
                        name: "Upload images to peers",
                        color: Color("Indigo"),
                        action: {
                            userVM.presentation.nextState()
                            userVM.sendPresentationtToAll()},
                        ignoreAction: userVM.presentation.imageFiles.count != selectedItems.count || selectedItems.count == 0 || userVM.presentation.imageFiles.count == 0
                    )
                ]
            case .uploading:
                tools = [
                    .init(
                        icon: "arrow.clockwise.icloud",
                        name: "Uploading images to peers",
                        color: Color("Indigo"),
                        action: {},
                        ignoreAction: true)
                ]
            case .presentation:
                tools = [
                    .init(
                        icon: "trash.circle",
                        name: "Start new presentation",
                        color: Color("Indigo"),
                        action: {
                            self.userVM.presentation.clear()
                            self.userVM.user.ready = false
                            for (key, _) in self.userVM.users {
                                self.userVM.users[key]!.ready = false
                            }
                            self.userVM.sendClearPresentation()
                            userVM.presentation.nextState()
                        })
                ]
            default:
                tools = .init()
            }
        }
    }
}

#Preview {
    ImageItemsView()
        .preferredColorScheme(.dark)
}
