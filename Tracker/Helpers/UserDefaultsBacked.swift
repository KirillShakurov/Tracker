//
//  UserDefaultsBacked.swift
//  Tracker
//
//  Created by Kirill on 24.04.2023.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<Value: Codable> {
    let key: String
    let storage: UserDefaults = .standard
    
    var wrappedValue: Value? {
        get {
            storage.value(forKey: key) as? Value
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}
