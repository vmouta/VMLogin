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
    
    @IBAction func loginEmailPass(_ sender: Any) {
        if let email = self.emailField.text, let password = self.passwordField.text {
            VMAuth.sharedInstance.loginEmailPassword(email: email, pass: password)
        }
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
