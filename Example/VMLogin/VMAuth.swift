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

import UIKit

import CoreTelephony
import VMLogger
import Firebase

import Fabric

import DigitsKit
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

// MARK: - Log
// - The main logging class
open class VMAuth: NSObject {
    
    let log = Log.getLogger(String(describing: VMAuth.self))  as! Log
    
    /** @var handle
     @brief The handler for the auth state listener, to allow cancelling later.
     */
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    func logout() {

        //Digits
        Digits.sharedInstance().logOut()
        
        // Google
        GIDSignIn.sharedInstance().signOut()
        
        // Facebook
        FBSDKLoginManager().logOut()
        
        //Twitter
        let sessionStore = Twitter.sharedInstance().sessionStore
        if let userId = sessionStore.session()?.userID {
            sessionStore.logOutUserID(userId)
        }
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            self.log.error("Error signing out:\(signOutError)")
        }
    }
    
    func firebaseLogin(_ credential: FIRAuthCredential) {
        if let user = FIRAuth.auth()?.currentUser {
            user.link(with: credential) { (user, error) in
                guard error == nil else { self.log.error(error); return }
            }
        } else {
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                guard error == nil else { self.log.error(error); return }
            }
        }
    }
}


/// MARK: EmailPassword
extension VMAuth {
    
    func loginEmailPassword(email: String, pass: String) {
        FIRAuth.auth()?.fetchProviders(forEmail: email) { (providers, error) in
            guard error == nil else { self.log.error(error); return }
            if let providers = providers, providers.count > 0 {
                self.log.debug("Providers for email:\(email) - Providers:\(providers)");
                if providers.contains(FIREmailPasswordAuthProviderID) {
                    FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                        guard error == nil else { self.log.error(error); return }
                        guard let _ = user  else { self.log.error("No user"); return}
                        self.log.debug("Login User:\(email) - Pass:\(pass)");
                    })
                } else {
                    self.log.error("No \(FIREmailPasswordAuthProviderID) provider");
                }
            } else {
                self.log.debug("No providers, Create new User");
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                    guard error == nil else { self.log.error(error); return }
                    guard let _ = user  else { self.log.error("No user"); return}
                    self.log.debug("Login User:\(email) - Pass:\(pass)");
                })
            }
        }
    }
    
    /** @fn requestPasswordReset
     @brief Requests a "password reset" email be sent.
     */
    func requestPasswordReset(email: String) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
            guard error == nil else { self.log.error(error); return }
            self.log.debug("Reset password for email:\(email)");
        }
    }
}

/// MARK: Digits
extension VMAuth {
    func loginDigits() {
        let digits = Digits.sharedInstance()
        let configuration = DGTAuthenticationConfiguration(accountFields: .email)
        configuration?.phoneNumber = getCountryPhonceCode()
        
        configuration?.appearance = DGTAppearance()
        //configuration?.appearance.logoImage = UIImage(named: "logo")
        configuration?.appearance.labelFont = UIFont(name: "HelveticaNeue-Bold", size: 16)
        configuration?.appearance.bodyFont = UIFont(name: "HelveticaNeue-Italic", size: 16)
        configuration?.appearance.accentColor = UIColor(red:0.33, green:0.67, blue:0.93, alpha:1.0)
        //configuration?.appearance.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
        
        digits.authenticate(with: nil, configuration: configuration!) { (session, error) in
            guard error == nil else { self.log.error(error); return }
            guard let digitsSession = session  else { self.log.error("No digits session"); return}
            
            self.log.verbose();
            let token = digitsSession.authToken
            let secret = digitsSession.authTokenSecret
            self.log.debug("Login Digits Token:\(String(describing: token)) - Secret:\(String(describing: secret))");
            
            let digits = Digits.sharedInstance()
            let oauthSigning = DGTOAuthSigning(authConfig:digits.authConfig, authSession: session)
            let authHeaders = oauthSigning?.oAuthEchoHeadersToVerifyCredentials()
            let url = authHeaders?[ TWTROAuthEchoRequestURLStringKey ] as! String
            let authorization = authHeaders?[ TWTROAuthEchoAuthorizationHeaderKey ] as! String
        }
    }
    
