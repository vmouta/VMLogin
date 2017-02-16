//
//  EmailPassViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import VMLogger
import FirebaseAuth

class EmailPassViewController: UIViewController {
    
    let log = Log.getLogger(EmailPassViewController.name())  as! Log
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func logout(_ sender: Any) {
        VMAuth.sharedInstance.logout()
    }
    
    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Google
extension EmailPassViewController {
    
    @IBAction func loginEmailPass(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
                // [START headless_email_auth]
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    // [START_EXCLUDE]
                        if let error = error {
                            return
                        }
                        self.navigationController!.popViewController(animated: true)
                    // [END_EXCLUDE]
                }
                // [END headless_email_auth]
        } else {
            print("email/password can't be empty")
        }
    }
    
    @IBAction func didCreateAccount(_ sender: AnyObject) {
        // [START create_user]
        FIRAuth.auth()?.createUser(withEmail: "", password: "") { (user, error) in
            // [START_EXCLUDE]
            if let error = error {
                return
            }
            print("\(user!.email!) created")
        }
    }
    
    /** @fn requestPasswordReset
     @brief Requests a "password reset" email be sent.
     */
    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
        // [START password_reset]
        FIRAuth.auth()?.sendPasswordReset(withEmail: "") { (error) in
                if let error = error {
                    return
                }
            // [END_EXCLUDE]
        }
        // [END password_reset]
    }
    
    /** @fn getProvidersForEmail
     @brief Prompts the user for an email address, calls @c FIRAuth.getProvidersForEmail:callback:
     and displays the result.
     */
    @IBAction func didGetProvidersForEmail(_ sender: AnyObject) {
        // [START get_providers]
        FIRAuth.auth()?.fetchProviders(forEmail: "") { (providers, error) in
            // [START_EXCLUDE]
                if let error = error {
                    return
                }
            // [END_EXCLUDE]
        }
        // [END get_providers]
    }
}
