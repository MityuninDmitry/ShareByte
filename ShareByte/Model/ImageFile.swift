//
//  ImageFile.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/4/23.
//

import Foundation
import SwiftUI

struct ImageFile: Identifiable, Codable {
    var id: UUID = .init()
    var imageName: String
    var imageData: Data?
    
    var image: UIImage? 
    var thumbnail: UIImage?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageName
        case imageData
    }
    
    mutating func setThumbnail() {
        if imageData != nil {
            thumbnail = UIImage(data: imageData!)?.preparingThumbnail(of: CGSize(width: 300, height: 300))
        }
        
    }
    
    mutating func setimage() {
        if imageData != nil {
            image = UIImage(data: imageData!)
        }
    }
    
}
