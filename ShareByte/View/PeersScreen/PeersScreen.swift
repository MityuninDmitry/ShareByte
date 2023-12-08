//
//  PeersManagementScreen.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/8/23.
//

import SwiftUI
import MultipeerConnectivity

struct PeersScreen: View {
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            Text("\(userVM.user.role?.rawValue ?? "Not defined role")")
                .fontWeight(.semibold)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    if userVM.disoverableStatus == .running {
                        Button {
                            userVM.disconnectAndStopDiscover()
                        } label: {
                            Image.init(systemName: "xmark.icloud")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                    } else {
                        Button {
                            userVM.makeDiscoverable()
                        } label: {
                            Image.init(systemName: "icloud")
                                .font(.title2)
                                .foregroundStyle(.indigo)
                        }
                    }
                }
                .padding([.horizontal], 15)
                .padding(.top, 10)
           
            List(Array(userVM.users.keys), id: \.self) { mcPeerId in
                if userVM.users[mcPeerId]!.connected {
                    PeerRowView(
                        userName: (userVM.users[mcPeerId]?.name) ?? "\(mcPeerId.description)",
                        userRole: "\((userVM.users[mcPeerId]?.role?.rawValue) ?? "UNKNOWN ROLE")",
                        userImageData: (userVM.users[mcPeerId]?.imageData) ?? UIImage(systemName: "person.circle")!.pngData()!
                    )
                    .listRowBackground(EmptyView())
                    .onTapGesture {
                        if userVM.user.role == .presenter {
                            userVM.sendReconnectTo(peers: [mcPeerId])
                        }
                        
                    }
                } else {
                    PeerRowView(
                        userName: mcPeerId.displayName,
                        userRole: "UNKNOWN ROLE",
                        userImageData: UIImage( systemName: "person.circle")!.pngData()!
                    )
                    .listRowBackground(EmptyView())
                    .onTapGesture {
                        self.userVM.inviteUser(mcPeerId)
                    }
                }
            }
            .listStyle(.plain)
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
