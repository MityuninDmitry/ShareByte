//
//  Network.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/9/23.
//

import Foundation

class RickAndMortyAPI: AppNetwork<RickAndMortyModel> {
    override init(url: String) {
        super.init(url: url)
        page = 1
    }
    
    public override var url: URL {
        get {
            return URL(string: baseStringURL + "?page=\(page!)")!
        }
    }
    
    override func setNextPage() {
        if mappedResponse != nil {
            if mappedResponse!.info.next != nil {
                if self.page != nil {
                    self.page! += 1
                }
                
            }
        }
        
    }
}

struct RickAndMortyModel: Codable {
    var info: RickAndMortyInfo
    var results: [RickAndMortyItem]
}

struct RickAndMortyItem: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var image: String
}
struct RickAndMortyInfo: Codable {
    var pages: Int
    var next: String?
    var prev: String?
}
