//
//  Dict.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/4/24.
//

import Foundation
import SwiftUI



struct Dict {
    static let userLimitDefault = 3 // PROD: 3
    static let userLimitPremium = 7 // PROD: 7
    
    static let imageLimitDefault = 10
    static let imageLimitPremium = 30
    
    static let appIndigo: Color = Color("AppIndigo")
    
    struct URL {
        static var shareApp = "https://apps.apple.com/app/id\(SafeInfo.appleID)"
        static var privacyPolicyAndTerms = "https://doc-hosting.flycricket.io/privacy-policy-terms-of-use/430d4f7f-c66f-43c4-ba17-cdd0204713a2/privacy"
    }
    
    struct AppUserDefaults {
        static let defaults = UserDefaults.standard
        private static let runAppCount = "RUN_APP_COUNT"
        private static let userLimit = "USER_LIMIT"
        private static let imageLimit = "IMAGE_LIMIT"
        private static let isPremium = "IS_PREMIUM"
        
        static func getRunAppCount() -> Int {
            let runAppCount = Dict.AppUserDefaults.defaults.integer(forKey: Dict.AppUserDefaults.runAppCount)
            return runAppCount
        }
        static func increaseRunAppCount() {
            let runAppCount = getRunAppCount()
            Dict.AppUserDefaults.defaults.setValue(runAppCount + 1, forKey: Dict.AppUserDefaults.runAppCount)
        }
        
        static func setPremium(_ isPremium: Bool) {
            Dict.AppUserDefaults.defaults.setValue(isPremium, forKey: Dict.AppUserDefaults.isPremium)
        }
        
        static func getIsPremium() -> Bool {
            return Dict.AppUserDefaults.defaults.bool(forKey: Dict.AppUserDefaults.isPremium)
        }
        
        static func getUserLimit() -> Int {
            let limit = Dict.AppUserDefaults.defaults.integer(forKey: Dict.AppUserDefaults.userLimit)
                
            return limit
        }
        
        static func setUserLimit(limit: Int) {
            Dict.AppUserDefaults.defaults.setValue(limit, forKey: Dict.AppUserDefaults.userLimit)
        }
        
        static func getImageLimit() -> Int {
            let limit = Dict.AppUserDefaults.defaults.integer(forKey: Dict.AppUserDefaults.imageLimit)
                
            return limit
        }
        
        static func setImageLimit(limit: Int) {
            Dict.AppUserDefaults.defaults.setValue(limit, forKey: Dict.AppUserDefaults.imageLimit)
        }
        
        static func setDefaultValues() {
            Dict.AppUserDefaults.setPremium(false)
            Dict.AppUserDefaults.setUserLimit(limit: Dict.userLimitDefault)
            Dict.AppUserDefaults.setImageLimit(limit: Dict.imageLimitDefault)
        }
        
        static func setPremiumValues() {
            Dict.AppUserDefaults.setPremium(true)
            Dict.AppUserDefaults.setUserLimit(limit: Dict.userLimitPremium)
            Dict.AppUserDefaults.setImageLimit(limit: Dict.imageLimitPremium)
            PurchasedStatus.shared.isPremium = true 
        }
        static func actualizeValues() {
            if AppUserDefaults.getIsPremium() {
                setPremiumValues()
            } else {
                setDefaultValues()
            }
        }
    }
    
    
}
