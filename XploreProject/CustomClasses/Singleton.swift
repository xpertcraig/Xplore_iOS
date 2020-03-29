//
//  Singleton.swift
//  XploreProject
//
//  Created by Dharmendra on 17/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//
import UIKit
import Foundation

import Firebase
import FirebaseDatabase
import FirebaseStorage

final class Singleton {
    private init() {}
    static let sharedInstance: Singleton = Singleton()
    
    var homeFeaturesCampsArr: NSArray = []
    var homeReviewBasedCampsArr: NSArray = []
    var myCurrentLocDict: [String: Any] = [:]
    
    var favouritesCampArr: NSArray = []
    var myCampsArr: NSArray = []
    var myProfileDict: NSDictionary = [:]
    
    var notificationListingArr: NSArray = []
    var chatListArr: [[String: Any]] = []
    
    var loginComeFrom: String = ""
    var favIndex: Int = -1
    var campId: String = ""
    
}

extension UIViewController {
    func moveBackToApp() {
        (applicationDelegate.window?.rootViewController as! UINavigationController).hasViewController(ofKind: MytabbarControllerVc.self)
        
        DataManager.isUserLoggedIn = true
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        if let tabArray = tabBarControllerItems {
            let tabBarItem1 = tabArray[2]
            let tabBarItem2 = tabArray[3]
            let tabBarItem3 = tabArray[4]

            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
            tabBarItem3.isEnabled = true
        }
        
        let ref = Database.database().reference().child("UsersProfile").child(DataManager.userId as! String)
        ref.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.hasChild(DataManager.userId as! String) {
                print("true rooms exist")
                
            } else {
                print("false room doesn't exist")
                
                let dictMessage: [String: Any] = ["userId": String(describing: (DataManager.userId)), "username": String(describing: (DataManager.name)) , "userProfileImage": String(describing: (DataManager.profileImage))]
                                
                ref.updateChildValues(dictMessage)
                
            }
        }
        
        let sing = Singleton.sharedInstance
        if sing.loginComeFrom == campDescription || sing.loginComeFrom == featuredCamp {
            self.navigationController?.popViewController(animated: false)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
            if sing.loginComeFrom == filter {
                vc.selectedIndex = 1
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == savedCamp {
                vc.selectedIndex = 2
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == myCampsStr {
                vc.selectedIndex = 3
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == settingStr {
                vc.selectedIndex = 4
                sing.loginComeFrom = ""
            } else {
                vc.selectedIndex = 0
              //  vc.tabBar.isHidden = true
            }
            (applicationDelegate.window?.rootViewController as! UINavigationController).tabBarController?.tabBar.isHidden = true
            (applicationDelegate.window?.rootViewController as! UINavigationController).pushViewController(vc, animated: false)
            
        }
    }
}
