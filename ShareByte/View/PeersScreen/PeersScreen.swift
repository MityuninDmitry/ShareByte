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
        .overlay {
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                HStack {
                    Spacer()
                    if userVM.disoverableStatus == .running {
                        Button {
                            userVM.disconnectAndStopDiscover()
                        } label: {
                            CircleButtonView(
                                systemImageName: "xmark.icloud",
                                imageColor: .red)
                                
                        }
                    } else {
                        Button {
                            userVM.makeDiscoverable()
                        } label: {
                            CircleButtonView(systemImageName: "icloud")
                        }
                    }
                }
                .padding([.horizontal], 25)
                .padding(.bottom, 15)
            }
        }
        
    }
}

struct PeersScreen_Previews: PreviewProvider {
    static var previews: some View {
        PeersScreen()
            .environmentObject(UserViewModel.shared)
            .preferredColorScheme(.dark)
    }
}
