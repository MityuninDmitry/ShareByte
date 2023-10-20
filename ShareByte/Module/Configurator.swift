//
//  Configurator.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/13/23.
//

import Foundation
import RealmSwift

class Configurator {
    static var shared = Configurator()
    
    func registerServices() {
        // Network Service
        let rickAndMortyAPI = RickAndMortyAPI(url: "https://rickandmortyapi.com/api/character") as AppNetwork
        ServiceLocator.shared.addService(rickAndMortyAPI)
        
        
        // DataBase Service
        let realm = try! Realm()
        ServiceLocator.shared.addService(realm)
        
        let savableUser: SavableUserModel = .init()
        ServiceLocator.shared.addService(savableUser)
    }
}
