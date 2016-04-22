//
//  ViewController.swift
//  JSTouchID
//
//  Created by Jim on 4/20/16.
//  Copyright © 2016 Jim. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthViewController: UIViewController {
    
    // Keychain
    let key = "MyKey"
    let keychain = KeychainWrapper.standardKeychainAccess()
    
    // Local Authentication
    var laContext = LAContext()
    let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.editable = false
        textView.layer.borderColor = UIColor.blueColor().CGColor
        textView.layer.borderWidth = 2.0

        touchIDAvailable()        
    }
    
    func touchIDAvailable() {
        if laContext.canEvaluatePolicy(policy, error: nil) {
            log( "Touch ID available")
        } else {
            print( "No Touch ID for you")
        }
    }
    
    func log(string: String) {
        let text = textView.text ?? ""
        textView.text = text + "\n" + string + "\n"
        guard let viewText = textView.text else {return}
        let range = NSMakeRange((viewText as NSString).length - 1, 1)
        textView.scrollRangeToVisible(range)
    }

    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func localAuthTapped(sender: UIButton) {
        log("local auth tapped")
        laContext.evaluatePolicy(policy, localizedReason: "Local Authentication with TouchID") { (success: Bool, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.log("Successful local authentication with touch ID")
                } else {
                    self.log("Local auth with touch ID failed with error: \(error!)")
                }
            }
        }
    }
    
    
    @IBAction func resetLAContextTapped(sender: UIButton) {
        log("Reset Local Auth Context Tapped")
        laContext.invalidate()
        laContext = LAContext()
    }
    
    @IBAction func keychainAuthTapped(sender: UIButton) {
        log("Keychain Auth tapped")
    }

    
    func storeSecret() {
        let saveSuccessful: Bool = keychain.setString("Some String", forKey: key)
        print("Saved successfully: \(saveSuccessful)")
    }
    
    func retrieveSecret() {
        let retrievedString = keychain.stringForKey(key)
        print("Retrieved string: \(retrievedString)")
    }
    
    
}

