//
//  SelectAvatarView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/11/23.
//

import SwiftUI

struct SelectAvatarView: View {
    @ObservedObject var searchAvatar: SearchAvatar = .init()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(self.searchAvatar.rickAndMorty?.results ?? [], id: \.self) { avatar in
                        VStack {
                            AsyncImage(
                                url: URL(string:avatar.image),
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 100, maxHeight: 100)
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            )
                            
                            Text("\(avatar.name)")
                        }
                    }
                }
            }
            HStack {
                Button {
                    
                } label: {
                    Text("Previous page")
                }
                
                Button {
                    searchAvatar.setNextPage()
                    searchAvatar.loadRickAndMorty()
                } label: {
                    Text("Next page")
                }.disabled(self.searchAvatar.rickAndMorty?.info.next == nil)
            }
        }
        .onAppear {
            searchAvatar.loadRickAndMorty()
        }
        
        
    }
}

#Preview {
    SelectAvatarView()
}
