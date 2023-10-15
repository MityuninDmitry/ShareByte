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
protocol DataBaseProtocol {
    associatedtype T where T: Any
    associatedtype DB where DB: Object
    
    func save(instance: T)
    func loadInstances() -> [T]
    func mapFrom(_ instance: T) -> DB
}

class SavableUser: Object, DataBaseProtocol  {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var imageData: Data
    @Injected var api: Realm!
    
    func save(instance: User) {
        if api != nil {
            if loadInstances().count > 0 {
                
                let objects = api!.objects(type(of: self))
                let firstUser = objects[0]
                try! api!.write {
                    firstUser.name = instance.name ?? UIDevice.current.name
                    firstUser.imageData = instance.imageData 
                }
            } else {
                let savableUser = mapFrom(instance)
                try! api!.write {
                    api!.add(savableUser)
                }
            }
        }
        
        
        
    }
    
    func loadInstances() -> [User] {
        let realm = try! Realm()
        let objects = realm.objects(type(of: self))
        let array: [User] = objects.map { object in
            var user = User()
            user.id = "\(object._id)"
            user.name = object.name
            user.imageData = object.imageData
            return user
        }
        return array
    }
    
    func mapFrom(_ instance: User) -> SavableUser {
        let savableUser = SavableUser()
        savableUser._id = try! ObjectId(string: instance.id)
        savableUser.name = instance.name ?? ""
        savableUser.imageData = instance.imageData
        return savableUser
    }
        
}
