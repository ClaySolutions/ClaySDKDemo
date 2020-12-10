//
//  MainViewController.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import UIKit

class MainViewController: UIViewController {
    
    let presenter = MainPresenter()
    
    override func viewDidLoad() {
        presenter.view = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.registerDevice()
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        presenter.logout(viewController: self)
    }
}


extension MainViewController: MainViewProtocol {
    func didLogout() {
        dismiss(animated: true, completion: nil)
    }
}
