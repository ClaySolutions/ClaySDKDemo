//
//  MobileKey.swift
//  Demo
//
//  Created by Jakov Videkovic on 11/12/2020.
//

import Foundation

struct MobileKey: Codable {
    var id: String = ""
    let keyId: String
    let expiryDate: String
    let registrationDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyId = "key_id"
        case expiryDate = "expiry_date"
        case registrationDate = "registration_date"
    }
}
