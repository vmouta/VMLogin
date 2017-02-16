//
//  TwitterViewController.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import VMLogger

import TwitterKit

class TwitterViewController: UIViewController {

    let log = Log.getLogger(TwitterViewController.name())  as! Log

    @IBAction func logout(_ sender: Any) {
        VMAuth.sharedInstance.logout()
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
        VMAuth.sharedInstance.loginTwitter()
    }

    /// MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTwitterButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/// MARK: Twitter
extension TwitterViewController {
    
    fileprivate func setupTwitterButtons() {
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error { self.log.error(err); return }
            
            guard let token = session?.authToken else {return}
            guard let secret = session?.authTokenSecret else {return}
            
        }
        twitterButton.center = self.view.center
        twitterButton.loginMethods = [.systemAccounts, .webBased]
        view.addSubview(twitterButton)
    }
}
