//
//  KeychainWrapper.swift
//  JSTouchID
//
//  Created by Jim on 4/20/16.
//  Copyright © 2016 Jim. All rights reserved.
//

import Foundation

private let SecMatchLimit: String! = kSecMatchLimit as String
private let SecReturnData: String! = kSecReturnData as String
private let SecReturnPersistentRef: String! = kSecReturnPersistentRef as String
private let SecValueData: String! = kSecValueData as String
private let SecAttrAccessible: String! = kSecAttrAccessible as String
private let SecClass: String! = kSecClass as String
private let SecAttrService: String! = kSecAttrService as String
private let SecAttrGeneric: String! = kSecAttrGeneric as String
private let SecAttrAccount: String! = kSecAttrAccount as String
private let SecAttrAccessGroup: String! = kSecAttrAccessGroup as String
private let SecAccessControl: String! = kSecAttrAccessControl as String

private let sharedKeychainWrapper = KeychainWrapper()

/// KeychainWrapper is a class to help make Keychain access in Swift more straightforward. It is designed to make accessing the Keychain services more like using NSUserDefaults, which is much more familiar to people.
public class KeychainWrapper {
    
    /// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, KeychainWrapper will default to using the bundleIdentifier.
    private (set) public var serviceName: String = ""
    
    /// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
    private (set) public var accessGroup: String?
    
    private static let defaultServiceName: String = {
        return NSBundle.mainBundle().bundleIdentifier ?? "SwiftKeychainWrapper"
    }()
    
    private convenience init() {
        self.init(serviceName: KeychainWrapper.defaultServiceName)
    }
    
    /// nil suite means use the default search list that +standardUserDefaults uses
    public init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    /// Standard access keychain
    public class func standardKeychainAccess() -> KeychainWrapper {
        return sharedKeychainWrapper
    }
    
    // MARK:- Public Methods
    
    /// Checks if keychain data exists for a specified key.
    ///
    /// - parameter keyName: The key to check for.
    /// - returns: True if a value exists for the key. False otherwise.
    public func hasValueForKey(keyName: String) -> Bool {
        if let _ = self.dataForKey(keyName) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Public Getters
    public func integerForKey(keyName: String) -> Int? {
        guard let numberValue = self.objectForKey(keyName) as? NSNumber else {
            return nil
        }
        
        return numberValue.integerValue
    }
    
    public func floatForKey(keyName: String) -> Float? {
        guard let numberValue = self.objectForKey(keyName) as? NSNumber else {
            return nil
        }
        
        return numberValue.floatValue
    }
    
    public func doubleForKey(keyName: String) -> Double? {
        guard let numberValue = objectForKey(keyName) as? NSNumber else {
            return nil
        }
        
        return numberValue.doubleValue
    }
    
    public func boolForKey(keyName: String) -> Bool? {
        guard let numberValue = objectForKey(keyName) as? NSNumber else {
            return nil
        }
        
        return numberValue.boolValue
    }
    
    /// Returns a string value for a specified key.
    ///
    /// - parameter keyName: The key to lookup data for.
    /// - returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
    public func stringForKey(keyName: String) -> String? {
        guard let keychainData = self.dataForKey(keyName) else {
            return nil
        }
        
        return String(data: keychainData, encoding: NSUTF8StringEncoding) as String?
    }
    
    /// Returns an object that conforms to NSCoding for a specified key.
    ///
    /// - parameter keyName: The key to lookup data for.
    /// - returns: The decoded object associated with the key if it exists. If no data exists, or the data found cannot be decoded, returns nil.
    public func objectForKey(keyName: String) -> NSCoding? {
        guard let keychainData = self.dataForKey(keyName) else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithData(keychainData) as? NSCoding
    }
    
    
    /// Returns a NSData object for a specified key.
    ///
    /// - parameter keyName: The key to lookup data for.
    /// - returns: The NSData object associated with the key if it exists. If no data exists, returns nil.
    public func dataForKey(keyName: String) -> NSData? {
        var keychainQueryDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        var result: AnyObject?
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want NSData/CFData returned
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        keychainQueryDictionary[kSecUseOperationPrompt as String] = "My Prompt"
        
        // Search
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(keychainQueryDictionary, UnsafeMutablePointer($0))
        }
        
        return status == noErr ? result as? NSData : nil
    }
    
    
    /// Returns a persistent data reference object for a specified key.
    ///
    /// - parameter keyName: The key to lookup data for.
    /// - returns: The persistent data reference object associated with the key if it exists. If no data exists, returns nil.
    public func dataRefForKey(keyName: String) -> NSData? {
        var keychainQueryDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        var result: AnyObject?
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want persistent NSData/CFData reference returned
        keychainQueryDictionary[SecReturnPersistentRef] = kCFBooleanTrue
        
        // Search
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(keychainQueryDictionary, UnsafeMutablePointer($0))
        }
        
