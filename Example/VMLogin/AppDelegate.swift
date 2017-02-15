//
//  AppDelegate.swift
//  VMLogin
//
//  Created by Vasco Mouta on 29.01.17.
//  Copyright © 2017 zucred AG. All rights reserved.
//

import UIKit
import Fabric
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit
import DigitsKit
import VMLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let log = Log.getLogger(AppDelegate.name())  as! Log
    
    override class func initialize() {
        Log.enable(assignedLevel: .verbose)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        Fabric.with([Twitter.self, Digits.self])
        
        //let twitter = Twitter.sharedInstance()
        //let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:twitter.session())
        
        Twitter.sharedInstance().start(withConsumerKey: "LPXIExIKs4lAg2SXIt3zr3SRA", consumerSecret: "yAW1Tdj1uv6Fy98JeogHDMju2JU9yhkuAj6VGcEud7fqMbRjnk")
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Check for an existing Twitter or Digits session before presenting the sign in screen.
        if Twitter.sharedInstance().sessionStore.session() == nil && Digits.sharedInstance().session() == nil {
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let signInViewController: AnyObject! = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            //window?.rootViewController = signInViewController as? UIViewController
        } else {
            log.info("User Login")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        log.verbose("application.open url")
        
        // Comeback from Twitter
        if Twitter.sharedInstance().application(app, open:url, options:options) {
            log.verbose("Twitter")
            return true
        }
        
        // Comeback from Facebook
        if FBSDKApplicationDelegate.sharedInstance().application(app, open:url, options:options) {
            log.verbose("Facebook")
            return true
        }
        
        // Comeback from Google
        if GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:]) {
            log.verbose("Google")
            return true
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        log.debug()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log.debug()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        log.debug()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log.debug()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log.debug()
    }

}

extension AppDelegate: GIDSignInDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        log.verbose("GIDSignInDelegate.didDisconnectWithUser.didSignInFor")
        
        if let error = error { log.error(error); return}
        
        guard let authentication = user.authentication else { log.error("user.authentication is nil"); return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error { self.log.error(error); return }
        }
        log.verbose("login successful")
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        log.verbose("GIDSignInDelegate.didDisconnectWithUser")
        
    }
}

extension NSObject {
    
    public static func name() -> String {
        return fullName().components(separatedBy:".").last!
    }
    
    public static func fullName() -> String {
        return NSStringFromClass(self.classForCoder())
    }
    
    public func className() -> String {
        return classFullName().components(separatedBy:".").last!
    }
    
    public func classFullName() -> String {
        return NSStringFromClass(type(of: self))
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}
