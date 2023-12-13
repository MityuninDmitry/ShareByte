//
//  ImageView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/15/23.
//

import SwiftUI

struct ImageView: View {
    var imageData: Data?
    var width: CGFloat = 150
    var height: CGFloat = 150
    @State private var imageChanged: Bool = false
    @State private var uiImage: UIImage = UIImage(systemName: "person.circle")!
    @State private var firstAppeared: Bool = true
    @State private var hasImageData: Bool = false
    var body: some View {
        VStack {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(Circle())
                .overlay {
                    if hasImageData {
                        Circle()
                            .stroke(.indigo, lineWidth: 3)
                            .frame(width: width, height: height)
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundStyle(.indigo)
                            .frame(width: width, height: height)
                    }
                    
                }
                .scaleEffect(x: imageChanged ? -1 : 1, y: 1)
        }
        .onAppear(perform: {
            if firstAppeared {
                setUIImage(imageData)
            }
            firstAppeared = false
        })
        .rotation3DEffect(.degrees(imageChanged ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onChange(of: imageData) { newValue in
            setUIImage(newValue)
        }
        
    }
    
    func setUIImage(_ imageData: Data?) {
        withAnimation(.easeInOut(duration: 0.7)) {
            if imageData != nil {
                uiImage = UIImage(data: imageData!)!
                imageChanged.toggle()
                hasImageData = true
            } else {
                uiImage = UIImage(systemName: "person.circle")!
                hasImageData = false
            }
        }
    }
}
