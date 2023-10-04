//
//  ViewerView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import SwiftUI

struct ViewerView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(50))]) {
                    ForEach(0..<userVM.presentation.images().count, id: \.self) { i in
                        userVM.presentation.images()[i]
                            .resizable()
                            .frame(width: 50)
                            .onTapGesture {
                                userVM.presentation.indexToShow = i
                            }
                    }
                }
            }
            .frame(height: 50)
            ScrollView {
                if userVM.presentation.imageToShow != nil {
                    userVM.presentation.imageToShow!
                        .resizable()
                        .scaledToFit()
                    
                    
                } else {
                    VStack {
                        
                        Text("NO DATA TO SHOW")
                        
                    }
                    
                }
            }
        }
    }
}

struct ViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ViewerView()
            .environmentObject(UserViewModel.shared)
    }
}
