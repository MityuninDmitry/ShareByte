//
//  ButPremiumView.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/6/24.
//

import SwiftUI

struct BuyPremiumView: View {
    @ObservedObject var storeManager: StoreManager = StoreManager.shared
    @EnvironmentObject var purchasedStatus: PurchasedStatus
    @Environment(\.locale) private var localization
    @State private var uuid: UUID = .init()
    
    @State var radius: CGFloat = 15
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            Text("\(purchasedStatus.isPremium ? NSLocalizedString("Premium app version", comment: "Премиум") : NSLocalizedString("Default app version", comment: "Бесплатное"))")
                .padding([.top], 15)
                .font(.title)
                .multilineTextAlignment(.center)
            
            ImageView(
                imageData: UIImage(named: "Premium")?.pngData()!,
                width: 250,
                height: 250
            )
            .padding([.top], 15)
            .shadow(color: Dict.appIndigo, radius: radius)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.linear.repeatForever(autoreverses: true).speed(0.1)) {
                        radius = 30
                    }
                }
            }
            
            HStack {
                Spacer()
                Text("Default")
                    .shadow(color: .red, radius: 10)
                    .shadow(color: .red.opacity(0.5), radius: 10)
                Spacer()
                Text("Premium")
                    .shadow(color: Dict.appIndigo, radius: 10)
                    .shadow(color: Dict.appIndigo.opacity(0.5), radius: 10)
                Spacer()
            }
            .font(.title2)
            .padding(.top, 15)
            
            HStack {
                Spacer()
                Text("How many users can be in session")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .font(.callout)
            .padding(.horizontal, 35)
            .padding(.top, 10)
            
            HStack {
                Spacer()
                Text("\(Dict.userLimitDefault)")
                    .font(.title2)
                    .shadow(color: .red, radius: 10)
                    
                Spacer()
                Text("\(Dict.userLimitPremium)")
                    .fontWeight(.semibold)
                    .font(.title)
                    .shadow(color: Dict.appIndigo, radius: 10)
                    .shadow(color: Dict.appIndigo.opacity(0.5), radius: 10)
                Spacer()
            }
            
            .padding(.top, 5)
            
            HStack {
                Spacer()
                Text("How many images can be uploaded")
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .font(.callout)
            .padding(.horizontal, 35)
            .padding(.top, 10)
            
            HStack {
                Spacer()
                Text("\(Dict.imageLimitDefault)")
                    .font(.title2)
                    .shadow(color: .red, radius: 10)
                
                Spacer()
                Text("\(Dict.imageLimitPremium)")
                    .fontWeight(.semibold)
                    .font(.title)
                    .shadow(color: Dict.appIndigo, radius: 10)
                    .shadow(color: Dict.appIndigo.opacity(0.5), radius: 10)
                Spacer()
            }
            .padding(.top, 5)
            
            if !purchasedStatus.isPremium {
                Button {
                    if let product = storeManager.product {
                        let _ = storeManager.purchase(product: product)
                    }
                } label: {
                    HStack {
                        Text("Purchase premium version for")
                        Text(storeManager.product?.localizedPrice() ?? "")
                    }
                    .foregroundStyle(.white)
                    .strockedFilledCapsule()
                    
                }
                
            }
               
                
            Button {
                storeManager.restore()
            } label: {
                HStack {
                    Text("Restore purchase")
                        .foregroundStyle(.white)
                }
                .strockedFilledCapsule()
            }
            
            
            
            Group {
                if localization.identifier == "ru" {
                    Text(.init("Продолжая, вы соглашаетесь с [условиями и положениями](\(Dict.URL.privacyPolicyAndTerms)), а также с [политикой конфиденциальности](\(Dict.URL.privacyPolicyAndTerms)). При удалении приложения возврат покупки не происходит. Для восстановления ранее оплаченных покупок нажмите кнопку \"Восстановить покупки\"."))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                        
                } else {
                    Text(.init("By continuing, you agree with [privacy policy](\(Dict.URL.privacyPolicyAndTerms)), and also with [terms of use](\(Dict.URL.privacyPolicyAndTerms)). If you will remove application from your device, spent money not return back. If you want to restore in-app purchases, then press button \"Restore purchases\"."))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
                
            }
            .padding(.top, 10)
        }
        .id(uuid)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(Color("BG").opacity(0.6).gradient)
                .rotationEffect(.init(degrees: -180))
                .ignoresSafeArea()
        }
        .onAppear(perform: {
            self.storeManager.storeManagerDelegate = self
            storeManager.getProducts()
        })
    }
}

extension BuyPremiumView: StoreManagerDelegate {
    func storeManagerChanges() {
        uuid = .init()
    }
    
    
}

#Preview {
    BuyPremiumView()
        .preferredColorScheme(.dark)
}
