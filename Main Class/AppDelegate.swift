//
//  AppDelegate.swift
//  XploreProject
//
//  Created by shikha kochar on 19/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//


//backupbranch


import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

import CoreLocation

import FBSDKLoginKit
import GoogleSignIn

//notification
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var notificationRecdict: NSDictionary = [:]
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    var window: UIWindow?    
    var notiType: String = ""
    let gcmMessageIDKey = "gcm.message_id"
    
    //location
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        
//        UITabBarItem.appearance()
//            .setTitleTextAttributes(
//                [NSAttributedStringKey.font: UIFont(name: "Nunito-Regular", size: 15)!],
//                for: .normal)
        
        //
        self.determineMyCurrentLocation()
        
        //
        GMSServices.provideAPIKey(googleApiKey)
        GMSPlacesClient.provideAPIKey(googleApiKey)
        
        self.checkLogin()
        
        //notification
        // This will enable to show nowplaying controls on lock screen
        application.beginReceivingRemoteControlEvents()
        //FireBase Notification
        FirebaseApp.configure()
        // [START set_messaging_delegate]
        
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert,.sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        //fire notification
        application.registerForRemoteNotifications()
        
        
        //facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //gmail Integration
        GIDSignIn.sharedInstance().clientID = "391490568950-or37ivee2lf3hhmd5tl318pns8ms9eoq.apps.googleusercontent.com"
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.callSearch()
        
        //paypal
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "",PayPalEnvironmentSandbox: "AchQBo7DxGgkZ9gfoqvq-pU2nyQUQmgGoff_J5Dqw60d2CGIRiB0E5yn-Hj9igkaJLvWJx5K139FB_tb"])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if userDefault.value(forKey: homeFeaturesStr) != nil {
            Singleton.sharedInstance.homeFeaturesCampsArr = userDefault.value(forKey: homeFeaturesStr) as! NSArray
            userDefault.removeObject(forKey: homeFeaturesStr)

        }
        if userDefault.value(forKey: homeReviewBasedStr) != nil {
            Singleton.sharedInstance.homeReviewBasedCampsArr = userDefault.value(forKey: homeReviewBasedStr) as! NSArray
            userDefault.removeObject(forKey: homeReviewBasedStr)
            
        }
        if userDefault.value(forKey: favouritesCampsStr) != nil {
            Singleton.sharedInstance.favouritesCampArr = userDefault.value(forKey: favouritesCampsStr) as! NSArray
            userDefault.removeObject(forKey: favouritesCampsStr)
            
        }
        if userDefault.value(forKey: myCampsStr) != nil {
            Singleton.sharedInstance.myCampsArr = userDefault.value(forKey: myCampsStr) as! NSArray
            userDefault.removeObject(forKey: myCampsStr)
            
        }
        if userDefault.value(forKey: myProfileStr) != nil {
            Singleton.sharedInstance.myProfileDict = userDefault.value(forKey: myProfileStr) as! NSDictionary
            userDefault.removeObject(forKey: myProfileStr)
            
        }
        if userDefault.value(forKey: notificationListingStr) != nil {
            Singleton.sharedInstance.notificationListingArr = userDefault.value(forKey: notificationListingStr) as! NSArray
            userDefault.removeObject(forKey: notificationListingStr)
            
        }
        if userDefault.value(forKey: chatListStr) != nil {
            Singleton.sharedInstance.chatListArr = (userDefault.value(forKey: chatListStr) as! [[String: Any]] )
            userDefault.removeObject(forKey: chatListStr)
            
        }
        if userDefault.value(forKey: myCurrentLocStr) != nil {
            Singleton.sharedInstance.myCurrentLocDict = (userDefault.value(forKey: myCurrentLocStr) as! [String: Any] )
            userDefault.removeObject(forKey: myCurrentLocStr)
            
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
        if Singleton.sharedInstance.homeFeaturesCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.homeFeaturesCampsArr, forKey: homeFeaturesStr)

        }
        if Singleton.sharedInstance.homeReviewBasedCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.homeReviewBasedCampsArr, forKey: homeReviewBasedStr)
            
        }
        if Singleton.sharedInstance.favouritesCampArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.favouritesCampArr, forKey: favouritesCampsStr)
            
        }
        if Singleton.sharedInstance.myCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.myCampsArr, forKey: myCampsStr)
            
        }
        if Singleton.sharedInstance.myProfileDict.count > 0 {
            userDefault.set(Singleton.sharedInstance.myProfileDict, forKey: myProfileStr)
            
        }
        if Singleton.sharedInstance.notificationListingArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.notificationListingArr, forKey: notificationListingStr)
            
        }
        if Singleton.sharedInstance.chatListArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.chatListArr, forKey: chatListStr)
            
        }
        if Singleton.sharedInstance.myCurrentLocDict.count > 0 {
            userDefault.set(Singleton.sharedInstance.myCurrentLocDict, forKey: myCampsStr)
            
        }
    }
    
    //fb and gmail integration
    func callSearch() {
        // Set some colors (colorLiteral is convenient)
        let barColor: UIColor = UIColor(red: 0.5843137503, green: 0.8235294223, blue:  0.4196078479, alpha: 1)
        
        let backgroundColor: UIColor = UIColor(red: 0.8039215803, green: 0.8039215803, blue:  0.8039215803, alpha: 1)
        
        let textColor: UIColor =  UIColor(red: 0.501960814, green: 0.501960814, blue:  0.501960814, alpha: 1)
        
        // Navigation bar background.
        UINavigationBar.appearance().barTintColor = barColor
        UINavigationBar.appearance().tintColor = UIColor.white
        // Color and font of typed text in the search bar.
        var searchBarTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: textColor, NSAttributedStringKey.font.rawValue: UIFont(name: "Helvetica Neue", size: 16)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
        // Color of the placeholder text in the search bar prior to text entry.
        var placeholderAttributes = [NSAttributedStringKey.foregroundColor: backgroundColor, NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 15)]
        // Color of the default search text.
        var attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if UserDefaults.standard.value(forKey: XPLoginStatus) as! String == facbookLogin {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            
        } else if UserDefaults.standard.value(forKey: XPLoginStatus) as! String == gmailLogin {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: (options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String), annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
        }else {
            return true
            
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        
        return GIDSignIn.sharedInstance().handle(url as URL?,sourceApplication: sourceApplication,annotation: annotation)
    }
    
    //notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            // print("Message ID: \(messageID)")
        }
       
       // print(userInfo)
        notificationRecdict = userInfo as NSDictionary
        
        notificationCount += 1
        
    //    self.notiType = String(describing: (notificationRecdict.value(forKey: "gcm.notification.type"))!)
        self.notificationRec()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            // print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
        notificationCount += 1
        
        notificationRecdict = userInfo as NSDictionary
        
    //    self.notiType = String(describing: (notificationRecdict.value(forKey: "gcm.notification.type"))!)
        self.notificationRec()
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //  print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       // print("APNs token retrieved: \(deviceToken)")
        if let token = Messaging.messaging().fcmToken{
            
            //print("Device Token: \(token)")
            userDefault.set(token, forKey: "DeviceToken")
            
        } else {
            userDefault.set("0", forKey: "DeviceToken")
            
        }
    }
    
    //MARK: - Alamofire Method
    func registerDeviceTokenResult(dictionaryContent: NSDictionary){
        let success = dictionaryContent.value(forKey: "success") as AnyObject
        if success .isEqual(1) {
           // print("deviceToken register successfully")
            
        }
    }
    
    func notificationRec() {
        if UIApplication.shared.applicationState == UIApplicationState.active {
            if (self.notiType == "") {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                self.window?.makeKeyAndVisible()
                
            } else  if (self.notiType == "") {
                
            }
            
            /* active stage is working */
        } else if (UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.background) {
            //get notification count
            self.notificationCountApi()
            
            let revealViewControllerVcObj = storyboard.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
            (self.window?.rootViewController as! UINavigationController).pushViewController(revealViewControllerVcObj, animated: false)
            
        }
    }
    
    //MARK: - ProgressIndicator view start
    func startProgressView(view:UIView){
        let spinnerActivity = MBProgressHUD.showAdded(to: view, animated: true)
        // spinnerActivity.backgroundColor = UIColor.clear
        spinnerActivity.bezelView.color = UIColor.clear
        spinnerActivity.mode = MBProgressHUDMode.indeterminate
        spinnerActivity.animationType = .zoomOut
        
    }
    
    //MARK: - ProgressIndicator View Stop
    func dismissProgressView(view:UIView)  {
        MBProgressHUD.hide(for: view, animated: true)
        
    }
    
    func checkLogin() {
  //      let loginCheck = DataManager.isUserLoggedIn
        
      //  let loginCheck = userDefault.bool(forKey: login.USER_DEFAULT_LOGIN_CHECK_Key)
  //      if(loginCheck)! {
            
            //get notification count
         //   self.notificationCountApi()
            
        if DataManager.isUserLoggedIn! == false {
            DataManager.userId = "0" as AnyObject
            
        }
        
            let revealViewControllerVcObj = storyboard.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
            (self.window?.rootViewController as! UINavigationController).pushViewController(revealViewControllerVcObj, animated: false)
            
    //    }
    }    
    
    func determineMyCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        //print("user latitude = \((userLocation.coordinate.latitude))")
        //print("user longitude = \(userLocation.coordinate.longitude)")
        
        myCurrentLongitude = (userLocation.coordinate.longitude).roundToDecimal(4)
        myCurrentLatitude = (userLocation.coordinate.latitude).roundToDecimal(4)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
    }
    
    func notificationCountApi() {
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "notificationsCount.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
           
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                   // print(dict)
                    notificationCount = Int(String(describing: (dict["result"])!))!
                    
                } else {
                   // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            if connectivity.isConnectedToInternet() {
             //   CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
               // CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Xplore")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

//notification
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            //  print("Message ID: \(messageID)")
        }
        
        //print(userInfo)
        notificationRecdict = userInfo as NSDictionary
        
      //  notificationCount += 1
        
     //   self.notiType = String(describing: (notificationRecdict.value(forKey: "gcm.notification.type"))!)
        self.notificationRec()
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //  print("Message ID: \(messageID)")
            
        }
        // Print full message.
      //  print(userInfo)
        notificationRecdict = userInfo as NSDictionary
        
        notificationCount += 1
        
    //    self.notiType = String(describing: (notificationRecdict.value(forKey: "gcm.notification.type"))!)
        self.notificationRec()
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //print("Firebase registration token: \(fcmToken)")
        userDefault.set(fcmToken, forKey: "DeviceToken")
        
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //  print("Received data message: \(remoteMessage.appData)")
        
    }
}


// MARK: - CLLocationManagerDelegate
//extension AppDelegate: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.startUpdatingLocation()
////            mapView.myLocationEnabled = true
////            mapView.settings.myLocationButton = true
//        } else {
//            print("Off")
//
//        }
//    }
////    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        if let location = locations.first {
////           // mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
////            locationManager.stopUpdatingLocation()
////        }
////    }
//}

extension UINavigationController {
    public func hasViewController(ofKind kind: AnyClass) -> UIViewController? {
        return self.viewControllers.first(where: {$0.isKind(of: kind)})
    }
}
