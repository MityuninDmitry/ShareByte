//
//  PeerRowView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/7/23.
//

import SwiftUI

struct PeerRowView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    var user: User

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            ImageView(
                imageData: user.imageData,
                width: 70,
                height: 70)
            
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(user.name ?? NSLocalizedString("UNKNOWN NAME", comment: "") )
                    .font(.title2)
                Text(user.role?.localizedString() ?? NSLocalizedString("UNKNOWN ROLE", comment: ""))
                    .font(.callout)
                    .foregroundStyle(user.role == .presenter ? .red : .indigo)
                    .padding(.top, 5)
                Spacer()
            }
            .padding(.leading, 15)
            
            Spacer()
            if user.connected {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(user.ready ? "READY" : "")
                        .font(.callout)
                        .foregroundStyle(.indigo)
                        .padding(.top, 5)
                    Spacer()
                }
                .padding(.leading, 15)
            } else {
                if userVM.connectedUsersCount >= Dict.AppUserDefaults.getUserLimit() && !purchasedStatus.isPremium {
                    VStack {
                        Spacer()
                        Image(systemName: "dollarsign.circle")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Spacer()
                    }
                    
                }
            }
            
        }
        .frame(height: 70)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

#Preview {
    PeerRowView(
        user: User.init()
    )
}
