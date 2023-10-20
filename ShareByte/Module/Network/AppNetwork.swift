//
//  AppNetwork.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/13/23.
//

import Foundation
public protocol AppNetworking<NetworkModel> {
    associatedtype NetworkModel: Decodable
    func makeRequest() async -> NetworkModel?
    func setNextPage()
}

open class AppNetwork<T: Decodable>: AppNetworking {
    public typealias NetworkModel = T
    
    public let baseStringURL: String
    public var page: Int?
    public var url: URL {
        return URL(string: baseStringURL)!
    }
    public var mappedResponse: NetworkModel?
    
    public init(url: String) {
        self.baseStringURL = url
    }
    
    public init(url: String, page: Int) {
        self.baseStringURL = url
        self.page = page
    }
    
    
    open func makeRequest() async -> NetworkModel? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let responseData = response as! HTTPURLResponse
            if responseData.statusCode != 200 {
                return nil
            }
            
            let mappedResponse =  try? JSONDecoder().decode(NetworkModel.self, from: data)
            
            self.mappedResponse = mappedResponse!
            
            return mappedResponse
            
        } catch {
            
        }
        
        return nil
    }
    
    public func setNextPage() {
        // заглушка
    }
}
