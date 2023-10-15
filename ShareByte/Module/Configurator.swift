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
        ServiceLocator.shared.addService(RickAndMortyAPI(url: "https://rickandmortyapi.com/api/character"))
        
        
        // DataBase Service
        let realm = try! Realm()
        ServiceLocator.shared.addService(realm)
        
        let savableUser: SavableUser = .init()
        ServiceLocator.shared.addService(savableUser)
    }
}
