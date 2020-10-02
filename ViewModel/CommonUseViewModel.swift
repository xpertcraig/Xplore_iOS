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
    
    var urlOfImageToShare: URL?
    
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
            
            downloadGroup.enter()
            self.featuredViewAllApiFirst(apistartStr: "featuredCampsites.php?userId=")
            downloadGroup.leave()
            
            downloadGroup.enter()
            self.featuredViewAllApiFirst(apistartStr: "reviewCampsites.php?userId=")
            downloadGroup.leave()
            
            downloadGroup.enter()
            self.featuredViewAllApiFirst(apistartStr: "nearbynew.php?userId=")
            downloadGroup.leave()
            
            if DataManager.isUserLoggedIn! {
                downloadGroup.enter()
                self.featuredViewAllApiFirst(apistartStr: "favouriteCampsite.php?userId=")
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.featuredViewAllApiFirst(apistartStr: "publishedCampsite.php?userId=")
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.notiListingApiOnStart()
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.profilesAPIHit()
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.nearByUsersOnStart()
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.getFollowerListFromAPI(actionUrl: apiUrl.followerListApiStr.rawValue) { (rMsg) in
                }
                downloadGroup.leave()
                
                downloadGroup.enter()
                self.getFollowerListFromAPI(actionUrl: apiUrl.followingListApiStr.rawValue) { (rMsg) in
                }
                downloadGroup.leave()
            }
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
                    
                 //   print(retValues)
                    
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

//featured,review and allcamps api
extension CommonUseViewModel {
    func featuredViewAllApiFirst(apistartStr: String) {
        var userId: String = "0"
        if let userId1 = DataManager.userId as? String {
            userId = userId1
            
        }
        var apiUrl: String = ""
        if apistartStr == "reviewCampsites.php?userId=" {
            apiUrl = "\(apistartStr)\(userId)&latitude=\(myCurrentLatitude)&longitude=\(myCurrentLongitude)&toggle=\(0)&offset=\(0)&country=\(countryOnMyCurrentLatLong)&loginId=\(DataManager.userId as? String ?? "0")"
        } else if apistartStr == "publishedCampsite.php?userId=" || apistartStr == "favouriteCampsite.php?userId=" {
            apiUrl = "\(apistartStr)\(userId)&offset=\(0)"
        } else {
            apiUrl = "\(apistartStr)\(userId)&latitude=\(myCurrentLatitude)&longitude=\(myCurrentLongitude)&offset=\(0)&country=\(countryOnMyCurrentLatLong)"
        }
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: apiUrl, onSuccess: { (responseData) in
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    
                  //  print(retValues)
                    
                    if apistartStr == "featuredCampsites.php?userId=" {
                        self.sing.featuredViewAllArr = retValues
                    } else if apistartStr == "nearbynew.php?userId=" {
                        self.sing.allCampsArr = retValues
                    } else if apistartStr == "reviewCampsites.php?userId=" {
                        self.sing.reviewViewAllArr = retValues
                    } else if apistartStr == "publishedCampsite.php?userId=" {
                        self.sing.myCampsArr = retValues
                    } else if apistartStr == "favouriteCampsite.php?userId=" {
                        self.sing.favouritesCampArr = retValues
                    }
                    
                    //self.reloadTbl(arrR: retValues, pageR: pageNum)
                } else {
                    
                }
            }
        }) { (error) in
            
        }
    }
}

//notification listing api
extension CommonUseViewModel {
    func notiListingApiOnStart() {
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "notifications.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    if let notiArr = dict["result"] as? NSArray {
                        Singleton.sharedInstance.notificationListingArr = notiArr
                    }
                }
            }
        }) { (error) in
            
        }
    }
    
    func profilesAPIHit(){
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "myProfile.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let retValue = dict["result"] as! NSDictionary
                    Singleton.sharedInstance.myProfileDict = retValue
                    
                }
            }
        }) { (error) in
            
        }
    }

    
    func getFollowerListFromAPI(actionUrl: String, completion: @escaping (_ msg: String) -> Void) {
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "\(actionUrl)/?userId=\(DataManager.userId as! String)", onSuccess: { (responseData) in
                   
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    if let listDict = dict["result"] as? [String: Any] {
                        if actionUrl == apiUrl.followerListApiStr.rawValue {
                            Singleton.sharedInstance.followerListArr = listDict["allfollowers"] as! [[String : Any]]
                        } else {
                            Singleton.sharedInstance.followingListArr = listDict["allfollowing"] as! [[String : Any]]
                        }
                        completion(success)
                    }
                } else if (String(describing: (dict["success"])!)) == "0" {
                    if actionUrl == apiUrl.followerListApiStr.rawValue {
                        Singleton.sharedInstance.followerListArr = []
                    } else {
                        Singleton.sharedInstance.followingListArr = []
                    }
                    completion(success)
                }
            }
        }) { (error) in
            
        }
    }
}

extension CommonUseViewModel {
    func nearByUsersOnStart() {
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "nearbyUser.php/?userId=\(DataManager.userId as! String)"+"&latitude=\(myCurrentLatitude)"+"&longitude=\(myCurrentLongitude)"+"&distance=\(1)", onSuccess: { (responseData) in
                   
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    if let retValue = dict["result"] as? NSArray {
                        if retValue.count > 0 {
                            self.sing.nearByUsersArr = retValue
                            
                        }
                    }
                }
            }
        }) { (error) in
            
        }
    }
}

extension CommonUseViewModel {
    func shareAppLinkAndImage(campTitle: String, campImg: UIImage, campimg1: String, sender: UIButton, vc: UIViewController) {
//        // Setting description
        let firstActivityItem = campTitle

        // Setting url
        let appLink : NSURL = NSURL(string: "http://itunes.apple.com/app/1525560350")!

        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [(campImg), firstActivityItem, "\nAppstore Link: \(appLink)" ], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender)

        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

        // Pre-configuring activity items
        if #available(iOS 13.0, *) {
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
                ] as? UIActivityItemsConfigurationReading
        } else {
            // Fallback on earlier versions
        }

        // Anything you want to exclude
//        activityViewController.excludedActivityTypes = [
//            UIActivity.ActivityType.postToWeibo,
//            UIActivity.ActivityType.print,
//            UIActivity.ActivityType.assignToContact,
//            UIActivity.ActivityType.saveToCameraRoll,
//            UIActivity.ActivityType.addToReadingList,
//            UIActivity.ActivityType.postToFlickr,
//            UIActivity.ActivityType.postToVimeo,
//            UIActivity.ActivityType.postToTencentWeibo
//            UIActivity.ActivityType.postToFacebook
//        ]

        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        vc.present(activityViewController, animated: true, completion: nil)
        
    }
}

//MARK: Follow/Unfollow user
extension CommonUseViewModel {
    func followUnfollowUwser(actionUrl: String, param: [String: Any], completion: @escaping ( _ msg: String) -> Void) {
        AlamoFireWrapper.sharedInstance.getPostApplicationJSON(action: actionUrl, param: param, onSuccess: { (responseData) in
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    if let retValues = (dict["result"]! as? Int) {
                        print(retValues)
                    }
                    completion(success)
                    self.getFollowerListFromAPI(actionUrl: apiUrl.followerListApiStr.rawValue) { (rMsg) in
//                        completion(success)
                    }
                    self.getFollowerListFromAPI(actionUrl: apiUrl.followingListApiStr.rawValue) { (rMsg) in
                       // completion(success)
                    }
                    //completion(success)
                
                } else {
                    completion("Failed")
                }
            }
        }) { (error) in
            completion(error.localizedDescription)
        }
    }
}
