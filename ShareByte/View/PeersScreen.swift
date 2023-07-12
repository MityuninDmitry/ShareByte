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
                Text("\(user.type?.rawValue ?? "Not defined")")
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
                List(user.foundUsers, id: \.self) { userInfo in
                    Text(userInfo.name ?? "\(userInfo.mcPeerId)")
                        .onTapGesture {
                            self.user.inviteUser(userInfo)
                        }
                }
                .listStyle(.plain)
            }
            Section("CONNECTED PEERS") {
                List(user.connectedUsers, id: \.self) { userInfo in
                    Text(userInfo.name ?? "\(userInfo.mcPeerId)")
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
