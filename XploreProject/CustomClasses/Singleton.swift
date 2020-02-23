//
//  Singleton.swift
//  XploreProject
//
//  Created by Dharmendra on 17/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//
import UIKit
import Foundation

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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
        let sing = Singleton.sharedInstance
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
