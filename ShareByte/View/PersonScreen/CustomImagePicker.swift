//
//  CustomImagePicker.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/18/23.
//

import SwiftUI
import PhotosUI


extension View {
    @ViewBuilder
    func croppImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        CustomImagePicker(show: show, croppedImage: croppedImage) {
            self
        }
    }
    
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        self
            .frame(width: size.width, height: size.height)
    }
    
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}


fileprivate struct CustomImagePicker<Content: View>: View {
    var content: Content
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?
    
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }
    
    @State private var photosItems: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCropView: Bool = false
    @State private var confirmImage: Bool = false
    @State private var uuid: UUID = .init()
    
    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItems, matching: .images)
            .onChange(of: photosItems) { newValue in
                if let newValue {
                    Task(priority: .userInitiated) {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                            await MainActor.run {
                                selectedImage = image
                                //confirmImage = true
                                uuid = UUID()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showCropView = true
                                }
                                
                                
                            }
                        }
                    }
                }
            }
            .id(uuid)
//            .confirmationDialog("", isPresented: $confirmImage, actions: {
//                Button {
//                    showCropView = true
//                } label: {
//                    Text("Confirm image")
//                }
//                
//            })
            .fullScreenCover(isPresented: $showCropView) {
                selectedImage = nil
                photosItems = nil
                showCropView = false
            } content: {
                CropView(image: selectedImage) { croppedImage, status in
                    if let croppedImage {
                        self.croppedImage = croppedImage
                    }
                }
            }
    }
}

struct CropView: View {
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View {
        NavigationStack {
            CropImageView()
                .navigationTitle("Crop image")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("BG").gradient, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    Circle()
                        .stroke(.indigo, lineWidth: 3)
                        .frame(width: 300, height: 300)
                }
                .background {
                    Color("BG")
                        .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            let renderer = ImageRenderer(content: CropImageView(true))
                            renderer.proposedSize = .init(width: 300, height: 300)
                            if let image = renderer.uiImage {
                                onCrop(image, true)
                            } else {
                                onCrop(nil, false)
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
        
    }
    
    @ViewBuilder
    func CropImageView(_ hideGrids: Bool = false) -> some View {
        let cropSize = CGSize(width: 300, height: 300)
        ZStack {
            GeometryReader {
                let size = $0.size
                
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            GeometryReader { proxy in
                                let rect = proxy.frame(in: .named("CROPVIEW"))
                                
                                Color.clear
                                    .onChange(of: isInteracting) { newValue in
                                       
                                        if !newValue {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                if rect.minX > 0 {
                                                    offset.width = (offset.width - rect.minX)
                                                    haptics(.medium)
                                                }
                                                if rect.minY > 0 {
                                                    offset.height = (offset.height - rect.minY)
                                                    haptics(.medium)
                                                }
                                                
                                                if rect.maxX < size.width {
                                                    offset.width = (rect.minX - offset.width)
                                                    haptics(.medium)
                                                }
                                                
                                                if rect.maxY < size.height {
                                                    offset.height = (rect.minY - offset.height)
                                                    haptics(.medium)
                                                }
                                            }
                                            lastStoredOffset = offset
                                           
                                        }
                                    }
                            }
                            
                        }
                        .frame(size)
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                DragGesture()
                    .updating($isInteracting, body:  { _, out, _ in
                        out = true
                    }).onChanged({ value in
                        let translation = value.translation
                        offset = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
                    })
            )
            .gesture(
                MagnificationGesture()
                    .updating($isInteracting, body: { _, out, _ in
                         out = true
                    }).onChanged({ value in
                        let updatedScale = value + lastScale
                        scale = (updatedScale < 1 ? 1 : updatedScale)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if scale < 1 {
                                scale = 1
                                lastScale = 0
                            } else {
                                lastScale = scale - 1
                            }
                        }
                    })
            )
            .frame(cropSize)
            .coordinateSpace(name: "CROPVIEW")
            .cornerRadius(cropSize.height / 2)
            
            if !hideGrids {
                Grids()
                    .cornerRadius(cropSize.height / 2)
                    .frame(cropSize)
            }
        }
        
    }
    
    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            
            VStack {
                ForEach(1...5, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    CropView(image: UIImage(named: "TestImage")!) { image, state in
        
    }
}
