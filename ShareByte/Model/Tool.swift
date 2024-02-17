//
//  Tool.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/12/23.
//

import Foundation
import SwiftUI

enum ToolPosition {
    case right, left
}

struct Tool: Identifiable {
    var id: String = UUID().uuidString
    var icon: String
    var name: String
    var color: Color = Dict.appIndigo
    var toolPosition: CGRect = .zero
    var action: (() -> Void) = {}
    var ignoreAction: Bool = false
    var iconColor: Color = .white
    var position: ToolPosition = .right
}
