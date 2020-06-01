//
//  CommonUseViewModel.swift
//  XploreProject
//
//  Created by Dharmendra on 04/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

import Firebase
import FirebaseDatabase
import FirebaseStorage

class CommonUseViewModel {
    func updateFirebaseProfile() {
        let ref = Database.database().reference().child("UsersProfile").child(DataManager.userId as! String)
        ref.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.hasChild(DataManager.userId as! String) {
                print("true rooms exist")
                
            } else {
                print("false room doesn't exist")
                if userDefault.value(forKey: "DeviceToken") as? String == nil {
                    userDefault.set(0, forKey: "DeviceToken")
                    
                }
                let dictMessage: [String: Any] = ["userId": String(describing: (DataManager.userId)), "username": String(describing: (DataManager.name)) , "userProfileImage": String(describing: (DataManager.profileImage)), "deviceToken": userDefault.value(forKey: "DeviceToken")!]
                                
                ref.updateChildValues(dictMessage)
                
            }
        }

    }
    
    func removeUserTokenFromFirebase(userId: String) {
        Database.database().reference().child("UsersProfile").child(userId).child("deviceToken").setValue("")
        
    }
    
    func removeDataonLogout() {
        let deviceToken = userDefault.value(forKey: "DeviceToken")!
        
        userDefault.removeObject(forKey: XPLoginStatus)
        self.removeUserTokenFromFirebase(userId: DataManager.userId as! String)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefault.set(deviceToken, forKey: "DeviceToken")
        
        let sing = Singleton.sharedInstance
        sing.homeFeaturesCampsArr = []
        sing.homeReviewBasedCampsArr = []
        sing.myCurrentLocDict = [:]
        sing.favouritesCampArr = []
        sing.myCampsArr = []
        sing.myProfileDict = [:]
        sing.notificationListingArr = []
        sing.chatListArr = []
        sing.loginComeFrom = ""
        
        DataManager.userId = "0" as AnyObject
        
        
    }

    
        //Apple login
    func saveToKeychaine(dict: [String: String]) {
        KeychainWrapper.standard.set(dict["id"]!, forKey: appleUserId)
        KeychainWrapper.standard.set(dict["fullName"]!, forKey: appleuserName)
        KeychainWrapper.standard.set(dict["email"]!, forKey: appleUserEmail)
        
    }
    
    func returnAppleKeyChaneValues() -> [String: String] {
        let getUserId: String? = KeychainWrapper.standard.string(forKey: appleUserId)
        let getUserName: String? = KeychainWrapper.standard.string(forKey: appleuserName)
        let getUserEmail: String? = KeychainWrapper.standard.string(forKey: appleUserEmail)
        
        if getUserEmail != nil {
            return ["id": getUserId!, "fullName": getUserName!, "email": getUserEmail!]
        } else {
            return [:]
        }
        
    }
    
    func appleLoginApiHit(completion: @escaping(_ Msg: String, _ dict: [String: Any]) -> Void ){
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set(0, forKey: "DeviceToken")
            
        }
        var appleDict: [String: String] = [:]
        if #available(iOS 13.0, *) {
            appleDict = returnAppleKeyChaneValues()
        } else {
            // Fallback on earlier versions
        }
        if appleDict != [:] {
            let param: [String:Any] = ["name": appleDict["fullName"] ?? "", "email": appleDict["email"] ?? "" ,"password": "", "cpwd": "", "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": "", "googleToken": "", "appleToken": String(describing: (appleDict["id"])!) ,"longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
              
            //  print(param)
              
              AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
                  if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                      if (String(describing: (dict["success"])!)) == "1" {
                          let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                            DataManager.userId = retValues["userId"] as AnyObject
                            DataManager.emailAddress = retValues["email"] as AnyObject
                            DataManager.name = retValues["name"] as! String
                            DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                            DataManager.isPaid = retValues["isPaid"] as AnyObject
                        
                          completion(success, retValues)
                      } else {
                          completion((String(describing: (dict["error"])!)), [:])
                      }
                  }
              }) { (error) in
                  if connectivity.isConnectedToInternet() {
                      completion(serverError, [:])
                  } else {
                      completion(noInternet, [:])
                  }
              }
        } else {
            completion(errorInAppleLigin, [:])
        }
    }
}
