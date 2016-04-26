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
    
    func storeSecret(key: String, secret: String) -> Bool {
        return self.setString("Some String", forKey: key)
    }
    
    func retrieveSecret(key: String) -> String? {
        return self.stringForKey(key)
    }
}
