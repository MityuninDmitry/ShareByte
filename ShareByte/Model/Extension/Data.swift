//
//  Data.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/18/23.
//

import Foundation
extension Data {
    var sizeInMB: Double {
        return Double(count) / 1024 / 1024
    }
}
