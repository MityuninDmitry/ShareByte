//
//  RealmDataBase.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/7/23.
//

import Foundation
import RealmSwift
import UIKit


// НАРАБОТКИ НАЧАЛО 
//public protocol DataBaseProtocol<SavableModel> {
//    associatedtype SavableModel: Any
//    
//    func save(instance: Any)
//    func loadInstances() -> [Any]
//}
//class DataBase: DataBaseProtocol {
//    typealias SavableModel = Any
//    
//    func save(instance: Any) {
//        // заглушка
//    }
//    
//    func loadInstances() -> [Any] {
//        // заглушка
//        return .init()
//    }
//}
// НАРАБОТКИ КОНЕЦ

// пользователь для сохранения в БД
// забираем нужные для сохранения поля пользователя и сохраняем в БД
class SavableUserModel: Object  {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var imageData: Data
    @Injected var api: Realm?
    
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
    
    func mapFrom(_ instance: User) -> SavableUserModel {
        let savableUser = SavableUserModel()
        savableUser._id = try! ObjectId(string: instance.id)
        savableUser.name = instance.name ?? ""
        savableUser.imageData = instance.imageData
        return savableUser
    }
        
}
