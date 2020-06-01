//
//  DataManager.swift
//  AlamofireDemo2
//
//  Created by iMark_IOS on 01/06/18.
//  Copyright © 2018 iMark_IOS. All rights reserved.
//

import Foundation

class DataManager {
    
    static var userId: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPuserId)
            UserDefaults.standard.synchronize()

        }
        get {
            return UserDefaults.standard.string(forKey: XPuserId) as AnyObject

        }
    }
    
    static var pushNotification: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPisPushNotificationsEnabled)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPisPushNotificationsEnabled) as AnyObject
            
        }
    }
    
    static var isPaid: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPisPaid)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPisPaid) as AnyObject
            
        }
    }
    
    static var emailAddress: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPemailAddress)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPemailAddress) as AnyObject
            
        }
    }
    static var name: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPname)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPname) ?? ""
            
        }
    }
    
    static var profileImage: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPprofileImage)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPprofileImage) as AnyObject
            
        }
    }
    
    static var contactNum: AnyObject {
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPcontactNum)
            UserDefaults.standard.synchronize()
            
        }
        get {
            return UserDefaults.standard.string(forKey: XPcontactNum) as AnyObject
            
        }
    }
    
    static var isUserLoggedIn:Bool?{
        set {
            UserDefaults.standard.setValue(newValue, forKey: XPIsUserLoggedIn)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: XPIsUserLoggedIn)
        }
    }
}