    func getCountryPhonceCode () -> String?
    {
        let network_Info = CTTelephonyNetworkInfo()
        let carrier = network_Info.subscriberCellularProvider;
        let phoneCode = ((carrier?.isoCountryCode) ?? "").uppercased()
        self.log.verbose("getCountryPhonceCode:\(phoneCode)")
        let phoneCodes = ["BD": "+880", "BE": "+32", "BF": "+226", "BG": "+359", "BA": "+387", "BB": "+1-246", "WF": "+681", "BL": "+590", "BM": "+1-441", "BN": "+673", "BO": "+591", "BH": "+973", "BI": "+257", "BJ": "+229", "BT": "+975", "JM": "+1-876", "BV": "", "BW": "+267", "WS": "+685", "BQ": "+599", "BR": "+55", "BS": "+1-242", "JE": "+44-1534", "BY": "+375", "BZ": "+501", "RU": "+7", "RW": "+250", "RS": "+381", "TL": "+670", "RE": "+262", "TM": "+993", "TJ": "+992", "RO": "+40", "TK": "+690", "GW": "+245", "GU": "+1-671", "GT": "+502", "GS": "", "GR": "+30", "GQ": "+240", "GP": "+590", "JP": "+81", "GY": "+592", "GG": "+44-1481", "GF": "594", "GE": "995", "GD": "+1-473", "GB": "+44", "GA": "+241", "SV": "+503", "GN": "+224", "GM": "+220", "GL": "+299", "GI": "+350", "GH": "+233", "OM": "+968", "TN": "+216", "JO": "+962", "HR": "+385", "HT": "+509", "HU": "+36", "HK": "+852", "HN": "+504", "HM": " ", "VE": "+58", "PR": "+1-787", "PS": "+970", "PW": "+680", "PT": "+351", "SJ": "+47", "PY": "+595", "IQ": "+964", "PA": "+507", "PF": "+689", "PG": "+675", "PE": "+51", "PK": "+92", "PH": "+63", "PN": "+870", "PL": "+48", "PM": "+508", "ZM": "+260", "EH": "+212", "EE": "+372", "EG": "+20", "ZA": "+27", "EC": "+593", "IT": "+39", "VN": "+84", "SB": "+677", "ET": "+251", "SO": "+252", "ZW": "+263", "SA": "+966", "ES": "+34", "ER": "+291", "ME": "+382", "MD": "+373", "MG": "+261", "MF": "+590", "MA": "+212", "MC": "+377", "UZ": "+998", "MM": "+95", "ML": "+223", "MO": "+853", "MN": "+976", "MH": "+692", "MK": "+389", "MU": "+230", "MT": "+356", "MW": "+265", "MV": "+960", "MQ": "+596", "MP": "+1-670", "MS": "+1-664", "MR": "+222", "IM": "+44-1624", "UG": "+256", "TZ": "+255", "MY": "60", "MX": "+52", "IL": "+972", "FR": "+33", "IO": "+246", "SH": "+290", "FI": "+358", "FJ": "+679", "FK": "+500", "FM": "+691", "FO": "+298", "NI": "+505", "NL": "+31", "NO": "+47", "NA": "+264", "VU": "+678", "NC": "+687", "NE": "+227", "NF": "+672", "NG": "+234", "NZ": "+64", "NP": "+977", "NR": "+674", "NU": "+683", "CK": "+682", "XK": "", "CI": "+225", "CH": "+41", "CO": "+57", "CN": "+86", "CM": "+237", "CL": "56", "CC": "+61", "CA": "+1", "CG": "+242", "CF": "+236", "CD": "+243", "CZ": "+420", "CY": "+357", "CX": "+61", "CR": "+506", "CW": "+599", "CV": "+238", "CU": "+53", "SZ": "+268", "SY": "+963", "+SX": "+599", "KG": "+996", "KE": "+254", "SS": "+211", "SR": "+597", "KI": "+686", "KH": "+855", "KN": "+1-869", "KM": "+269", "ST": "+239", "SK": "+421", "KR": "+82", "SI": "+386", "KP": "+850", "KW": "+965", "SN": "+221", "SM": "+378", "SL": "+232", "SC": "248", "KZ": "7", "KY": "+1-345", "SG": "+65", "SE": "+46", "SD": "+249", "DO": "+1-809", "DM": "+1-767", "DJ": "+253", "DK": "+45", "VG": "+1-284", "DE": "+49", "YE": "+967", "DZ": "+213", "US": "+1", "UY": "+598", "YT": "+262", "UM": "+1", "LB": "+961", "LC": "+1-758", "LA": "+856", "TV": "+688", "TW": "886", "TT": "+1-868", "TR": "+90", "LK": "+94", "LI": "+423", "LV": "+371", "TO": "+676", "LT": "+370", "LU": "+352", "LR": "+231", "LS": "+266", "TH": "+66", "TF": "", "TG": "+228", "TD": "+235", "TC": "+1-649", "LY": "+218", "VA": "+379", "VC": "+1-784", "AE": "+971", "AD": "+376", "AG": "+1-268", "AF": "+93", "AI": "+1-264", "VI": "+1-340", "IS": "+354", "IR": "98", "AM": "+374", "AL": "+355", "AO": "+244", "AQ": "", "AS": "+1-684", "AR": "54", "AU": "+61", "AT": "+43", "AW": "+297", "IN": "+91", "AX": "+358-18", "AZ": "+994", "IE": "+353", "ID": "+62", "UA": "+380", "QA": "+974", "MZ": "+258"];
        return phoneCodes[phoneCode]
    }
}

