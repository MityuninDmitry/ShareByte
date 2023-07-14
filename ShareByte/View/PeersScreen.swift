//
//  PeersManagementScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI

struct PeersScreen: View {
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Text("\(user.userInfo.type?.rawValue ?? "Not defined")")
                    .font(.title)
                Spacer()
                Button {
                    user.disconnectAndStopDiscover()
                } label: {
                    Image.init(systemName: "xmark.icloud")
                }
                Button {
                    user.makeDiscoverable()
                } label: {
                    Image.init(systemName: "icloud")
                }
            }
            Section("FOUND PEERS") {
                List(Array(user.foundUsers.keys), id: \.self) { mcPeerId in
                    Text(mcPeerId.description)
                        .onTapGesture {
                            self.user.inviteUser(mcPeerId)
                        }
                }
                .listStyle(.plain)
            }
            Section("CONNECTED PEERS") {
                List(Array(user.connectedUsers.keys), id: \.self) { mcPeerId in
                    Text(user.connectedUsers[mcPeerId]!.name ?? "\(mcPeerId.description)" )
                }
                .listStyle(.plain)
            }
            
        }
        .padding()
    }
}

struct PeersScreen_Previews: PreviewProvider {
    static var previews: some View {
        PeersScreen()
            .environmentObject(UserViewModel.shared)
    }
}
