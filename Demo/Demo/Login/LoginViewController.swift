//
//  ViewController.swift
//  Example
//
//  Created by Jakov Videkovic on 03/12/2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let presenter = LoginPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.discoverConfiguration()
    }

    @IBAction func didTapLogin(_ sender: Any) {
        presenter.login(viewController: self)
    }
}

extension LoginViewController: LoginViewProtocol {
    func showError(message: String) {
        errorLabel.text = message
    }
    
    func toggleLoginButton(enabled: Bool) {
        loginButton.isEnabled = enabled
    }
    
    func goToMainViewController() {
        performSegue(withIdentifier: "mainSegue", sender: self)
    }
}

