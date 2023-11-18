//
//  UIImage.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 11/11/23.
//

import Foundation
import SwiftUI

extension UIImage {
    var fixedOrientation: UIImage {
        guard imageOrientation != .up else { return self }
        
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).rotated(by: .pi)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: size.height).rotated(by: -.pi/2)
        case .upMirrored:
            transform = transform
                .translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard
            let cgImage = cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(
                data: nil, width: Int(size.width), height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue
            )
        else { return self }
        context.concatenate(transform)
        
        var rect: CGRect
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        default:
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        context.draw(cgImage, in: rect)
        return context.makeImage().map { UIImage(cgImage: $0) } ?? self
    }
    
    
    func resizeImage(image: UIImage, compressFactor: Double = 0.5) -> UIImage? {
        let size = image.size
        
        let newWidth  = size.width * compressFactor
        let newHeight = size.height * compressFactor
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize = CGSize(width: newWidth, height: newHeight)
        
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func reduceImageDataRecursively(uiImage: UIImage, limitSizeInMB: Double = 2) -> Data? {
        var copiedData = uiImage.pngData()!
        var copiedUIImage = uiImage 
//        print("Size in MB \(copiedData.sizeInMB)")
//        print("Dimenstions is \(copiedUIImage.size)")
        
        if copiedData.sizeInMB > limitSizeInMB {
            copiedData = copiedUIImage.jpegData(compressionQuality: 0.1)!
            if copiedData.sizeInMB > limitSizeInMB {
                let resizedUIImage = resizeImage(image: copiedUIImage, compressFactor: 0.5)!
                copiedData = reduceImageDataRecursively(uiImage: resizedUIImage, limitSizeInMB: limitSizeInMB)!
            }
            
            
        }
        
        return copiedData
    }
    
    func reducedDataForUploading(uiImage: UIImage) -> Data {
        return reduceImageDataRecursively(uiImage: uiImage, limitSizeInMB: 1)!
    }
}
