//
//  SearchAvatar.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/11/23.
//

import Foundation
import SwiftUI

class SearchAvatar: ObservableObject {
    static var shared = SearchAvatar()
    
    @Published var rickAndMortyInfo: RickAndMortyInfo?
    @Published var rickAndMortyItems: [RickAndMortyItem] = .init()
    @Injected var api: RickAndMortyAPI?
        
    func loadRickAndMorty() {
        if api != nil {
            Task {
                let mappedResponse = await api!.makeRequest()
                if let safeResponse = mappedResponse {
                    Task { @MainActor in
                        self.rickAndMortyItems.append(contentsOf: safeResponse.results)
                        self.rickAndMortyInfo = safeResponse.info
                    }
                }
            }
        }
        
        
    }
    
    func setNextPage() {
        if api != nil {
            api!.page! += 1
        }
        
    }
}
