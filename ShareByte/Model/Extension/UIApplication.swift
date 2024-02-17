//
//  UIApplication.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/4/24.
//

import Foundation
import UIKit

extension UIApplication {
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }
}
