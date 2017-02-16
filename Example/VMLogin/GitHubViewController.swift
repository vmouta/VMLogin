//
//  GitHubViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import VMLogger

class GitHubViewController: UIViewController {

    let log = Log.getLogger(GitHubViewController.name())  as! Log
    
    @IBAction func logout(_ sender: Any) {
        VMAuth.sharedInstance.logout()
    }
    
    @IBAction func loginGitHub(_ sender: Any) {
        
    }
    
    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGitHubButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Google
extension GitHubViewController {
    
    fileprivate func setupGitHubButtons() {
        
    }
}
