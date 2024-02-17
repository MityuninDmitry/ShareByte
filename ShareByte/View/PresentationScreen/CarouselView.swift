//
//  CarouselView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/28/23.
//

import SwiftUI
import PhotosUI

struct CarouselView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    @Binding var selectedItems:  [PhotosPickerItem]
    @Binding var index: Int
    
    var lock: NSLock = .init()
    
    var body: some View {
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
            .disabled(self.userVM.presentation.state == .preparing || self.userVM.presentation.state == .uploading)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: imageWidth, height: size.height)
                    .allowsHitTesting(false)
            }
            .opacity(userVM.user.role == .presenter && self.userVM.presentation.state == .selecting ? 0.0 : 1.0)
            .onChange(of: userVM.presentation.indexToShow ?? 0) { index in
                lock.lock()
                if index < userVM.presentation.imageFiles.count && self.userVM.user.role != .presenter {
                    self.index = index
                    if !purchasedStatus.isPremium {
                        if index >= Dict.imageLimitDefault {
                            Task {
                                try await Task.sleep(for: .seconds(0.7))
                                Task { @MainActor in
                                    self.index = Dict.imageLimitDefault - 1
                                }
                            }
                        }
                    }
                    
                    
                }
                lock.unlock()
            }
        }
        .frame(height: 120)
        .padding(.bottom, 10)
    }
}
