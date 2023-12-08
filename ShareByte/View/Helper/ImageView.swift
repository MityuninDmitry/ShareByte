//
//  ImageView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/15/23.
//

import SwiftUI

struct ImageView: View {
    var imageData: Data
    var width: CGFloat = 150
    var height: CGFloat = 150
    
    
    var body: some View {
        Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(Circle())
            
    }
}

#Preview {
    ImageView(imageData: UIImage(named: "TestImage")!.pngData()!)
}
