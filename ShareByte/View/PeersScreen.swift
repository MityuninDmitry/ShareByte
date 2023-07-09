//
//  PeersManagementScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI

struct PeersScreen: View {
    @StateObject var peerManager: PeerManagerViewModel = .init()
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Text("\(peerManager.user.type?.rawValue ?? "Not defined")")
                    .font(.title)
                Spacer()
                Button {
                    peerManager.disconnect()
                } label: {
                    Image.init(systemName: "xmark.icloud")
                }
                Button {
                    peerManager.discover()
                } label: {
                    Image.init(systemName: "icloud")
                }
            }
            Section("FOUND PEERS") {
                List(peerManager.foundPeers, id: \.self) { peerId in
                    Text("\(peerId.displayName)")
                        .onTapGesture {
                            peerManager.invitePeer(peerId)
                        }
                }
                .listStyle(.plain)
            }
            Section("CONNECTED PEERS") {
                List(peerManager.connectedPeers, id: \.self) { peerId in
                    Text("\(peerId.displayName)")
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
    }
}
