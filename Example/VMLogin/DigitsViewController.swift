//
//  DigitsViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import DigitsKit
import VMLogger

class DigitsViewController: UIViewController {

    let log = Log.getLogger(DigitsViewController.name())  as! Log
    var authButton: DGTAuthenticateButton? = nil
    
    @IBAction func logout(_ sender: Any) {
        //Digits
        Digits.sharedInstance().logOut()
        authButton?.isEnabled = true
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
    
    @IBAction func loginDigits(_ sender: Any) {
        let digits = Digits.sharedInstance()
        let configuration = DGTAuthenticationConfiguration(accountFields: .email)
        //let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        configuration?.phoneNumber = "+41"
        
        configuration?.appearance = DGTAppearance()
        //configuration?.appearance.logoImage = UIImage(named: "logo")
        configuration?.appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        configuration?.appearance.bodyFont = UIFont(name: "HelveticaNeue-Italic", size: 16)
        configuration?.appearance.accentColor = UIColor(red:0.33, green:0.67, blue:0.93, alpha:1.0)
        //configuration?.appearance.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
        
        digits.authenticate(with: nil, configuration: configuration!) { session, error in
            // Country selector will be set to Spain and phone number field will be set to 5555555555
           
            
            let digits = Digits.sharedInstance()
            let oauthSigning = DGTOAuthSigning(authConfig:digits.authConfig, authSession: session)
            let authHeaders = oauthSigning?.oAuthEchoHeadersToVerifyCredentials()
            let url = authHeaders?[ TWTROAuthEchoRequestURLStringKey ] as! String
            let authorization = authHeaders?[ TWTROAuthEchoAuthorizationHeaderKey ] as! String
        }
    }
}
