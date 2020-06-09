//
//  CommonUseViewModel.swift
//  XploreProject
//
//  Created by Dharmendra on 04/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import CoreLocation
import GooglePlaces
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CommonUseViewModel {
    let sing = Singleton.sharedInstance
    
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

//Call all api before enter into the app
extension CommonUseViewModel {
    func getCampAllApiResponse() {
        DispatchQueue.global(qos: .userInitiated).async {
            var storedError: NSError?
            let downloadGroup = DispatchGroup()
            
            if self.sing.homeFeaturesCampsArr.count == 0 {
                downloadGroup.enter()
                self.homeAPICallInStart()
                downloadGroup.leave()
            }
            
            downloadGroup.enter()
            self.getLocationNameAndImage()
            downloadGroup.leave()
        }
    }
    
    func homeAPICallInStart() {
        var userId: String = ""
        if let userId1 = DataManager.userId as? String {
            userId = userId1
        } else {
            userId = "0"
        }
        
        let param: NSDictionary = ["userId": userId, "latitude": myCurrentLatitude, "longitude": myCurrentLongitude, "country": countryOnMyCurrentLatLong]
        AlamoFireWrapper.sharedInstance.getPost(action: "home.php", param: param as! [String : Any], onSuccess: { (responseData) in
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSDictionary)
                    
                    print(retValues)
                    
                    if let featuerd = retValues.value(forKey: "featuredCampsite") as? NSArray {
                        self.sing.homeFeaturesCampsArr = featuerd
                    }
                    if let review = retValues.value(forKey: "reviewBased") as? NSArray {
                        self.sing.homeReviewBasedCampsArr = review
                    }
                }
            }
        }) { (error) in
           
        }
    }
}

//get location and image
extension CommonUseViewModel {
    func getLocationNameAndImage() {
        let geocoder = CLGeocoder()
        if userLocation != nil {
            geocoder.reverseGeocodeLocation(userLocation!) { (placemarksArray, error) in
                if placemarksArray != nil {
                    if (placemarksArray?.count)! > 0 {
                        let placemark = placemarksArray?.first
                  //      "AIzaSyDuMxcTE9veBDMS_jjIjHJ0ltUVCyGMn2I"
                        
//                        myCurrentLatitude = 32.265942
//                        myCurrentLongitude = 75.646873
                        if placemark?.addressDictionary != nil {
                            if (placemark?.addressDictionary!["Country"]) != nil {
                                countryOnMyCurrentLatLong = (placemark?.addressDictionary!["Country"]) as? String ?? ""
                               
                            }
                        }
                        
                        AlamoFireWrapper.sharedInstance.getOnlyApiForGooglePlace(action: ("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(myCurrentLatitude),\(myCurrentLongitude)&radius=500&types=&name=&key=" + googleApiKey), onSuccess: { (responseData) in

                            // applicationDelegate.dismissProgressView(view: self.view)
                            if let dict:NSDictionary = responseData.result.value as? NSDictionary {

                            //    print(dict)

                                if (dict["results"] as! NSArray).count != 0 {
                                    let placeId: String = String(describing: (((dict["results"] as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "place_id"))!)
                                    
                                    self.loadFirstPhotoForPlace(placeID: placeId)
                                    
                                }
                            }
                        }) { (error) in
                            
                        }
                        
                        self.sing.myCurrentLocation = placemark?.subLocality ?? ""
                        self.sing.myCurrentLocationState = placemark!.locality ?? ""
                        
                        Singleton.sharedInstance.myCurrentLocDict.updateValue(self.sing.myCurrentLocation, forKey: "locName")
                        Singleton.sharedInstance.myCurrentLocDict.updateValue(self.sing.myCurrentLocationState, forKey: "locState")
                    }
                }
            }
        }
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                    
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.sing.mycurrentLocationImage = photo;
                self.sing.myCurrentLocDict.updateValue(self.sing.mycurrentLocationImage!, forKey: "mycurLocImg")
                NotificationCenter.default.post(name: Notification.Name("locationRec"), object: nil)

             //   self.animateLocView()
                
            }
        })
    }
    
}
