//
//  Device.swift
//  Demo
//
//  Created by Jakov Videkovic on 11/12/2020.
//

import Foundation

struct Device: Codable {
    let id: String
    let deviceName: String
    let deviceUID: String
    let mobileKey: MobileKey?
    
    enum CodingKeys: String, CodingKey {
        case id
        case deviceName = "device_name"
        case deviceUID = "device_uid"
        case mobileKey = "mkey"
    }
}
