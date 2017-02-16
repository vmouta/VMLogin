//
//  DigitsViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import VMLogger

import DigitsKit

class DigitsViewController: UIViewController {

    let log = Log.getLogger(DigitsViewController.name())  as! Log
    var authButton: DGTAuthenticateButton? = nil
    
    @IBAction func logout(_ sender: Any) {
        VMAuth.sharedInstance.logout()
        authButton?.isEnabled = true
    }
    
    @IBAction func loginDigits(_ sender: Any) {
        VMAuth.sharedInstance.loginDigits()
    }
    
    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDigitsButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Digits
extension DigitsViewController {
    
    fileprivate func setupDigitsButtons() {
        authButton = DGTAuthenticateButton(authenticationCompletion: { (session, error) in
            if (session != nil) {
                // TODO: associate the session userID with your user model
                let message = "Phone number: \(session!.phoneNumber), \(session!.authToken), \(session!.authTokenSecret), email: \(String(describing: session?.emailAddress))"
                let alertController = UIAlertController(title: "You are logged in!", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
                self.present(alertController, animated: true, completion: .none)
               
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        })
        
        authButton?.center = self.view.center
        self.view.addSubview(authButton!)
        
        let digits = Digits.sharedInstance()
        if let _ = digits.session()?.authToken {
            authButton?.isEnabled = false
            if (digits.session()?.emailAddressIsVerified == false) {
                print("Email not verified!")
            }
        }
    }
}
