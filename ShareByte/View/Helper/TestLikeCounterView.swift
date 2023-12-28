//
//  Home.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/24/23.
//

import SwiftUI

struct TestLikeCounterView: View {
    
    @State private var isLiked: [Bool] = [false, false, false]
    @State private var currentLikeCounter: Int = 1
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                LikeCounterView(currentLikeCounter: currentLikeCounter) {
                    print("HELLO")
                }
                
                
                
                Button {
                    currentLikeCounter += 1
                } label: {
                    Text("Add")
                }
                
                Button {
                    if currentLikeCounter > 0 {
                        currentLikeCounter -= 1
                    }
                    
                } label: {
                    Text("Minus")
                }
                
            }
        }
    }
}

#Preview {
    TestLikeCounterView()
        .preferredColorScheme(.dark)
}
