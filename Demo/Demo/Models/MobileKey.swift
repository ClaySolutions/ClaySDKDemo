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
    
    var isMobileKeyExpairingIn7days: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let expiryDate = dateFormatter.date(from: expiryDate), let aWeekFromNow = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) {
            return expiryDate < aWeekFromNow
        }
        return false
    }
}

struct MobileKeyData: Codable {
    let mKeyData: String
    
    enum CodingKeys: String, CodingKey {
        case mKeyData = "mkey_data"
    }
}
