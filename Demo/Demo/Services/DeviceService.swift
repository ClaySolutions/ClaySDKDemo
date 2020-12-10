//
//  DeviceService.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import Foundation
import AppAuth

class DeviceService {
    
    @UserDefaultNSCoding(key: .state)
    private var state: OIDAuthState?
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration
    
    func registerDevice(deviceName: String, deviceUID: String, publicKey: String) {
        var request = URLRequest(url: URL(string: "\(configuration.apiUrl)/me/devices")!)
        request.httpMethod = "POST"
        
        let paramsDict: [String: Any] = [
            "device_name": deviceName.prefix(49), // backend allows max 50 characters
            "device_uid": deviceUID,
            "public_key": publicKey
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramsDict, options: [])
        
        state?.performAction(freshTokens: { (accessToken, _, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let accessToken = accessToken else { return }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "IDENT")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            print(request.allHTTPHeaderFields)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        })
        
        
    }
}
