//
//  PeerRowView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/7/23.
//

import SwiftUI

struct PeerRowView: View {
    var userName: String
    var userRole: String
    var userImageData: Data
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ImageView(
                imageData: userImageData,
                width: 70,
                height: 70)
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(userName)
                    .font(.title2)
                Text(userRole)
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
    PeerRowView(userName: "Dmitry Mityunin", userRole: Role.presenter.rawValue, userImageData: UIImage(named: "TestImage")!.pngData()!)
}
