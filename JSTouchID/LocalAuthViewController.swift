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

    var laContext: LAContext?
    var policy: LAPolicy? = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
    lazy var policies: [(policy: LAPolicy, name: String)] = self.laPolicies()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var policyPicker: UIPickerView!
    @IBOutlet weak var policyPickerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var policyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.configure()
        configureLAContext()
        touchIDAvailable()
        configurePolicyButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logPolicy()
    }
    
    func logPolicy() {
        log("Policy: \(titleOfPolicy(policy!)!)")
    }
    
    func log(string: String) {
        textView.log(string)
    }
    
    func configurePolicyButton() {
        policyButton.enabled = policies.count > 1
        if !policyButton.enabled {
            policyPicker.hidden = true
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
        if isPickerDisplayed() {
            hidePolicyPicker()
        } else {
            showPolicyPicker()
        }
    }
    
    @IBAction func resetLAContextTapped(sender: UIButton) {
        resetLAContext()
    }
    
}

//MARK: - LAContext -
extension LocalAuthViewController {
    
    private func laPolicies() -> [(policy: LAPolicy, name: String)] {
        if #available(iOS 9, *) {
            return [
                (LAPolicy.DeviceOwnerAuthenticationWithBiometrics, "DeviceOwnerAuthenticationWithBiometrics"),
                (LAPolicy.DeviceOwnerAuthentication, "DeviceOwnerAuthentication")
            ]
        } else  {
            return [
                (LAPolicy.DeviceOwnerAuthenticationWithBiometrics, "DeviceOwnerAuthenticationWithBiometrics"),
            ]
        }
    }
    
    private func configureLAContext() {
        laContext = LAContext()
        laContext?.localizedFallbackTitle = "Fallback Title"
    }
    
    private func resetLAContext() {
        log("Reset Local Auth Context Tapped")
        if #available(iOS 9.0, *) {
            laContext?.invalidate()
        } else {
            laContext = nil
        }
        configureLAContext()
    }
    
    private func setLAPolicy(index: Int) {
        guard index < policies.count else { log("Policy index \(index) out of range"); return }
        policy = policies[index].policy
        logPolicy()
    }
    
    func touchIDAvailable() {
        let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        if ((laContext!.canEvaluatePolicy(policy, error: nil)) ) {
            log( "Touch ID available")
        } else {
            log( "No Touch ID for you")
        }
    }
    
    func policy(title: String) -> LAPolicy? {
        guard let index = policies.indexOf({title == $0.name }) else { return nil }
        return policies[index].0
    }
    
    func titleOfPolicy(policy: LAPolicy) -> String? {
        guard let index = policies.indexOf({policy == $0.policy }) else { return nil }
        return policies[index].1
    }
}

//MARK:- Picker -
extension LocalAuthViewController {
    private func showPolicyPicker() {
        let row = policies.indexOf{ $0.policy == policy }
        policyPicker.selectRow(row!, inComponent: 0, animated: false)
        
        policyPickerTopConstraint.constant = policyPicker.intrinsicContentSize().height
        UIView.animateConstraint(view)
    }
    
    private func hidePolicyPicker() {
        policyPickerTopConstraint.constant = 0
        UIView.animateConstraint(view)
    }
    
    func isPickerDisplayed() -> Bool {
        return policyPickerTopConstraint.constant != 0
    }

}


extension LocalAuthViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setLAPolicy(row)
        hidePolicyPicker()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return policies[row].name
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
