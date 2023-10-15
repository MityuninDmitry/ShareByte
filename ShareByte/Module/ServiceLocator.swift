//
//  ServiceLocator.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/13/23.
//

import Foundation

class ServiceLocator {
    static var shared = ServiceLocator()
    
    private var services: [String: Any] = [:]
    
    private func typeName(of some: Any) -> String {
        return "\(type(of: some))"
    }
    
    func addService<T: Any>(_ service: T)  {
        let key = typeName(of: T.self)
        services[key] = service
    }
    
    func getService<T: Any> () -> T?  {
        let key = typeName(of: T.self)
        return services[key] as? T
    }
}
