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
    
    func toggleLoginButton(enabled: Bool)
    
    func goToMainViewController()
}


class LoginPresenter {
    
    var view: LoginViewProtocol?
    
    @UserDefaultNSCoding(key: .serviceConfiguration)
    private var serviceConfig: OIDServiceConfiguration?
    
    @UserDefaultNSCoding(key: .state)
    private var state: OIDAuthState?
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration?
    
    private let scopes = [OIDScopeOpenID, OIDScopeProfile, "user_api.full_access", "offline_access"]
    
    
    /// Fetches configuration for SaltoKS IDS. Configuration contains login, authenticate and other endpoints needed for using service. Configuration is save to UserDefaults for later use.
    func discoverConfiguration() {
        self.view?.toggleLoginButton(enabled: false)
        
        guard let issuerUrl = configuration?.issuerURL else { return }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUrl) { (configuration, error) in
            if let error = error {
                self.view?.showError(message: error.localizedDescription)
                return
            }
            self.serviceConfig = configuration
            self.view?.toggleLoginButton(enabled: true)
        }
    }
    
    /// Displays in app web browser with login page
    func login(viewController: UIViewController) {
        guard let authRequest = createAuthorizationRequest() else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.flow = OIDAuthorizationService.present(authRequest, presenting: viewController) { (response, error) in
            if let error = error {
                self.view?.showError(message: error.localizedDescription)
                return
            }
            let state = OIDAuthState(authorizationResponse: response!)
            self.fetchTokens(state: state)
        }
    }
    
    private func createAuthorizationRequest() -> OIDAuthorizationRequest? {
        guard let serviceConfig = self.serviceConfig,
              let config = self.configuration,
              let clientId = config.clientId else { return nil }
        
        return OIDAuthorizationRequest(
            configuration: serviceConfig,
            clientId: clientId,
            scopes: scopes,
            redirectURL: config.redirectLoginURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil //["login_hint": email] if you set this it will automatically populate email field
        )
    }
    
    private func fetchTokens(state: OIDAuthState) {
        
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
            
            self.view?.goToMainViewController()
        }
    }
}
