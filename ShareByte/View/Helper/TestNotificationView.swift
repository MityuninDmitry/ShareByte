//
//  TestNotificationView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/13/24.
//

import SwiftUI

struct TestNotificationView: View {
    @State var count: Int = 0
    
    @State var showNotification: Bool = false
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        VStack {
            Image("Example")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 500)
                
            Spacer()
            Button {
                count += 1
                var user: User = .init()
                user.name = "\(count)"
                let notification = NotificationView(
                    header: "Новый пользователь \(user.name!)",
                    text: "Достигнут предел пользователей в сессии в бесплатной версии приложения. Приобретите премиум версию.",
                    accept: {print("YES \(user.name!)")},
                    decline: {print("NO \(user.name!)")})
                notificationManager.setNewNotification(notification)
                
            } label: {
                Text("SHOW NOTIFICATION")
            }
        }
        .appNotifications()
    }
}

#Preview {
    TestNotificationView()
        .environmentObject(NotificationManager.shared)
        .preferredColorScheme(.dark)
        
}


