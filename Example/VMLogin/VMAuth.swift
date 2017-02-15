/**
 * @name             VMAuth.swift
 * @partof           zucred AG
 * @description
 * @author	 		Vasco Mouta
 * @created			15/02/17
 *
 * Copyright (c) 2017 zucred AG All rights reserved.
 * This material, including documentation and any related
 * computer programs, is protected by copyright controlled by
 * zucred AG. All rights are reserved. Copying,
 * including reproducing, storing, adapting or translating, any
 * or all of this material requires the prior written consent of
 * zucred AG. This material also contains confidential
 * information which may not be disclosed to others without the
 * prior written consent of zucred AG.
 */

import Foundation
import FirebaseAuth

// MARK: - Log
// - The main logging class
open class VMAuth {
    
    
    
    
    func firebaseLogin(_ credential: FIRAuthCredential) {
            if let user = FIRAuth.auth()?.currentUser {
                // [START link_credential]
                user.link(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                        if let error = error {
                            return
                        }
                    // [END_EXCLUDE]
                }
                // [END link_credential]
            } else {
                // [START signin_credential]
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                                            // [END_EXCLUDE]
                        if let error = error {
            
                            // [END_EXCLUDE]
                            return
                        }
                }
            }
    }

    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        // [START signout]
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        // [END signout]
    }

}



