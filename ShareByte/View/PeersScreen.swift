//
//  PeersManagementScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI

struct PeersScreen: View {
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        
        VStack {
            HStack {
                Text(userVM.disoverableStatus.rawValue)
            }
            HStack {
                Spacer()
                Text("\(userVM.user.role?.rawValue ?? "Not defined")")
                    .font(.title)
                Spacer()
                Button {
                    userVM.disconnectAndStopDiscover()
                } label: {
                    Image.init(systemName: "xmark.icloud")
                }
                Button {
                    userVM.makeDiscoverable()
                } label: {
                    Image.init(systemName: "icloud")
                }
            }
            Section("FOUND PEERS") {
                List(Array(userVM.foundUsers.keys), id: \.self) { mcPeerId in
                    Text(mcPeerId.description)
                        .onTapGesture {
                            self.userVM.inviteUser(mcPeerId)
                        }
                }
                .listStyle(.plain)
            }
            Section("CONNECTED PEERS") {
                List(Array(userVM.connectedUsers.keys), id: \.self) { mcPeerId in
                    HStack {
                        //Text(user.connectedUsers[mcPeerId]!.name ?? "\(mcPeerId.description)")
                        Text(userVM.connectedUsers[mcPeerId]!.name ?? "\(mcPeerId.description)")
                        Spacer()
                        Text("\(userVM.connectedUsers[mcPeerId]!.role?.rawValue ?? "UNKNOWN")" )
                    }
                    .onTapGesture {
                        userVM.sendReconnectTo(peers: [mcPeerId])
                    }
                    
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
            .environmentObject(UserViewModel())
    }
}