        return status == noErr ? result as? NSData : nil
    }
    
    // MARK: Public Setters
    
    public func setInteger(value: Int, forKey keyName: String) -> Bool {
        return self.setObject(NSNumber(integer: value), forKey: keyName)
    }
    
    public func setFloat(value: Float, forKey keyName: String) -> Bool {
        return self.setObject(NSNumber(float: value), forKey: keyName)
    }
    
    public func setDouble(value: Double, forKey keyName: String) -> Bool {
        return self.setObject(NSNumber(double: value), forKey: keyName)
    }
    
    public func setBool(value: Bool, forKey keyName: String) -> Bool {
        return self.setObject(NSNumber(bool: value), forKey: keyName)
    }
    
    /// Save a String value to the keychain associated with a specified key. If a String value already exists for the given keyname, the string will be overwritten with the new value.
    ///
    /// - parameter value: The String value to save.
    /// - parameter forKey: The key to save the String under.
    /// - returns: True if the save was successful, false otherwise.
    public func setString(value: String, forKey keyName: String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return self.setData(data, forKey: keyName)
        } else {
            return false
        }
    }
    
    /// Save an NSCoding compliant object to the keychain associated with a specified key. If an object already exists for the given keyname, the object will be overwritten with the new value.
    ///
    /// - parameter value: The NSCoding compliant object to save.
    /// - parameter forKey: The key to save the object under.
    /// - returns: True if the save was successful, false otherwise.
    public func setObject(value: NSCoding, forKey keyName: String) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
        
        return self.setData(data, forKey: keyName)
    }
    
    /// Save a NSData object to the keychain associated with a specified key. If data already exists for the given keyname, the data will be overwritten with the new value.
    ///
    /// - parameter value: The NSData object to save.
    /// - parameter forKey: The key to save the object under.
    /// - returns: True if the save was successful, false otherwise.
    public func setData(value: NSData, forKey keyName: String) -> Bool {
        var keychainQueryDictionary: [String:AnyObject] = self.setupKeychainQueryDictionaryForKey(keyName)
        
        keychainQueryDictionary[SecValueData] = value
        
        // Protect the keychain entry so it's only valid when the device is unlocked
//        keychainQueryDictionary[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return self.updateData(value, forKey: keyName)
        } else {
            return false
        }
    }
    
    /// Remove an object associated with a specified key.
    ///
    /// - parameter keyName: The key value to remove data for.
    /// - returns: True if successful, false otherwise.
    public func removeObjectForKey(keyName: String) -> Bool {
        let keychainQueryDictionary: [String:AnyObject] = self.setupKeychainQueryDictionaryForKey(keyName)
        
        // Delete
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary);
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    /// Remove all keychain data added through KeychainWrapper. This will only delete items matching the currnt ServiceName and AccessGroup if one is set.
    public func removeAllKeys() -> Bool {
        //let keychainQueryDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:AnyObject] = [SecClass:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = self.serviceName
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[SecAttrAccessGroup] = accessGroup
        }
        
        let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionaryRef)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    /// Remove all keychain data, including data not added through keychain wrapper.
    ///
    /// - important: This may remove custom keychain entries you did not add via SwiftKeychainWrapper.
    ///
    public class func wipeKeychain() {
        deleteKeychainSecClass(kSecClassGenericPassword) // Generic password items
        deleteKeychainSecClass(kSecClassInternetPassword) // Internet password items
        deleteKeychainSecClass(kSecClassCertificate) // Certificate items
        deleteKeychainSecClass(kSecClassKey) // Cryptographic key items
        deleteKeychainSecClass(kSecClassIdentity) // Identity items
    }
    
    // MARK:- Private Methods
    
    /// Remove all items for a given Keychain Item Class
    ///
    ///
    private class func deleteKeychainSecClass(secClass: AnyObject) -> Bool {
        let query = [ kSecClass as String : secClass ]
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    /// Update existing data associated with a specified key name. The existing data will be overwritten by the new data
    private func updateData(value: NSData, forKey keyName: String) -> Bool {
        let keychainQueryDictionary: [String:AnyObject] = self.setupKeychainQueryDictionaryForKey(keyName)
        let updateDictionary = [SecValueData:value]
        
        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary, updateDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    /// Setup the keychain query dictionary used to access the keychain on iOS for a specified key name. Takes into account the Service Name and Access Group if one is set.
    ///
    /// - parameter keyName: The key this query is for
    /// - returns: A dictionary with all the needed properties setup to access the keychain on iOS
    private func setupKeychainQueryDictionaryForKey(keyName: String) -> [String:AnyObject] {
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:AnyObject] = [SecClass:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = self.serviceName
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[SecAttrAccessGroup] = accessGroup
        }
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: NSData? = keyName.dataUsingEncoding(NSUTF8StringEncoding)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        if #available(iOS 9.0, *) {
            if let access = accessControl() {
                keychainQueryDictionary[SecAccessControl] = access
            }
        }
        
        return keychainQueryDictionary
    }
    
    @available(iOS 9.0, *)
    private func accessControl() -> SecAccessControl?   {
        var aclError: Unmanaged<CFErrorRef>?
        return SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, SecAccessControlCreateFlags.UserPresence, &aclError)
    }
}

