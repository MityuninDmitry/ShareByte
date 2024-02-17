//
//  InstructionsView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/22/24.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        List {
            Text("Thank you for using ShareByte application. I hope it will be usefull for you and your friends.")
                //.font(.title2)
                .font(.callout)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.green)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("ShareByte:")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Simple app which allows users to share images safety in local internet even while internet connection is lost. Your images can't be downloaded until when presenter shares it manually with you.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Main rules:")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Important: ShareByte requires local network setting enabled. You can check it in app settings. Otherwise you can't find users nearby.")
                .foregroundStyle(.red)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Common things:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Initially person has no any role.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Presenter - person who demonstrates images. If you want to be presenter - tap user and wait while he accepts invitation. He can decline it, but you can invite him again.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Viewer - person who watches images of presenter. If you want to be viewer - accept invitation from another user.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Any user can:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Change name in any time for better visibility in front of another users in session.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Change avatar in any time for better visibility in front of another users in session.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Presenter can:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Invite another user into session in any time of presentation.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Kick user from session by tapping connected user while session.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Share full images of presentation or particular image while presentation.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Viewer can:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Watch presentation and like images.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Viewer can't:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Make any screenshot of presentation. Screenshot will be empty.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Invite anoter user to presentation. It can be done only by presenter")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Invite another user to session.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Sections:")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Presentation:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- When you are presenter. This section allows select images, upload it to users and change demonstrated image. Also this section allows send images to another users.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Presenter can's select more images, than app limit. More about limitations see below.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- When you are viewer. This section allows watch presenter's images. Also you can tap ❤️ to send like for demonstrated image.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Viewer can's watch more images, than app limit. More about limitations see below.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Users:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- You can see your role, another users and their roles.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- You can disconnect and reconnect your session by tapping button. Your role and presentation will be cleared.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Me:")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- You can change your user name or avatar.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Also there are some buttons for opening app menu.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("Limitations:")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- There are some limitations for best app performance and quality.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Image limits in presentation - you can select different amount of images for presentation. But not more than current app image limit.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- User limits in session - you can invite different amount of users into session as presenter. But not more than current app user limit.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- Limits depend on free or premium app edition. Free and premium edition has different limits. You can see your limits in app settings inside application.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
            Text("- App versions should be equal for connecting between users. It's important. For example: your app version can be v1.0.1, but your friend app version is v1.0.2. Your versions are not equal, so you can't be connected.")
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            
        }
        .foregroundStyle(.white.opacity(0.7))
        .listStyle(.plain)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(Color("BG").opacity(0.6).gradient)
                .rotationEffect(.init(degrees: -180))
                .ignoresSafeArea()
        }
    }
    
}

#Preview {
    InstructionsView()
        .preferredColorScheme(.dark)
}
