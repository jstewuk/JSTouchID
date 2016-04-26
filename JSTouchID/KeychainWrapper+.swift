//
//  KeychainWrapper+.swift
//  JSTouchID
//
//  Created by Jim on 4/25/16.
//  Copyright © 2016 Jim. All rights reserved.
//

import Foundation

/**
 Have to set these somewhere in the calling code:
 let key = "MyKey"
 let keychain = KeychainWrapper.standardKeychainAccess()

 */

extension KeychainWrapper {
    
    func storeSecret(key: String, secret: String) {
        let saveSuccessful: Bool = self.setString("Some String", forKey: key)
        print("Saved successfully: \(saveSuccessful)")
    }
    
    func retrieveSecret(key: String) {
        let retrievedString = self.stringForKey(key)
        print("Retrieved string: \(retrievedString)")
    }
}
