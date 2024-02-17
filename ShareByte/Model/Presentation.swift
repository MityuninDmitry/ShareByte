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
    var id: String = UUID().uuidString {
        didSet {
            print("CREATE NEW ID PRESENTATION")
        }
    }
    var imageFiles: [ImageFile] = []
    var state: PresentationState = .selecting
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
    mutating func setState(_ state: PresentationState) {
        switch state {
        case .preparing:
            indexToShow = nil
            imageFiles = []
        case .selecting:
            id = UUID().uuidString
            indexToShow = nil
            imageFiles = []
        case .prepared:
            indexToShow = 0
        default:
            self.state = state 
        }
        self.state = state
    }
    
    mutating func appendImageFile(_ data: Data) async {
        let index = self.imageFiles.count
        let thumbnail = UIImage(data: data)?.preparingThumbnail(of: CGSize(width: 300, height: 300))
        let imageFile = ImageFile(imageName: "Pic \(index)", imageData: data, uiImage: UIImage(data: data), thumbnail: thumbnail)
        self.imageFiles.append(imageFile)
    }
    
   mutating func nextState() {
        switch state {
        case .selecting:
            setState(.preparing)
        case .preparing:
            setState(.prepared)
        case .prepared:
            setState(.uploading)
        case .uploading:
            setState(.presentation)
        case .presentation:
            setState(.selecting)
        }
    }
    
    func getImagesData() -> [Data] {
        var data: [Data] = .init()
        for imageFile in imageFiles {
            data.append(imageFile.imageData!)
        }
        return data
    }
}


