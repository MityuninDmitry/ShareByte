//
//  Network.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/9/23.
//

import Foundation

protocol AppNetworking {
    associatedtype T
    func makeRequest() async -> T?
}

open class AppNetwork<T : Decodable>: AppNetworking {
    public let baseStringURL: String
    public var page: Int?
    public var url: URL {
        get {
            return URL(string: baseStringURL)!
        }
    }
    public var mappedResponse: T?
    open func makeRequest() async -> T? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let responseData = response as! HTTPURLResponse
            if responseData.statusCode != 200 {
                return nil
            }
            
            let mappedResponse =  try? JSONDecoder().decode(T.self, from: data)
            
            self.mappedResponse = mappedResponse!
            
            return mappedResponse
            
        } catch {
            
        }
        
        return nil
    }
    public init(url: String) {
        self.baseStringURL = url
    }
    
    public init(url: String, page: Int) {
        self.baseStringURL = url
        self.page = page 
    }
}

class RickAndMortyAPI: AppNetwork<RickAndMortyModel> {
    public override var url: URL {
        get {
            //https://rickandmortyapi.com/api/character?page=41
            return URL(string: baseStringURL + "?page=\(page!)")!
        }
    }
    
    func setNextPage() {
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
