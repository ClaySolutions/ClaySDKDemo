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
    
    func request<T: Codable>(endpoint: String, httpMethod: String, params: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(configuration.apiUrl)\(endpoint)")!)
        
        if let params = params {
            request = getRequestWith(params: params, for: httpMethod, from: request)
        }
        request.httpMethod = httpMethod
        
        guard let state = self.state else {
            completion(.failure("No state to fetch tokens"))
            return
        }
        state.performAction(freshTokens: { (accessToken, _, error) in
            if let _ = error {
                completion(.failure("API tokens expired, you can still use mobile key"))
                return
            }
            // save new state
            self.state = state
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
                    print(response.url?.absoluteURL ?? "")
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
    
    /// Embed params depending on method, GET params are put as query items, POST and PUT serialized to body as json
    private func getRequestWith(params: [String: Any], for httpMethod: String, from request: URLRequest) -> URLRequest {
        var updatedRequest = request
        switch httpMethod {
        case "POST", "PUT":
            updatedRequest.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        case "GET":
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = params.map({ (key, value) -> URLQueryItem in
                URLQueryItem(name: key, value: value as? String)
            })
            updatedRequest = URLRequest(url: urlComponents.url!)
        default:
            break
        }
        return updatedRequest
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
