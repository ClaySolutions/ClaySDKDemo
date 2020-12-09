//
//  UserDefaults.swift
//  Demo
//
//  Created by Jakov Videkovic on 09/12/2020.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultNSCoding<Value> where Value: NSObject, Value: NSSecureCoding {
    let key: String
    var container: UserDefaults = .standard

    var wrappedValue: Value? {
        get {
            guard let data = container.data(forKey: key) else {
                return nil
            }
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Value
        }
        set {
            guard let value = newValue, let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) else { return }

            container.set(data, forKey: key)
        }
    }
}
