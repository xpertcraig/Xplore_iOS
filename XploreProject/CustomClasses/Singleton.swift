//
//  Singleton.swift
//  XploreProject
//
//  Created by Dharmendra on 17/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//
import UIKit
import Foundation
import GoogleMobileAds

import Firebase
import FirebaseDatabase
import FirebaseStorage

final class Singleton {
    private init() {}
    static let sharedInstance: Singleton = Singleton()
    
    var loaderActive: Bool = false
    var fromMyProfileTabbarIndex: Int = 0
    var fromMyProfile: Bool = false
    
    var homeFeaturesCampsArr: NSArray = []
    var homeReviewBasedCampsArr: NSArray = []
    var myCurrentLocDict: [String: Any] = [:]
    var mycurrentLocationImage: UIImage?
    var myCurrentLocation: String = ""
    var myCurrentLocationState: String = ""
    
    var featuredViewAllArr: NSArray = []
    var reviewViewAllArr: NSArray = []
    var allCampsArr: NSArray = []
    var nearByUsersArr: NSArray = []
    
    var favouritesCampArr: NSArray = []
    var myCampsArr: NSArray = []
    var myProfileDict: NSDictionary = [:]
    
    var notificationListingArr: NSArray = []
    var chatListArr: [[String: Any]] = []
    
    var loginComeFrom: String = ""
    var favIndex: Int = -1
    var campId: String = ""
    var notiType: String = ""
    var messageSentUserId: String = ""
    
    var interstitial: GADInterstitial!
    var timerAdd = Timer()
    var addReady: Bool = false
    
    
    func updateUnreadMessageCount(chatUnitId: String, receiverId: String) {
        var msgCount: Int = 0
        var calledOnce: Bool = false
        
        let ref = Database.database().reference()
        ref.child("Users").child(chatUnitId).observe(.value) { (snapShot) in
            if let postDict = snapShot.value as? Dictionary<String, AnyObject> {
                
                if let uCount = postDict["unread_\(receiverId)"] as? Int {
                    if calledOnce == false {
                        calledOnce = true
                        msgCount = Int(uCount)
                        msgCount += 1
                        
                        Database.database().reference().child("Users").child(chatUnitId).child("unread_\(receiverId)").setValue(msgCount)
                        
                        Database.database().reference().child("Users").child(chatUnitId).child("unread_\(DataManager.userId)").setValue(0)
                       
                    }
                }
            }
        }
    }
}

extension UIViewController {
    func CheckAndShowAdds(vc: UIViewController) {
        if (Singleton.sharedInstance.interstitial.isReady) {
            Singleton.sharedInstance.addReady = true
            Singleton.sharedInstance.timerAdd.invalidate()
            Singleton.sharedInstance.interstitial.present(fromRootViewController: vc)
        
        }
    }
    func MoveToHomeScreen(vc: UIViewController) {
        if Singleton.sharedInstance.addReady == true {
            Singleton.sharedInstance.addReady = false
        
        }
    }
    
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
                
        let sing = Singleton.sharedInstance
        if sing.loginComeFrom == campDescription || sing.loginComeFrom == featuredCamp {
            self.navigationController?.popViewController(animated: false)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
            if sing.loginComeFrom == filter {
                vc.selectedIndex = 1
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == savedCamp {
                self.navigationController?.tabBarController?.tabBar.isHidden = false
                vc.selectedIndex = 2
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == myCampsStr {
                self.navigationController?.tabBarController?.tabBar.isHidden = false
                vc.selectedIndex = 3
                sing.loginComeFrom = ""
            } else if sing.loginComeFrom == settingStr {
                self.navigationController?.tabBarController?.tabBar.isHidden = false
                vc.selectedIndex = 4
                sing.loginComeFrom = ""
            } else {
                vc.selectedIndex = 0
              //  vc.tabBar.isHidden = true
            }
            //(applicationDelegate.window?.rootViewController as! UINavigationController).tabBarController?.tabBar.isHidden = true
            (applicationDelegate.window?.rootViewController as! UINavigationController).pushViewController(vc, animated: false)
            
        }
    }
}
