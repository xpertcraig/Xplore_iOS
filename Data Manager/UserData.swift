//
//  UserData.swift
//  AlamofireDemo2
//
//  Created by iMark_IOS on 01/06/18.
//  Copyright © 2018 iMark_IOS. All rights reserved.
//

import Foundation

class UserData {
    
    func parseUserData(recUserDict: [String:Any]) {        
        DataManager.userId = recUserDict["userId"] as AnyObject
        DataManager.emailAddress = recUserDict["email"] as AnyObject
        DataManager.name = recUserDict["name"] as! String
        DataManager.pushNotification = recUserDict["isPushNotificationsEnabled"] as AnyObject
        DataManager.isPaid = recUserDict["isPaid"] as AnyObject
     //   DataManager.profileImage = recUserDict["pr"]
      //  DataManager.contactNum = recUserDict["pr"]
        
    }
}
