//
//  DeviceService.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import Foundation
import AppAuth

class DeviceService {
    
    private let networkService = NetworkService()
    
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

    func downloadMobileKey(deviceId: String, completion: @escaping (Result<MobileKeyData, Error>) -> Void) {
        
        networkService.request(endpoint: "/me/devices/\(deviceId)/mkey", httpMethod: "GET") { (result: Result<MobileKeyData, Error>) in
            completion(result)
        }
    }
    
    func getDevices(with deviceUID: String, completion: @escaping (Result<ListResponse<Device>, Error>) -> Void) {
        
        let params: [String: Any] = [
            "$filter" : "device_uid eq '\(deviceUID)'"
        ]
        
        networkService.request(endpoint: "/me/devices", httpMethod: "GET", params: params) { (result) in
            completion(result)
        }
    }
    
    func putCertificate(deviceId: String, publicKey: String, completion: @escaping (Result<Device, Error>) -> Void) {
        
        let params: [String: Any] = [
            "public_key": publicKey
        ]
        
        networkService.request(endpoint: "/me/devices/\(deviceId)/certificate", httpMethod: "PUT", params: params) { (result) in
            completion(result)
        }
    }
}
