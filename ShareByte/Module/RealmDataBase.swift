//
//  RealmDataBase.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/7/23.
//

import Foundation
import RealmSwift
import UIKit

//struct RealmDataBase {
//    static var shared = RealmDataBase()
//    let realm: Realm
//    
//    func add(_ object: Object) {
//        try! realm.write {
//            realm.add(object)
//        }
//        
//    }
//    
//    func open<T>(type: T.Type) -> [T] where T: Object  {
//        
//        let objects = realm.objects(type)
//        let  array: [T] = objects.map { $0 as T
//        }
//        return array
//    }
//    
//    func save(_ object: Object) {
//        
//        try! realm.write {
//            realm.delete(object)
//            
//        }
//        try! realm.write {
//            add(object)
//            
//        }
//        
//        
//    }
//    private init() {
//         realm = try! Realm()
//    }
//}

// пользователь для сохранения в БД
// забираем нужные для сохранения поля пользователя и сохраняем в БД 
class SavableUser: Object {

    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var imageData: Data
    
    static func save(user: User) {
        let realm = try! Realm()
        
        if loadInstances().count > 0 {
            let objects = realm.objects(SavableUser.self)
            let firstUser = objects[0]
            try! realm.write {
                firstUser.name = user.name ?? UIDevice.current.name
                firstUser.imageData = user.image.pngData()!
            }
        } else {
            let savableUser = mapFrom(user)
            try! realm.write {
                realm.add(savableUser)
            }
        }
        
        
    }
    
    static func mapFrom(_ user: User) -> SavableUser {
        let savableUser = SavableUser()
        savableUser._id = try! ObjectId(string: user.id)
        savableUser.name = user.name ?? ""
        savableUser.imageData = user.image.pngData()!
        return savableUser
    }
    
    static func loadInstances() -> [User] {
        let realm = try! Realm()
        let objects = realm.objects(SavableUser.self)
        let array: [User] = objects.map { object in
            var user = User()
            user.id = "\(object._id)"
            user.name = object.name
            return user
        }
        return array
    }
        
}
