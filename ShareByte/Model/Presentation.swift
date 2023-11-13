//
//  Presenter.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/17/23.
//

import Foundation
import UIKit
import SwiftUI


struct Presentation: Codable {
    var id: UUID = .init()
    var imagesData: [Data] = .init()
    var indexToShow: Int? = nil {
        didSet {
            if indexToShow != nil {
                let imageName = "\(indexToShow!).png"
                let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)
                if FileManager.default.fileExists(atPath: tempDir.path(percentEncoded: true)) {
                    print("FILE EXIST")
                    self.imageURL = tempDir
                } else {
                    print("CREATE NEW FILE IN TMP DIR")
                    let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
                    let pngData = UIImage(data: imagesData[indexToShow!])!.pngData();
                    do {
                        try pngData?.write(to: imageURL!);
                    } catch { }
                    self.imageURL = imageURL
                }
            } else {
                self.imageURL = nil
            }
        }
    }
    /// для вюера свойство, что данные получены и готовы к презентации. А для презентера, что презентация готова к показу - когда все пользователи готовы к нему
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
    var uiImageToShow: UIImage? {
        get {
            if indexToShow != nil {
                if let uiImage = UIImage(data: imagesData[indexToShow!]) {
                    
                    return uiImage
                }
            }
            return nil
        }
    }
    
    var imageURL: URL?
   
    
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
        id = .init()
        indexToShow = nil
        imagesData = []
        FileManager().clearTmpDirectory()
    }
    
    mutating func appendImageData(_ data: Data)  {
        let index = self.imagesData.count
        self.imagesData.append(data)
        
        Task(priority: .medium) {
            let imageName = "\(index).png"
            let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
            let pngData = UIImage(data: data)!.pngData();
            do {
                try pngData?.write(to: imageURL!);
            } catch { }
        }
        
    }
    
    func setImageURLFor(index: Int) -> URL {
        let imageName = "\(index).png"
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)
        if FileManager.default.fileExists(atPath: tempDir.path(percentEncoded: true)) {
            print("FILE EXIST")
            return tempDir
        } else {
            print("CREATE NEW FILE IN TMP DIR")
            let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
            let pngData = UIImage(data: imagesData[indexToShow!])!.pngData();
            do {
                try pngData?.write(to: imageURL!);
            } catch { }
            return imageURL!
            
        }
    }
    
    var imageURLs: [URL] {
        return getAllImageURLs()
    }
    func getAllImageURLs() -> [URL] {
        var imageURLs: [URL] = .init()
        if self.imagesData.count > 0 {
            for (index, _) in self.imagesData.enumerated() {
                imageURLs.append(setImageURLFor(index: index))
            }
        }
        return imageURLs
    }
}
