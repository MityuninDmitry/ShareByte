//
//  AppNetwork.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/13/23.
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
