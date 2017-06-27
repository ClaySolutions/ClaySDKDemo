//
//  ViewController.swift
//  ClaySDKDemoApp
//
//  Created by Arthur Schenk on 20/06/2017.
//  Copyright © 2017 Clay Solutions. All rights reserved.
//

import UIKit
import ClaySDK

class ViewController: UIViewController {
    @IBOutlet weak var encryptedKeyField: UITextView!
    @IBOutlet weak var openDoorButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var publicKeyField: UITextView!
    @IBOutlet weak var messageLabel: UILabel!

    private var claySDK: ClaySDK?

    override func viewDidLoad() {
        super.viewDidLoad()

        claySDK = ClaySDK(delegate: self)

        publicKeyField.text = claySDK?.getPublicKey()

        openDoorButton.addTarget(
            self,
            action: #selector(didTapOpenDoor),
            for: .touchUpInside
        )
        copyButton.addTarget(
            self,
            action: #selector(didTapCopy),
            for: .touchUpInside
        )
        encryptedKeyField.delegate = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func didTapOpenDoor() {
        let input = encryptedKeyField.text ?? ""
        if input.characters.count == 0 {
            alert(title: "Error", message: "No encrypted text entered")
            return
        }
        claySDK?.openDoor(with: input, delegate: self)
    }

    func didTapCopy() {
        UIPasteboard.general.string = claySDK?.getPublicKey()
        show(message: "Public key copied")
        print("-------------------------------")
        print("------- your public key -------")
        print("-------------------------------")
        print(publicKeyField.text ?? "")
        print("-------------------------------")
        print("-------------------------------")
    }

    func show(message: String) {
        messageLabel.alpha = 1.0
        messageLabel.text = message

        UIView.animate(withDuration: 0.5, delay: 3.0, animations: {
            self.messageLabel.alpha = 0.0
        })
    }

    func alert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: UIAlertActionStyle.default,
                handler: nil
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: OpenDoorDelegate {
    /// Open handler
    func didOpen(with result: ClayResult) {
        if result == .accessDenied {
            show(message: "Acces to the door denied")
            return
        }
        if result == .accessGranted {
            show(message: "Door opened successfully")
            return
        }

        show(message: "Received unknown state from the door")
    }


    func didFindLock() {
        show(message: "Lock found")
    }

    func didOpen() {
        show(message: "Door opened successfully")
    }

    func didReceive(error: Error) {
        alert(title: "Error", message: error.localizedDescription)
    }
}

extension ViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
