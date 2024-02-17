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
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    
    @State var tools: [Tool] = .init()
    @State private var showPremiumView: Bool = false
    @State private var uuid: UUID = .init()
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            PeersScreenHeaderView()
            
            if userVM.users.count == 0 {
                Spacer()
                Text("ShareByte will show nearby users when any of them open application.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                Spacer()
            } else {
                List(Array(userVM.users.keys), id: \.self) { mcPeerId in
                    if userVM.hasPeer(mcPeerId) {
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
                                    if userVM.connectedUsersCount >= Dict.AppUserDefaults.getUserLimit() && !purchasedStatus.isPremium {
                                        showPremiumView = true
                                    } else if userVM.connectedUsersCount == Dict.AppUserDefaults.getUserLimit() && purchasedStatus.isPremium {
                                        showAlert = true
                                    }
                                    else {
                                        self.userVM.inviteUser(mcPeerId)
                                    }
                                    
                                }
                                
                            }
                    }
                    
                    
                }
                .listStyle(.plain)
            }
            
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
        .sheet(isPresented: $showPremiumView, onDismiss: {
            showPremiumView = false
        }) {
            BuyPremiumView()
        }
        .alert("Connected user limit is reached.", isPresented: $showAlert) {
            Button {
                showAlert = false
            } label: {
                Text("OK")
            }
        }
        
    }
    
    func actualizeTools() {
        if userVM.disoverableStatus == .running {
            tools = [
                .init(icon: "xmark.icloud", name: NSLocalizedString("Disconnect and stop discover", comment: "Отключиться и недоступен для поиска") , color: Dict.appIndigo, action: {
                    userVM.disconnectAndStopDiscover()
                },iconColor: .red)
            ]
        } else {
            tools = [
                .init(icon: "icloud", name: NSLocalizedString("Make discoverable", comment: "Доступен для поиска") , color: Dict.appIndigo, action: {
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
