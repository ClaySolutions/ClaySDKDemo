//
//  LoginPresenter.swift
//  Demo
//
//  Created by Jakov Videkovic on 08/12/2020.
//

import Foundation
import AppAuth

protocol LoginViewProtocol: class {
    
    func showError(message: String)
}


class LoginPresenter {
    
    var view: LoginViewProtocol?
    
    @UserDefaultNSCoding(key: "Config")
    var serviceConfig: OIDServiceConfiguration?
    
    @UserDefaultNSCoding(key: "State")
    var state: OIDAuthState?
    
    let scopes = [OIDScopeOpenID, OIDScopeProfile, "user_api.full_access", "offline_access"]
    
    func discoverConfiguration(_ completion: @escaping (Result<Void, Error>) -> Void) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: "https://clp-test-identityserver.my-clay.com")!) { (configuration, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.serviceConfig = configuration
        }
    }
    
    func login(viewController: UIViewController) {
        guard let authRequest = createAuthorizationRequest() else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.flow = OIDAuthorizationService.present(authRequest, presenting: viewController) { (response, error) in
            if let error = error {
                print(error)
                return
            }
            let state = OIDAuthState(authorizationResponse: response!)
            self.fetchTokens(state: state)
        }
    }
    
    private func createAuthorizationRequest() -> OIDAuthorizationRequest? {
        guard let config = self.serviceConfig else { return nil }
        return OIDAuthorizationRequest(
            configuration: config,
            clientId: "48b34030-9053-4a25-8a32-b8f0bde57ef2",
            scopes: scopes,
            redirectURL: URL(string: "nl.moboa.myclay.debug:/oauth2redirect/redirect")!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil //["login_hint": email] if you set this it will automatically populate email field
        )
    }
    
    private func fetchTokens(state: OIDAuthState) {
        
        guard let tokenExchangeRequest = state.lastAuthorizationResponse.tokenExchangeRequest() else { return }
        
        OIDAuthorizationService.perform(tokenExchangeRequest) { response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            print("Access token: \(response?.accessToken ?? "No access token")")
            print("Refersh token: \(response?.refreshToken ?? "No refresh token")")
            
            state.update(with: response, error: error)
            self.state = state
        }
    }
}
