//
//  NotificationView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/13/24.
//

import SwiftUI

struct NotificationView: View, Hashable {
    var id: UUID = .init()
    var header: String
    var text: String
    var accept: (() -> ())? = nil
    var decline: (() -> ())? = nil
    @State var showNotification: Bool = false 
    @Environment(\.dismiss) var dismiss
    var callback: (()->())? = nil
    var onSwipe: (()->())? = nil
    var body: some View {
        
        GeometryReader { proxy in
            let midX: CGFloat = proxy.size.width / 2
            let appearedY: CGFloat = 50
            if showNotification {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("BG"))
                    .shadow(color: Dict.appIndigo,radius: 3)
                    .shadow(color: Dict.appIndigo,radius: 1)
                    .frame(width: proxy.size.width, height: 100)
                    .overlay {
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                Text(header)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.indigo)
                                    
                                Spacer()
                                Text(text)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2, reservesSpace: true)
                                
                                Spacer()
                            }
                            Spacer()
                            if decline != nil {
                                Button {
                                    decline!()
                                    setShowNotification(false)
                                } label: {
                                    Image(systemName: "xmark.icloud.fill")
                                        .font(.title)
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            if accept != nil {
                                Button {
                                    accept!()
                                    setShowNotification(false)
                                } label: {
                                    Image(systemName: "checkmark.icloud.fill")
                                        .font(.title)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .frame(minWidth: proxy.size.width - 15)
                        .padding(.horizontal, 15)
                        
                    }
                    .transition(.move(edge: .top))
                    .position(x: midX, y: showNotification ? appearedY : 0)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 30)
        .onAppear(perform: {
            setShowNotification(true)
            Task {
                try await Task.sleep(for: .seconds(7))
                if onSwipe != nil {
                    onSwipe!()
                }
                setShowNotification(false)
                
            }
        })
        .coordinateSpace(name: "NOTIFICATION VIEW")
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .named("NOTIFICATION VIEW")) // swipe gesture
            .onEnded { value in
                let verticalAmount = value.translation.height
                if verticalAmount < 0 { // свайп вверх
                    if onSwipe != nil {
                        onSwipe!()
                    }
                    setShowNotification(false)
                }
            }
        )
        
        
    }
    
    func setShowNotification(_ value: Bool) {
        withAnimation(.easeInOut(duration: 1)) {
            if showNotification != value {
                showNotification = value
                if !value {
                    if callback != nil {
                        callback!()
                    }
                    dismiss()
                    
                }
            }
        }
        
    }
    
    static func == (lhs: NotificationView, rhs: NotificationView) -> Bool {
       return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NotificationView(
        header: "Новый пользователь",
        text: "Достигнут предел пользователей. Приобретите премиум версию.",
        accept: {
            print("ACCEPT")
        },
        decline: {
            print("DECLINE")
        }
        )
    .preferredColorScheme(.dark)
}
