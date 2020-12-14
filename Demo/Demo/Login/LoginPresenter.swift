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
    
    private let authService = AuthService()
    
    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
    
    func discoverConfiguration() {
        self.view?.toggleLoginButton(enabled: false)
        
        authService.discoverConfiguration { (result) in
            switch result {
            case .success:
                self.view?.toggleLoginButton(enabled: true)
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func login(viewController: UIViewController) {
        
        authService.login(from: viewController) { (result) in
            switch result {
            case .success:
                self.view?.goToMainViewController()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
}
