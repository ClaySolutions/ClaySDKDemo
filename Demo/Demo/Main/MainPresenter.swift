//
//  MainPresenter.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import Foundation
import AppAuth
import ClaySDK

protocol MainViewProtocol {
    
    func didLogout()
    
    func showError(message: String)
}

class MainPresenter {
    
    var view: MainViewProtocol?
    
    private let deviceService = DeviceService()
    
    private let authService = AuthService()
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration
    
    private lazy var claySDK: ClaySDK = {
        ClaySDK(installationUID: UIDevice.current.identifierForVendor!.uuidString, apiKey: configuration.apiPublicKey!, delegate: self)
    }()
    
    func logout(viewController: UIViewController) {
        authService.logout(from: viewController) { (result) in
            switch result {
            case .success:
                self.view?.didLogout()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func registerDevice() {
        deviceService.registerDevice(
            deviceName: UIDevice.current.name,
            deviceUID: UIDevice.current.identifierForVendor!.uuidString,
            publicKey: claySDK.getPublicKey()
        ) { result in
            switch result {
            case .success(let device):
                print(device)
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
}

extension MainPresenter: ClayDelegate {
    
    func didReceive(error: Error) {
        print(error.localizedDescription)
    }
}
