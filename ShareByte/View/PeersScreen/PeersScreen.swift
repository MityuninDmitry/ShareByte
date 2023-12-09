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
            Text("\(userVM.user.role?.rawValue.uppercased() ?? "Not defined role")")
                .fontWeight(.semibold)
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
                PeerRowView(user: userVM.users[mcPeerId]!)
                    .listRowBackground(EmptyView())
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        if userVM.users[mcPeerId]!.connected {
                            if userVM.user.role == .presenter {
                                userVM.sendReconnectTo(peers: [mcPeerId])
                            }
                        }
                        else {
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
