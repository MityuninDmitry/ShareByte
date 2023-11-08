//
//  RealmDataBase.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/7/23.
//

import Foundation
import RealmSwift
import UIKit

protocol LoadableProtocol { // объект, который выгружаем из БД
    func mapToSavable() -> SavableProtocol
    func updateFrom(instance: SavableProtocol)
}
protocol SavableProtocol { // объект, который хотим сохранить
    func mapToLoadable() -> LoadableProtocol
}
class DataBase<LoadableType: LoadableProtocol, SavableType: SavableProtocol> {
    // сохранить инстанс протокола в БД
    func save(instance: SavableType) {
            
    }
    
    func load() -> [SavableType] {
        return .init()
    }
}

class DataBaseUser: DataBase<UserLoadable, User> {
    typealias LoadableType = UserLoadable
    typealias SavableType = User
    @Injected var api: Realm?
    
    override func save(instance: SavableType) {
        if api != nil {
            if load().count > 0 {
                let objects = api!.objects(LoadableType.self)
                let firstUser = objects[0]
                try! api!.write {
                    firstUser.updateFrom(instance: instance)
                }
            } else {
                let savableUser = instance.mapToLoadable() as! UserLoadable
                try! api!.write {
                    api!.add(savableUser)
                }
            }
        }
    }
    
    override func load() -> [SavableType] {
        if api != nil {
            let objects = api!.objects(LoadableType.self)
            let array: [SavableType] = objects.map { object in
                return object.mapToSavable() as! SavableType
            }
            return array
        }
        return .init()
    }
}

class UserLoadable: Object, LoadableProtocol {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var imageData: Data
    
    func mapToSavable() -> SavableProtocol {
        var user = User()
        user.id = "\(self._id)"
        user.name = self.name
        user.imageData = self.imageData
        return user
    }
    
    func updateFrom(instance: SavableProtocol) {
        let loadableInstance = instance.mapToLoadable() as! UserLoadable
        self.name = loadableInstance.name
        self.imageData = loadableInstance.imageData
    }
    
}
