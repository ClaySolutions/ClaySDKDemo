//
//  MainPresenter.swift
//  Demo
//
//  Created by Jakov Videkovic on 10/12/2020.
//

import Foundation
import AppAuth
import ClaySDK
import SaltoJustINMobileSDK

protocol MainViewProtocol {
    
    func didLogout()
    
    func showError(message: String)
    
    func showStatus(message: String)
    
    func toggleOpenButton(visible: Bool)
}

class MainPresenter {
    
    var view: MainViewProtocol?
    
    private let deviceService = DeviceService()
    
    private let authService = AuthService()
    
    @PropertyList(key: .configuration)
    private var configuration: Configuration
    
    @UserDefaultCodable(key: .device)
    private var device: Device?
    
    @UserDefaultCodable(key: .mobileKey)
    private var mobileKey: MobileKeyData?
    
    private var deviceUID: String {
        //This can be any string that is unique for currently running device.
        //This identifier is used to check if user already registered device.
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    private lazy var claySDK: ClaySDK = {
        ClaySDK(installationUID: deviceUID, apiKey: configuration.apiPublicKey!, delegate: self)
    }()
    
    //MARK: USING CLAY SDK TO OPEN DOOR
    
    func openLock() {
        guard let mobileKey = mobileKey?.mKeyData else { return }
        claySDK.openDoor(with: mobileKey, delegate: self)
        view?.showStatus(message: "Sending mobile key")
    }
    
    //MARK: MOBILE KEY AND DEVICE API HANDLING
    
    func checkDeviceAndMobileKey() {
        //Check if we have locally saved device and mobile key
        if let device = device, let _ = mobileKey {
            if device.mobileKey?.isMobileKeyExpairingIn7days == true {
                //Mobile key for user will expire soon, we need to update certificate and fetch new mobile key
                updateDeviceCertificate()
                return
            }
            // Mobile key is ready for use
            view?.showStatus(message: "Mobile key ready for use")
            view?.toggleOpenButton(visible: true)
            return
        }
        // We do not have mobile key or device. We are fetching user devices to see if device is already registered
        getDevices()
    }
    
    private func getDevices() {
        view?.showStatus(message: "Getting user devices")
        deviceService.getDevices(with: deviceUID) { (result) in
            switch result {
            case .success(let deviceList):
                if let device = deviceList.items.first {
                    //Device already exists in SaltoKS service, we don't need to register new device but reuse existing one and update certificate
                    self.device = device
                    self.updateDeviceCertificate()
                    return
                }
                //Device does not exist, we need to do device registration
                self.registerDevice()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func registerDevice() {
        view?.showStatus(message: "Registering device")
        deviceService.registerDevice(
            deviceName: UIDevice.current.name,
            deviceUID: deviceUID,
            publicKey: claySDK.getPublicKey()
        ) { result in
            switch result {
            case .success(let device):
                self.device = device
                self.downloadMobileKey()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func updateDeviceCertificate() {
        view?.showStatus(message: "Updating device certificate")
        guard let deviceId = device?.id else { return }
        deviceService.putCertificate(deviceId: deviceId, publicKey: claySDK.getPublicKey()) { (result) in
            switch result {
            case .success(_):
                self.downloadMobileKey()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func downloadMobileKey() {
        view?.showStatus(message: "Downloading mobile key")
        guard let device = self.device else { return }
        deviceService.downloadMobileKey(deviceId: device.id) { result in
            switch result {
            case .success(let mkeyData):
                self.mobileKey = mkeyData
                self.checkDeviceAndMobileKey()
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    //MARK: LOGOUT
    
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
}

//MARK: ClaySDK - OpenDoorDelegate
extension MainPresenter: OpenDoorDelegate {
    
    func didFindLock() {
        view?.showStatus(message: "Lock found")
    }
    
    func didOpen(with result: ClayResult?) {
        guard let opResult = result?.getOpResult() else { return }
        if opResult == AUTH_SUCCESS_CANCELLED_KEY {
            view?.showStatus(message: "Mobile key expired, reactivating")
            updateDeviceCertificate()
            return
        }
        if SSOpResult.getGroup(opResult) == .groupAccepted {
            view?.showStatus(message: "Mobile key received")
            return
        }
        view?.showStatus(message: "Problem while sending mobile key")
    }
    
    func didReceiveTimeout() {
        view?.showStatus(message: "Lock not found, timeout")
    }
    
    func alreadyRunning() {
        view?.showStatus(message: "Mobile key already running")
    }
    
    func didReceiveBLE(error: Error) {
        view?.showStatus(message: error.localizedDescription)
    }
    
    func didReceive(error: Error) {
        view?.showStatus(message: error.localizedDescription)
    }
}
