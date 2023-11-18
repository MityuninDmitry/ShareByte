//
//  View.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/18/23.
//

import Foundation
import SwiftUI

extension View {
    func strockedCapsule() -> some View {
        modifier(StrockedCapsule())
    }
    
    func strockedFilledCapsule() -> some View {
        modifier(StrockedFilledCapsule())
    }
}
