//
//  Tool.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/12/23.
//

import Foundation
import SwiftUI

struct Tool: Identifiable {
    var id: String = UUID().uuidString
    var icon: String
    var name: String
    var color: Color
    var toolPosition: CGRect = .zero
    var action: (() -> Void) = {}
    var ignoreAction: Bool = false
}
