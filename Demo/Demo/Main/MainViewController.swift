//
//  MainViewController.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var openLockBtn: UIButton!
    
    
    let presenter = MainPresenter()
    
    override func viewDidLoad() {
        presenter.view = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openLockBtn.isHidden = true
        presenter.checkDeviceAndMobileKey()
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        presenter.logout(viewController: self)
    }
    
    @IBAction func didTapOpenLock(_ sender: Any) {
        presenter.openLock()
    }
}


extension MainViewController: MainViewProtocol {
    func didLogout() {
        dismiss(animated: true, completion: nil)
    }
    
    func showError(message: String) {
        errorLabel.text = message
    }
    
    func showStatus(message: String) {
        statusLabel.text = message
    }
    
    func toggleOpenButton(visible: Bool) {
        openLockBtn.isHidden = !visible
    }
}
