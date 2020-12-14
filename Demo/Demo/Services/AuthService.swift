//
//  AuthService.swift
//  Demo
//
//  Created by Jakov Videkovic on 12/12/2020.
//

import Foundation
import AppAuth

class AuthService {
    
    @UserDefaultNSCoding(key: .serviceConfiguration)
    private var serviceConfig: OIDServiceConfiguration?
    
    @UserDefaultNSCoding(key: .state)
    private var state: OIDAuthState?
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration
    
    private let scopes = [OIDScopeOpenID, OIDScopeProfile, "user_api.full_access", "offline_access"]
    
    /// Indicates if user is logged in for the first time
    var isLoggedIn: Bool {
        state != nil
    }
    
    /// Fetches configuration for SaltoKS IDS. Configuration contains login, authenticate and other endpoints needed for using service. Configuration is save to UserDefaults for later use.
    func discoverConfiguration(completion: @escaping (Result<Void, Error>) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: configuration.issuerURL) { (configuration, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.serviceConfig = configuration
            completion(.success(()))
        }
    }
    
    /// Displays in app web browser with login page
    func login(from viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let authRequest = createAuthorizationRequest() else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.flow = OIDAuthorizationService.present(authRequest, presenting: viewController) { (response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let state = OIDAuthState(authorizationResponse: response!)
            self.fetchTokensUpdate(state: state, completion: completion)
        }
    }
    
    private func createAuthorizationRequest() -> OIDAuthorizationRequest? {
        guard let serviceConfig = self.serviceConfig,
              let clientId = configuration.clientId else { return nil }
        
        return OIDAuthorizationRequest(
            configuration: serviceConfig,
            clientId: clientId,
            scopes: scopes,
            redirectURL: configuration.redirectLoginURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil //["login_hint": "test@test.com"] if you set this it will automatically populate email field
        )
    }
    
    private func fetchTokensUpdate(state: OIDAuthState, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let tokenExchangeRequest = state.lastAuthorizationResponse.tokenExchangeRequest() else { return }
        
        OIDAuthorizationService.perform(tokenExchangeRequest) { response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Access token: \(response?.accessToken ?? "No access token")")
            print("Refersh token: \(response?.refreshToken ?? "No refresh token")")
            
            state.update(with: response, error: error)
            self.state = state
            
            completion(.success(()))
        }
    }
    
    /// Logout the user, it will  present in app browser that will immediately close if successful
    func logout(from viewController: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let idToken = state?.lastTokenResponse?.idToken,
              let serviceConfig = serviceConfig,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let agent = OIDExternalUserAgentIOS(presenting: viewController) else { return }

        let request = OIDEndSessionRequest(configuration: serviceConfig, idTokenHint: idToken, postLogoutRedirectURL: configuration.redirectLogoutURL, additionalParameters: nil)
        appDelegate.flow = OIDAuthorizationService.present(request, externalUserAgent: agent) { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let response = response else { return }
            print(response)
            
            HTTPCookieStorage.shared.cookies?.forEach { cookie in
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            self.state = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(.success(()))
            }
        }
    }
}
