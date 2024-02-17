//
//  AppSettingsView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/4/24.
//

import SwiftUI

struct AppSettingsView: View {
    private var buttonFont: Font = .title2
    private var buttonColor: Color = .white
    @State private var showPremiumView: Bool = false
    @State private var showInstruction: Bool = false
    var body: some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            Text("SETTINGS")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Spacer()
            
            Button {
                showInstruction.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("Show instruction")
                        .font(buttonFont)
                        .foregroundStyle(buttonColor)
                }
            }
            .padding(.bottom, 15)
            
            Button {
                showPremiumView.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("Buy premium version")
                        .font(buttonFont)
                        .foregroundStyle(buttonColor)
                }
            }
            .padding(.bottom, 15)
            
            Button {
                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            } label: {
                HStack {
                    Spacer()
                    Text("Change app language")
                        .font(buttonFont)
                        .foregroundStyle(buttonColor)
                }
                
            }
            .padding(.bottom, 15)
            
            Text("App version: \(UIApplication.appVersion)")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showPremiumView) {
            BuyPremiumView()
        }
        .sheet(isPresented: $showInstruction) {
            InstructionsView()
        }
    }
}

#Preview {
    AppSettingsView()
}
