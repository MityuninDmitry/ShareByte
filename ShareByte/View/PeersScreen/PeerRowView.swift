//
//  PeerRowView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/7/23.
//

import SwiftUI

struct PeerRowView: View {
    var user: User
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            ImageView(
                imageData: user.imageData,
                width: 70,
                height: 70)
            
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(user.name ?? "UNKNOWN NAME")
                    .font(.title2)
                Text(user.role?.rawValue ?? "UNKNOWN ROLE")
                    .font(.callout)
                    .padding(.top, 5)
                Spacer()
            }
            .padding(.leading, 15)
            Spacer()
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
