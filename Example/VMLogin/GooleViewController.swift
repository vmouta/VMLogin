//
//  GoogleViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import GoogleSignIn
import VMLogger

class GoogleViewController: UIViewController {

    let log = Log.getLogger(GoogleViewController.name())  as! Log
    
    @IBAction func logout(_ sender: Any) {
        // Google
        GIDSignIn.sharedInstance().signOut()
    }
    
    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGooleButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Google
extension GoogleViewController: GIDSignInUIDelegate {
    
    fileprivate func setupGooleButtons() {
        GIDSignIn.sharedInstance().uiDelegate = self
        let googleButton = GIDSignInButton()
        googleButton.center = self.view.center;
        view.addSubview(googleButton)
    }
    
    @IBAction func loginGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    /// MARK: GIDSignInUIDelegate
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        log.verbose("GIDSignInUIDelegate.present")
        self.present(viewController, animated: true)
    }
    
    // If implemented, this method will be invoked when sign in needs to dismiss a view controller.
    // Typically, this should be implemented by calling |dismissViewController| on the passed
    // view controller.
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        log.verbose("GIDSignInUIDelegate.dismiss")
        viewController.dismiss(animated: true)
    }
}
