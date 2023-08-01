//
//  Presenter.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/17/23.
//

import Foundation
import UIKit
import SwiftUI


struct Presentation: Codable, Hashable {
    var imagesData: [Data] = .init()
    var indexToShow: Int? = nil
    /// для вюера свойство, что данные получены и готовы к презентации. А для презентера, что презентация готова к показу - когда все пользователи готовы к нему
    var readyToShow: Bool = false
    var imageToShow: Image? {
        get {
            if indexToShow != nil {
                if let uiImage = UIImage(data: imagesData[indexToShow!]) {
                    return Image(uiImage: uiImage)
                }
            }
            return nil
        }
    }
    //var imageCountInPresentation: Int = 0
    
    func images() -> [Image] {
        var images: [Image] = .init()
        for imageData in imagesData {
            if let uiImage = UIImage(data: imageData) {
                let image = Image(uiImage: uiImage)
                images.append(image)
            }
        }
        return images 
    }
    
    mutating func clear() {
        indexToShow = nil
        imagesData = .init()
        readyToShow = false 
    }
}
