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
    var laContext: LAContext?
    var policy: LAPolicy? = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
    let policies = [
        "DeviceOwnerAuthentication",
        "DeviceOwnerAuthenticationWithBiometrics"
    ]
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var policyPicker: UIPickerView!
    
    @IBOutlet weak var policyPickerTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextView()
        configureLAContext()
        touchIDAvailable()
    }
}

//MARK: - LAContext -
extension LocalAuthViewController {
    private func configureLAContext() {
        laContext = LAContext()
        laContext?.localizedFallbackTitle = "Fallback Title"
    }
    
    private func setLaPolicy(index: Int) {
        switch index {
        case 0:
            policy = LAPolicy.DeviceOwnerAuthentication
        case 1:
            policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        default:
            policy = nil
            log("Policy index: \(index) out of range")
        }
    }
    
    func touchIDAvailable() {
        let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        if ((laContext!.canEvaluatePolicy(policy, error: nil)) ) {
            log( "Touch ID available")
        } else {
            log( "No Touch ID for you")
        }
    }
}

//MARK: - IBActions -
extension LocalAuthViewController {
    
    @IBAction func authenticateTapped(sender: UIButton) {
        log("Authenticate tapped")
        laContext?.evaluatePolicy(policy!, localizedReason: "Local Authentication with TouchID") { (success: Bool, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.log("Successful local authentication with touch ID")
                } else {
                    self.log("Local auth with touch ID failed with error: \(error!)")
                }
            }
        }
    }
    
    @IBAction func policyTapped(sender: UIButton) {
        log("Policy tapped")
        showPolicyPicker()
    }

    @IBAction func resetLAContextTapped(sender: UIButton) {
        log("Reset Local Auth Context Tapped")
        laContext?.invalidate()
        configureLAContext()
    }
    
}

//MARK:- Picker -
extension LocalAuthViewController {
    private func showPolicyPicker() {
        policyPickerTopConstraint.constant = policyPicker.intrinsicContentSize().height
        UIView.animateConstraint(view)
    }
    
    private func hidePolicyPicker() {
        policyPickerTopConstraint.constant = 0
        UIView.animateConstraint(view)
    }
}


extension LocalAuthViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log("Policy: \(policies[row])")
        setLaPolicy(row)
        hidePolicyPicker()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return policies[row]
    }
}

extension LocalAuthViewController: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return policies.count
    }
}

//MARK: - Keychain stuff -
extension LocalAuthViewController {
    
    func storeSecret() {
        let saveSuccessful: Bool = keychain.setString("Some String", forKey: key)
        print("Saved successfully: \(saveSuccessful)")
    }
    
    func retrieveSecret() {
        let retrievedString = keychain.stringForKey(key)
        print("Retrieved string: \(retrievedString)")
    }
}

//MARK: - Logging TextView -
extension LocalAuthViewController {
    
    private func configureTextView() {
        textView.editable = false
        textView.layer.borderColor = UIColor.blueColor().CGColor
        textView.layer.borderWidth = 2.0
    }
    
    
    private func log(string: String) {
        let text = textView.text ?? ""
        textView.text = text + "\n" + string + "\n"
        guard let viewText = textView.text else {return}
        let range = NSMakeRange((viewText as NSString).length - 1, 1)
        textView.scrollRangeToVisible(range)
    }
}

private extension UIView {
    class func animateConstraint(view: UIView) {
        self.animateWithDuration(
            0.25, delay: 0.0,
            options: .CurveEaseInOut,
            animations: {
                view.layoutIfNeeded()
            },
            completion: nil)
    }
}


