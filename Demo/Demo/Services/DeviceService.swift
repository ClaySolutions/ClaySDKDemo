//
//  DeviceService.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import Foundation
import AppAuth

class DeviceService {
    
    let networkService = NetworkService()
    
    /// Registers a new device within SaltoKS system
    func registerDevice(deviceName: String, deviceUID: String, publicKey: String, completion: @escaping (Result<Device, Error>) -> Void) {
                
        let paramsDict: [String: Any] = [
            "device_name": deviceName.prefix(49), // backend allows max 50 characters
            "device_uid": deviceUID,
            "public_key": publicKey
        ]
        
        networkService.request(endpoint: "/me/devices", httpMethod: "POST", params: paramsDict) { (result: Result<Device, Error>) in
            completion(result)
        }
    }
    
    
}
