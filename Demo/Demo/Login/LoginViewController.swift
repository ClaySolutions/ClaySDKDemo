//
//  ViewController.swift
//  Example
//
//  Created by Jakov Videkovic on 03/12/2020.
//

import UIKit

class LoginViewController: UIViewController {

    let presenter = LoginPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.discoverConfiguration { (result) in
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func didTapLogin(_ sender: Any) {
        presenter.login(viewController: self)
    }
    
}

