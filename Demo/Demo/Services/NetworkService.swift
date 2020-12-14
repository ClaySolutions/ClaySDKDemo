//
//  NetworkService.swift
//  Demo
//
//  Created by Jakov Videkovic on 11/12/2020.
//

import Foundation
import AppAuth

class NetworkService {
    
    @UserDefaultNSCoding(key: .state)
    private var state: OIDAuthState?
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration
    
    func request<T: Codable>(endpoint: String, httpMethod: String, params: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(configuration.apiUrl)\(endpoint)")!)
        request.httpMethod = httpMethod
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        state?.performAction(freshTokens: { (accessToken, _, error) in
            if let _ = error {
                completion(.failure("API tokens expired, you can still use mobile key"))
                return
            }
            guard let accessToken = accessToken else { return }
            // set required headers
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // background thread, we should receive callbacks on main thread
                let mainThreadCompletion: ((Result<T, Error>) -> Void) = { result in
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
                
                // error while executing network call
                if let error = error {
                    print(error)
                    mainThreadCompletion(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else { return }
                guard let data = data else { return }
                
                // print full response from server
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(json)
                }
                
                switch response.statusCode {
                case 200..<300:
                    do { // try to decode successful network response
                        let model = try JSONDecoder().decode(T.self, from: data)
                        mainThreadCompletion(.success(model))
                    } catch {
                        mainThreadCompletion(.failure(error))
                    }
                case 400..<500:
                    do { // try to decode error from server
                        let model = try JSONDecoder().decode(SaltoError.self, from: data)
                        mainThreadCompletion(.failure(model.message ?? "Unknown error"))
                    } catch {
                        mainThreadCompletion(.failure(error))
                    }
                default:
                    break
                }
                
            }.resume()
        })
    }
    
}

class SaltoError: Codable {
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
    }
}

extension String: Error {} // Enables us to throw a string

extension String: LocalizedError { // Adds error.localizedDescription to Error instances
    public var errorDescription: String? { return self }
}
