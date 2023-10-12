//
//  SearchAvatar.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/11/23.
//

import Foundation
import SwiftUI

class SearchAvatar: ObservableObject {
    
    @Published var rickAndMortyInfo: RickAndMortyInfo?
    @Published var rickAndMortyItems: [RickAndMortyItem] = .init()
    @Published var page = 1
    
    func loadRickAndMorty() {
        let api = RickAndMortyAPI(url: "https://rickandmortyapi.com/api/character", page: page)
        
        Task {
            let mappedResponse = await api.makeRequest()
            if let safeResponse = mappedResponse {
                Task { @MainActor in
                    self.rickAndMortyItems.append(contentsOf: safeResponse.results)
                    self.rickAndMortyInfo = safeResponse.info
                    
                }
            }
        }
    }
    
    func setNextPage() {
        page += 1
    }
}
