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
}

class MainPresenter {
    
    var view: MainViewProtocol?
    
    private let deviceService = DeviceService()
    
    @UserDefaultNSCoding(key: .state)
    private var state: OIDAuthState?
    
    @UserDefaultNSCoding(key: .serviceConfiguration)
    private var serviceConfig: OIDServiceConfiguration?
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration?
    
    private lazy var claySDK: ClaySDK = {
        ClaySDK(installationUID: UIDevice.current.identifierForVendor!.uuidString, apiKey: configuration!.apiPublicKey!, delegate: self)
    }()
    
    func logout(viewController: UIViewController) {
        guard let idToken = state?.lastTokenResponse?.idToken,
              let serviceConfig = serviceConfig,
              let logoutURL = configuration?.redirectLogoutURL,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let agent = OIDExternalUserAgentIOS(presenting: viewController) else { return }

        let request = OIDEndSessionRequest(configuration: serviceConfig, idTokenHint: idToken, postLogoutRedirectURL: logoutURL, additionalParameters: nil)
        appDelegate.flow = OIDAuthorizationService.present(request, externalUserAgent: agent) { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let response = response {
                print(response)
                HTTPCookieStorage.shared.cookies?.forEach { cookie in
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
                self.state = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.view?.didLogout()
                }
            }
        }
    }
    
    func registerDevice() {
        deviceService.registerDevice(deviceName: UIDevice.current.name, deviceUID: UIDevice.current.identifierForVendor!.uuidString, publicKey: claySDK.getPublicKey())
    }
}

extension MainPresenter: ClayDelegate {
    
    func didReceive(error: Error) {
        print(error.localizedDescription)
    }
}