// MARK: - Deprecated Class Functions
// TODO: Should these really be deprecated or are they acceptable for convenience? Convenience or bloat?

public extension KeychainWrapper {
    
    /// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, KeychainWrapper will default to using the bundleIdentifier.
    @available(*, deprecated=2.0, message="Use KeychainWrapper.standardKeychainAccess().serviceName. Changing serviceName will not be supported in the future. Instead create a new KeychainWrapper instance with a custom service name.")
    public class var serviceName: String {
        get {
            return sharedKeychainWrapper.serviceName
        }
        set(newServiceName) {
            sharedKeychainWrapper.serviceName = newServiceName
        }
    }
    
    /// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
    ///
    /// Access Group defaults to an empty string and is not used until a valid value is set.
    ///
    /// This is a static property and only needs to be set once. To remove the access group property after one has been set, set this to an empty string.
    @available(*, deprecated=2.0, message="Use KeychainWrapper.standardKeychainAccess().accessGroup. Changing accessGroup will not be supported in the future. Instead create a new KeychainWrapper instance with a custom accessGroup.")
    public class var accessGroup: String? {
        get {
            return sharedKeychainWrapper.accessGroup
        }
        set(newAccessGroup){
            sharedKeychainWrapper.accessGroup = newAccessGroup
        }
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func hasValueForKey(keyName: String) -> Bool {
        return sharedKeychainWrapper.hasValueForKey(keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func stringForKey(keyName: String) -> String? {
        return sharedKeychainWrapper.stringForKey(keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func objectForKey(keyName: String) -> NSCoding? {
        return sharedKeychainWrapper.objectForKey(keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func dataForKey(keyName: String) -> NSData? {
        return sharedKeychainWrapper.dataForKey(keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func dataRefForKey(keyName: String) -> NSData? {
        return sharedKeychainWrapper.dataRefForKey(keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func setString(value: String, forKey keyName: String) -> Bool {
        return sharedKeychainWrapper.setString(value, forKey: keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func setObject(value: NSCoding, forKey keyName: String) -> Bool {
        return sharedKeychainWrapper.setObject(value, forKey: keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func setData(value: NSData, forKey keyName: String) -> Bool {
        return sharedKeychainWrapper.setData(value, forKey: keyName)
    }
    
    @available(*, deprecated=2.0, message="Access via KeychainWrapper.standardKeychainAccess()")
    public class func removeObjectForKey(keyName: String) -> Bool {
        return sharedKeychainWrapper.removeObjectForKey(keyName)
    }
}
