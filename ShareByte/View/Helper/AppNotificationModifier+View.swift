//
//  AppNotificationModifier+View.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/16/24.
//

import SwiftUI

struct AppNotificationModifier: ViewModifier {
    @EnvironmentObject var notificationManager: NotificationManager

    func body(content: Content) -> some View {
        content
            .overlay {
                ForEach(notificationManager.freePositions.indices, id: \.self) { index in
                    if !notificationManager.freePositions[index] {
                        notificationManager.getNotificationBy(index)
                            .offset(y: 120 * CGFloat(index))
                    }
                }
            }
    }
}
extension View {
    
    func appNotifications() -> some View {
        modifier(
            AppNotificationModifier()
        )
    }
}
