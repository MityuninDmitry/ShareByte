//
//  SelectAvatarView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/11/23.
//

import SwiftUI

struct SelectAvatarView: View {
    @EnvironmentObject var searchAvatar: SearchAvatar 
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(self.searchAvatar.rickAndMortyItems, id: \.self) { avatar in
                        VStack {
                            AsyncImage(
                                url: URL(string:avatar.image),
                                content: { image in                                    
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 100, maxHeight: 100)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(.indigo, lineWidth: 3)
                                                .frame(width: 100, height: 100)
                                        }
                                },
                                placeholder: {
                                    ProgressView()
                                }
                                
                            )
                            .onTapGesture {
                                let url = URL(string: avatar.image)
                                Task { @MainActor in
                                    userVM.user.imageData = await downloadPhoto(url: url!)!
                                    userVM.user.name = avatar.name
                                    userVM.saveUser()
                                }
                                
                                
                                dismiss()
                            }
                            Text("\(avatar.name)")
                        }
                        .onAppear {
                            if self.searchAvatar.rickAndMortyItems.isLastItem(avatar) {
                                searchAvatar.setNextPage()
                                searchAvatar.loadRickAndMorty()
                            }
                        }
                    }
                    
                }
            }
           
        }
        .onAppear {
            searchAvatar.loadRickAndMorty()
        }
        
        
    }
    
    func downloadPhoto(url: URL) async -> Data? {
        async let data = try? Data(contentsOf: url)
        if await data != nil {
                //return await UIImage(data: data!)!
                return await data!
        }
        
        return nil
    }
}

#Preview {
    SelectAvatarView()
}
