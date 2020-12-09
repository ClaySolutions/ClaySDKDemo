//
//  PropertyList.swift
//  Demo
//
//  Created by Jakov Videkovic on 09/12/2020.
//

import Foundation

@propertyWrapper
struct PropertyList<Value> where Value: Decodable {
    
    enum Keys: String {
        case configuration = "Configuration"
    }
    
    let key: Keys

    var wrappedValue: Value? {
        let path = Bundle.main.path(forResource: key.rawValue, ofType: "plist")!
        let data = FileManager.default.contents(atPath: path)!
        return try? PropertyListDecoder().decode(Value.self, from: data)
    }
}

struct Configuration: Codable {
    var issuer: String?
    var clientId: String?
    var redirectLogin: String?
    
    var issuerURL: URL {
        URL(string: issuer!)!
    }
    
    var redirectLoginURL: URL {
        URL(string: redirectLogin!)!
    }
}
