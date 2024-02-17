//
//  PeersScreenHeaderView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/16/24.
//

import SwiftUI

struct PeersScreenHeaderView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    @State private var showPremiumView: Bool = false
    @State var uuid: UUID = .init()
    var body: some View {
        VStack(alignment: .center) {
            Text("\(userVM.user.role?.localizedString().uppercased() ?? NSLocalizedString("Not defined role", comment: "") )")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .bottom], 15)
                .padding(.top, 10)
            
            //Text("PRES ID: \(self.userVM.presentation.id)") // FOR TEST PURPOSE
            
            if !purchasedStatus.isPremium {
                if userVM.user.role == .presenter {
                    Text("You can invite only \(Dict.userLimitDefault) users in Default app version.\nPremium app version supports \(Dict.userLimitPremium) users in session.")
                        .font(.caption)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding([.horizontal], 15)
                        .onTapGesture {
                            showPremiumView = true
                        }
                }
            }
        }
        .sheet(isPresented: $showPremiumView, onDismiss: {
            showPremiumView = false

        }) {
            BuyPremiumView()
        }
        
    }
}

#Preview {
    PeersScreenHeaderView()
}
