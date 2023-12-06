//
//  Presenter.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/17/23.
//

import Foundation
import UIKit
import SwiftUI


struct Presentation: Identifiable, Codable {
    var id: String = UUID().uuidString
    var imageFiles: [ImageFile] = []
    var state: PresentationState? = .selecting
    var indexToShow: Int?
    var imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageFiles
    }
    
    mutating func clear() {
        id = UUID().uuidString
        indexToShow = nil
        imageFiles = []
        state = .selecting
    }
    
    mutating func appendImageFile(_ data: Data) async {
        let index = self.imageFiles.count
        let thumbnail = UIImage(data: data)?.preparingThumbnail(of: CGSize(width: 300, height: 300))
        let imageFile = ImageFile(imageName: "Pic \(index)", imageData: data, image: UIImage(data: data), thumbnail: thumbnail)
        self.imageFiles.append(imageFile)
    }
    
   mutating func nextState() {
        switch state {
        case .selecting:
            state = .uploading
        case .uploading:
            state = .presentation
        case .presentation:
            state = .selecting
        case .none:
            state = .uploading
        }
    }
}
