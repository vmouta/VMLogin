//
//  FacebookViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import VMLogger

import FBSDKLoginKit

class FacebookViewController: UIViewController {

    let log = Log.getLogger(FacebookViewController.name())  as! Log

    @IBAction func logout(_ sender: Any) {
        VMAuth.sharedInstance.logout()
    }
    
    @IBAction func loginFacebook(_ sender: Any) {
        VMAuth.sharedInstance.loginFacebook(from: self)
    }
    
    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFacebookButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Facebook
extension FacebookViewController: FBSDKLoginButtonDelegate {
    
    fileprivate func setupFacebookButtons() {
        let loginFBButton = FBSDKLoginButton()
        loginFBButton.delegate = self
        loginFBButton.readPermissions = ["email", "public_profile", "user_friends"]
        loginFBButton.center = self.view.center;
        view.addSubview(loginFBButton)
    }
    
    func showEmailAddress() {
        let token = FBSDKAccessToken.current();
        
        FBSDKGraphRequest(graphPath: "/me", parameters:["fields": "id, name, email"]).start{
            (connection, result, error) in
            if let error = error { self.log.error(error); return }
            self.log.verbose("Success FBSDKGraphRequest.start - \(String(describing: result))")
        }
    }

    /// MARK: FBSDKLoginButtonDelegate
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error { log.error(error); return }
        log.verbose("Success FBSDKLoginButtonDelegate.loginButton")
        showEmailAddress()
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        log.verbose("FBSDKLoginButtonDelegate.loginButtonDidLogOut")
    }
}

