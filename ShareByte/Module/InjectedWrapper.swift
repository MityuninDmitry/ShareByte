//
//  InjectedWrapper.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 10/13/23.
//

import Foundation

@propertyWrapper
struct Injected<T: Any> {
    private var service: T?
    private var serviceLocator = ServiceLocator.shared
    
    public var wrappedValue: T? {
        mutating get {
            if service == nil {
                
                self.service = serviceLocator.getService()
                return self.service
            }
            return service
        }
        mutating set {
            service = newValue
        }
    }
    
    public var projectedValue:Injected<T> {
        get {return self}
        mutating set {self = newValue}
    }
}