/// MARK: Facebook
extension VMAuth {
    
    func loginFacebook(from fromViewController: UIViewController!) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: nil) { (result, error) in
            guard error == nil else { self.log.error(error); return }
            guard result!.isCancelled == false else { self.log.error("Login Cancel by the user"); return }
            
            self.log.verbose()
            let tokenString = FBSDKAccessToken.current().tokenString
            self.log.debug("Twitter TokenString:\(String(describing: tokenString))")
            let credential = FIRFacebookAuthProvider.credential(withAccessToken:tokenString! )
            self.firebaseLogin(credential)
        }
    }
}

/// MARK: GitHub
extension VMAuth {
    
    func loginGitHub() {
       
    }
}

/// MARK: Google
extension VMAuth: GIDSignInDelegate {
    
    func loginGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: GIDSignInDelegate
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else { self.log.error(error); return }
        guard let authentication = user.authentication else { self.log.error("No Google User"); return }
        
        log.verbose()
        let token = authentication.idToken
        let secret = authentication.accessToken
        self.log.debug("Twitter Token:\(String(describing: token)) - Secret:\(String(describing: secret))");
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        self.firebaseLogin(credential)
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        log.verbose()
    }
}

/// MARK: Twitter
extension VMAuth {
    
    func loginTwitter() {
        Twitter.sharedInstance().logIn(with: nil) { (session, error) in
            guard error == nil else { self.log.error(error); return }
            guard let twitterSession = session  else { self.log.error("No twitter session"); return}
            
            self.log.verbose();
            let token = twitterSession.authToken
            let secret = twitterSession.authTokenSecret
            self.log.debug("Twitter Token:\(token) - Secret:\(secret)");
            let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            self.firebaseLogin(credential)
        }
    }
}

// MARK: - Singleton
extension VMAuth {
    
    static let sharedInstance = VMAuth()
    
    static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        VMAuth.sharedInstance.log.verbose()
        
        let kitClasses: [Any] = [Twitter.self, Digits.self]
        VMAuth.sharedInstance.log.verbose("Init Fabric wiht:\(kitClasses)")
        Fabric.with(kitClasses)

        //let consumerKey = Bundle.main.object(forInfoDictionaryKey: "consumerKey"),
        //let consumerSecret = Bundle.main.object(forInfoDictionaryKey: "consumerSecret")
        let consumerKey = "LPXIExIKs4lAg2SXIt3zr3SRA"
        let consumerSecret = "yAW1Tdj1uv6Fy98JeogHDMju2JU9yhkuAj6VGcEud7fqMbRjnk"
        VMAuth.sharedInstance.log.verbose("Init Twitter wiht:\(consumerKey) - \(consumerSecret)")
        Twitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
        let clientID = FIRApp.defaultApp()?.options.clientID
        VMAuth.sharedInstance.log.verbose("Init Google wiht FIRApp.clientID:\(String(describing: clientID))")
        GIDSignIn.sharedInstance().clientID = clientID
        GIDSignIn.sharedInstance().delegate = VMAuth.sharedInstance
        
        VMAuth.sharedInstance.log.verbose("Init Facebook")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        VMAuth.sharedInstance.handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            VMAuth.sharedInstance.log.debug("addStateDidChangeListener: \(auth) - \(String(describing: user))")
        }
        
        if FIRAuth.auth()?.currentUser == nil && Digits.sharedInstance().session() == nil {
            return false
        } else {
            return true
        }
    }
    
    static func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VMAuth.sharedInstance.log.verbose()
        
        // Comeback from Twitter
        if Twitter.sharedInstance().application(app, open: url, options: [UIApplicationOpenURLOptionsKey.sourceApplication:sourceApplication ?? ""]) {
            VMAuth.sharedInstance.log.verbose("Twitter handle")
            return true
        }
        
        // Comeback from Facebook
        if FBSDKApplicationDelegate.sharedInstance().application(app, open:url, sourceApplication: sourceApplication, annotation: annotation) {
            VMAuth.sharedInstance.log.verbose("Facebook handle")
            return true
        }
        
        // Comeback from Google
        if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
            VMAuth.sharedInstance.log.verbose("Google handle")
            return true
        }
        return false
    }
}


func showEmailAddress() {
    
    let token = FBSDKAccessToken.current();
    let credentials = FIRFacebookAuthProvider.credential(withAccessToken: (token?.tokenString)!)
    FIRAuth.auth()?.signIn(with: credentials, completion: {
        (user, err) in
        if err != nil {
            print(err)
            return
        }
        print("Success", user)
    })
    
    FBSDKGraphRequest(graphPath: "/me", parameters:["fields": "id, name, email"]).start{
        (connection, result, err) in
        if err != nil {
            print(err)
            return
        }
        print(result)
    }
}

