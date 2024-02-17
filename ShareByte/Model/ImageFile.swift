//
//  ImageFile.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 12/4/23.
//

import Foundation
import SwiftUI


struct ImageFile: Identifiable, Codable, Hashable {
    var id: UUID = .init()
    var imageName: String
    var imageData: Data?
    
    var uiImage: UIImage? 
    var thumbnail: UIImage?
    var likedUsers: [User] = .init()
    var image: Image {
        if uiImage != nil {
           return Image(uiImage: uiImage!)
        }
        return Image(systemName: "questionmark.circle")
    }
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
            uiImage = UIImage(data: imageData!)
        }
    }
    
    static func == (lhs: ImageFile, rhs: ImageFile) -> Bool {
       return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    mutating func processLikeFrom(_ user: User) {
        if self.likedUsers.contains(where: { $0.id == user.id}) {
            self.likedUsers.removeAll { $0.id == user.id }
        } else {
            self.likedUsers.append(user)
        }
    }
}

extension ImageFile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
}
