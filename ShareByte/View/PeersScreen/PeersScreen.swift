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
 
    @State var tools: [Tool] = .init()
    
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
                    ToolBarView(tools: $tools)
                }
                .padding([.horizontal], 35)
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            actualizeTools()
        }
        .onChange(of: userVM.disoverableStatus) { newValue in
            actualizeTools()
        }
        
    }
    
    func actualizeTools() {
        if userVM.disoverableStatus == .running {
            tools = [
                .init(icon: "xmark.icloud", name: "Disconnect and stop discover", color: Color("Indigo"), action: {
                    userVM.disconnectAndStopDiscover()
                },iconColor: .red)
            ]
        } else {
            tools = [
                .init(icon: "icloud", name: "Make discoverable", color: Color("Indigo"), action: {
                    userVM.makeDiscoverable()
                })
            ]
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
