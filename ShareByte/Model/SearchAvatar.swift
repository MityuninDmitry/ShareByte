//
//  SearchAvatar.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/11/23.
//

import Foundation
import SwiftUI

class SearchAvatar: ObservableObject {
    @Published var rickAndMorty: RickAndMortyModel?
    @Published var page = 1
    func loadRickAndMorty() {
        let api = RickAndMortyAPI(url: "https://rickandmortyapi.com/api/character", page: page)
        Task {
            let mappedResponse = await api.makeRequest()
            if let safeResponse = mappedResponse {
                Task { @MainActor in
                    self.rickAndMorty = safeResponse
                    print("END LOADING \(safeResponse.info.pages)")
                }
            }
        }
    }
    
    func setNextPage() {
        page += 1
    }
}
