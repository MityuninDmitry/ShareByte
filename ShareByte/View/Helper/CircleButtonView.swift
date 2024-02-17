//
//  CircleButtonView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/11/23.
//

import SwiftUI

struct CircleButtonView: View {
    @State private var activeColor: Color = Dict.appIndigo
    var systemImageName: String?
    var imageColor: Color = .white
    
    var body: some View {
        Circle()
            .fill(activeColor.gradient)
            .foregroundStyle(activeColor)
            .frame(width: 58, height: 58)
            .overlay {
                if let systemImageName {
                    Image(systemName: systemImageName)
                        .font(.title2)
                        .foregroundStyle(imageColor)
                }
                
            }
    }
}

#Preview {
    CircleButtonView()
        .preferredColorScheme(.dark)
}
