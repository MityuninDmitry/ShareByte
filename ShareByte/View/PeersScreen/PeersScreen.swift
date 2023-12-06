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
                Text("Status: \(userVM.disoverableStatus.rawValue)")
            }
            HStack {
                Spacer()
                Text("Your role is: \(userVM.user.role?.rawValue ?? "Not defined")")
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
                    Text(mcPeerId.displayName)
                        .onTapGesture {
                            self.userVM.inviteUser(mcPeerId)
                        }
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                
                
            }
            
            Section("CONNECTED PEERS") {
                List(Array(userVM.connectedUsers.keys), id: \.self) { mcPeerId in
                    HStack {
                        ImageView(
                            imageData: (userVM.connectedUsers[mcPeerId]?.imageData) ?? UIImage(systemName: "person.circle")!.pngData()!,
                            width: 100,
                            height: 100)
                        Text((userVM.connectedUsers[mcPeerId]?.name) ?? "\(mcPeerId.description)")
                        Spacer()
                        Text("\((userVM.connectedUsers[mcPeerId]?.role?.rawValue) ?? "UNKNOWN ROLE")" )
                    }
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        if userVM.user.role == .presenter {
                            userVM.sendReconnectTo(peers: [mcPeerId])
                        }
                        
                    }
                    
                }
                .listStyle(.plain)
                
            }
            
        }
        .background {
            Rectangle()
                .fill(Color("BG").opacity(0.6).gradient)
                .rotationEffect(.init(degrees: -180))
                .ignoresSafeArea()
        }
    }
}

struct PeersScreen_Previews: PreviewProvider {
    static var previews: some View {
        PeersScreen()
            .environmentObject(UserViewModel.shared)
    }
}
