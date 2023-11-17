//
//  PresentationStates.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import Foundation

enum PresentationState: String, Codable {
    case selecting = "SELECTING"
    case uploading = "UPLOADING"
    case presentation = "PRESENTATION"
}
