//
//  AppDelegate.swift
//  XploreProject
//
//  Created by shikha kochar on 19/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

//Main master branch

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
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var notificationRecdict: NSDictionary = [:]
    var firstCalled: Bool = false
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private let commonDataViewModel = CommonUseViewModel()
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    //location
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // UIApplication.shared.statusBarStyle = .lightContent
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //
        Singleton.sharedInstance.interstitial = createAndLoadInterstitial()
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
        
        GADMobileAds.configure(withApplicationID: googleAdsAppId)
        
        
        // [START set_messaging_delegate]
        
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
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
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //gmail Integration
        GIDSignIn.sharedInstance().clientID = "391490568950-or37ivee2lf3hhmd5tl318pns8ms9eoq.apps.googleusercontent.com"
        
        self.callSearch()
        
        //paypal
        //new
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AcSVl1kiDmTBoG4GiEbDRI4z0zSyfN8EK3_nGTXC89o5-JxiEmi2iFWNrqZ05_LAOFI9l8hb7FecOxg0"])
        
   //     PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AcSVl1kiDmTBoG4GiEbDRI4z0zSyfN8EK3_nGTXC89o5-JxiEmi2iFWNrqZ05_LAOFI9l8hb7FecOxg0",PayPalEnvironmentSandbox: "Ad-dgqhzoLcDLU5jmdcOozwWajoOSG3SWhsS6fmXjwYSF_FmseqNRDuKwjQM-o9jCHRDMo2O67Mg5GAv"])
        
     //   old
      //  PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "",PayPalEnvironmentSandbox: "AchQBo7DxGgkZ9gfoqvq-pU2nyQUQmgGoff_J5Dqw60d2CGIRiB0E5yn-Hj9igkaJLvWJx5K139FB_tb"])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AppEvents.activateApp()
        self.saveAppData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.doBackgroundTask()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.locationManager.startUpdatingLocation()
        self.getAppData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.getAppData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            UIScene.willDeactivateNotification
        } else {
            NSNotification.Name.UIApplicationWillResignActive
            // Fallback on earlier versions
        }

        self.saveAppData()
        
    }
    
    func getAppData() {
        if userDefault.value(forKey: homeFeaturesStr) != nil {
            Singleton.sharedInstance.homeFeaturesCampsArr = userDefault.value(forKey: homeFeaturesStr) as! NSArray
           // userDefault.removeObject(forKey: homeFeaturesStr)

        }
        if userDefault.value(forKey: homeReviewBasedStr) != nil {
            Singleton.sharedInstance.homeReviewBasedCampsArr = userDefault.value(forKey: homeReviewBasedStr) as! NSArray
          //  userDefault.removeObject(forKey: homeReviewBasedStr)
            
        }
       
        //
        if userDefault.value(forKey: featuredViewAll) != nil {
            Singleton.sharedInstance.featuredViewAllArr = userDefault.value(forKey: featuredViewAll) as! NSArray
            userDefault.removeObject(forKey: featuredViewAll)
            
        }
        if userDefault.value(forKey: reviewViewAllStr) != nil {
            Singleton.sharedInstance.reviewViewAllArr = userDefault.value(forKey: reviewViewAllStr) as! NSArray
            userDefault.removeObject(forKey: reviewViewAllStr)
            
        }
        if userDefault.value(forKey: viewAllCamps) != nil {
            Singleton.sharedInstance.allCampsArr = userDefault.value(forKey: viewAllCamps) as! NSArray
            userDefault.removeObject(forKey: viewAllCamps)
            
        }
        //
        
        if userDefault.value(forKey: favouritesCampsStr) != nil {
            Singleton.sharedInstance.favouritesCampArr = userDefault.value(forKey: favouritesCampsStr) as! NSArray
            //userDefault.removeObject(forKey: favouritesCampsStr)
            
        }
        if userDefault.value(forKey: myCampsStr) != nil {
            Singleton.sharedInstance.myCampsArr = userDefault.value(forKey: myCampsStr) as! NSArray
           // userDefault.removeObject(forKey: myCampsStr)
            
        }
        if userDefault.value(forKey: myProfileStr) != nil {
            Singleton.sharedInstance.myProfileDict = userDefault.value(forKey: myProfileStr) as! NSDictionary
           // userDefault.removeObject(forKey: myProfileStr)
            
        }
        if userDefault.value(forKey: notificationListingStr) != nil {
            Singleton.sharedInstance.notificationListingArr = userDefault.value(forKey: notificationListingStr) as! NSArray
            userDefault.removeObject(forKey: notificationListingStr)
            
        }
        if userDefault.value(forKey: chatListStr) != nil {
            Singleton.sharedInstance.chatListArr = (userDefault.value(forKey: chatListStr) as! [[String: Any]] )
            userDefault.removeObject(forKey: chatListStr)
            
        }
//        if userDefault.value(forKey: myCurrentLocStr) != nil {
//            Singleton.sharedInstance.myCurrentLocDict = (userDefault.value(forKey: myCurrentLocStr) as! [String: Any] )
//
//        }
    }
    
    func saveAppData() {
        self.saveContext()
        if Singleton.sharedInstance.homeFeaturesCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.homeFeaturesCampsArr, forKey: homeFeaturesStr)

        }
        if Singleton.sharedInstance.homeReviewBasedCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.homeReviewBasedCampsArr, forKey: homeReviewBasedStr)
            
        }
        if Singleton.sharedInstance.featuredViewAllArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.featuredViewAllArr, forKey: featuredViewAll)

        }
        if Singleton.sharedInstance.reviewViewAllArr.count > 0 {
            //userDefault.set(Singleton.sharedInstance.reviewViewAllArr, forKey: reviewViewAllStr)
            
        }
        if Singleton.sharedInstance.allCampsArr.count > 0 {
            userDefault.set(Singleton.sharedInstance.allCampsArr, forKey: viewAllCamps)
            
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
//        if Singleton.sharedInstance.myCurrentLocDict.count > 0 {
//            userDefault.set(Singleton.sharedInstance.myCurrentLocDict, forKey: myCurrentLocStr)
//
//        }
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
        let searchBarTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: textColor, NSAttributedStringKey.font.rawValue: UIFont(name: "Helvetica Neue", size: 16)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes as [String : Any]
        // Color of the placeholder text in the search bar prior to text entry.
        let placeholderAttributes = [NSAttributedStringKey.foregroundColor: backgroundColor, NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 15)]
        // Color of the default search text.
        let attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes as [NSAttributedStringKey : Any])
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if UserDefaults.standard.value(forKey: XPLoginStatus) as! String == facbookLogin {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
            
        } else if UserDefaults.standard.value(forKey: XPLoginStatus) as! String == gmailLogin {
            //return GIDSignIn.sharedInstance().handle(url, sourceApplication: (options[UIApplicationLaunchOptionsKey.sourceApplication]), annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
            return GIDSignIn.sharedInstance().handle(url)
        } else {
            return true
            
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var _: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        
        return GIDSignIn.sharedInstance().handle(url)
        //return GIDSignIn.sharedInstance()?.handle(url as URL?,sourceApplication: sourceApplication,annotation: annotation)
    }
    
    //notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            // print("Message ID: \(messageID)")
        }
        notificationRecdict = userInfo as NSDictionary
       // notificationCount += 1
        self.notificationRec()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey] {
            // print("Message ID: \(messageID)")
        }
       // notificationCount += 1
        notificationRecdict = userInfo as NSDictionary
        self.notificationRec()
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //  print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       // print("APNs token retrieved: \(deviceToken)")
        if let token = Messaging.messaging().fcmToken{
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
        self.notificationCountApi()
        if UIApplication.shared.applicationState == UIApplicationState.active {
            let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.makeKeyAndVisible()
            
            /* active stage is working */
        } else if (UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.background) {
            //get notification count
            
            let revealViewControllerVcObj = storyboard.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
            (self.window?.rootViewController as! UINavigationController).pushViewController(revealViewControllerVcObj, animated: false)
            
        }
    }
    
    //MARK: - ProgressIndicator view start
    func startProgressView(view:UIView){
        let spinnerActivity = MBProgressHUD.showAdded(to: view, animated: true)
        spinnerActivity.bezelView.color = UIColor.clear
        spinnerActivity.mode = MBProgressHUDMode.indeterminate
        spinnerActivity.animationType = .zoomOut
        
    }
    
    //MARK: - ProgressIndicator View Stop
    func dismissProgressView(view:UIView)  {
        MBProgressHUD.hide(for: view, animated: true)
        
    }
    
    func checkLogin() {
        if DataManager.isUserLoggedIn! == false {
            DataManager.userId = "0" as AnyObject
        }
        let revealViewControllerVcObj = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        (self.window?.rootViewController as! UINavigationController).pushViewController(revealViewControllerVcObj, animated: false)
   
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
        
        myCurrentLongitude = (userLocation.coordinate.longitude).roundToDecimal(4)
        myCurrentLatitude = (userLocation.coordinate.latitude).roundToDecimal(4)
        
        self.getLocationNameAndImage()
        
        if firstCalled == false {
            firstCalled = true
            if connectivity.isConnectedToInternet() {
                self.commonDataViewModel.getCampAllApiResponse()
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func getLocationNameAndImage() {
        let geocoder = CLGeocoder()
        if userLocation != nil {
            geocoder.reverseGeocodeLocation(userLocation!) { (placemarksArray, error) in
                if placemarksArray != nil {
                    if (placemarksArray?.count)! > 0 {
                        let placemark = placemarksArray?.first
                  
                        if placemark?.addressDictionary != nil {
                            if (placemark?.addressDictionary!["Country"]) != nil {
                                countryOnMyCurrentLatLong = (placemark?.addressDictionary!["Country"]) as? String ?? ""
                               
                            }
                        }
                    }
                }
            }
        }
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
                    let notiCountDict:[String: Int] = ["count": notificationCount]
                    // post a notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationRec"), object: nil, userInfo: notiCountDict)
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
        
        if UIApplication.shared.applicationState == UIApplicationState.active {
            if let senderId = notificationRecdict.value(forKey: "user") as? String {
                Singleton.sharedInstance.messageSentUserId = senderId
                self.makeChatUnitId()
            }
            
        } else if (UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.background) {
            
            if let notyType = notificationRecdict.value(forKey: "gcm.notification.type") as? String {
                Singleton.sharedInstance.notiType = notyType
            }
            if let senderId = notificationRecdict.value(forKey: "user") as? String {
                Singleton.sharedInstance.messageSentUserId = senderId
                self.makeChatUnitId()
            }
        }
        self.notificationRec()
        completionHandler([.alert])
    }
    
    func makeChatUnitId() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chatmsgCount"), object: nil, userInfo: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            //  print("Message ID: \(messageID)")
            
        }
      //  notificationCount += 1
        if UIApplication.shared.applicationState == UIApplicationState.active {
            if let senderId = notificationRecdict.value(forKey: "user") as? String {
                Singleton.sharedInstance.messageSentUserId = senderId
                self.makeChatUnitId()
            }
        } else if (UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.background) {
            
            notificationRecdict = userInfo as NSDictionary
            if let notyType = notificationRecdict.value(forKey: "gcm.notification.type") as? String {
               Singleton.sharedInstance.notiType = notyType
            }
            if let senderId = notificationRecdict.value(forKey: "user") as? String {
                Singleton.sharedInstance.messageSentUserId = senderId
                self.makeChatUnitId()
            }
        }
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        userDefault.set(fcmToken, forKey: "DeviceToken")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //  print("Received data message: \(remoteMessage.appData)")
        
    }
}

extension UINavigationController {
    public func hasViewController(ofKind kind: AnyClass) -> UIViewController? {
        return self.viewControllers.first(where: {$0.isKind(of: kind)})
    }
}

open class Reachability {
class func isLocationServiceEnabled() -> Bool {
    if CLLocationManager.locationServicesEnabled() {
        switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
            return false
            case .authorizedAlways, .authorizedWhenInUse:
            return true
            default:
            print("Something wrong with Location services")
            return false
        }
    } else {
            print("Location services are not enabled")
            return false
      }
    }
 }


extension AppDelegate: GADInterstitialDelegate {
    func createAndLoadInterstitial() -> GADInterstitial {
        Singleton.sharedInstance.interstitial = GADInterstitial(adUnitID: GADAdsUnitIdInterstitial)
        Singleton.sharedInstance.interstitial.delegate = self
        
        let request : GADRequest = GADRequest()
        request.testDevices = ["34af7f77e20d0ef06debd6380845e70f"]
        
        Singleton.sharedInstance.interstitial.load(request)
        return Singleton.sharedInstance.interstitial
        
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    
    }
   
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        Singleton.sharedInstance.interstitial = createAndLoadInterstitial()
    
    }
}

extension AppDelegate {
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }

    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }

    func doBackgroundTask() {
        let qos = DispatchQoS(qosClass: .background, relativePriority: 0)
        let backgroundQueue = DispatchQueue.global(qos: qos.qosClass)
        backgroundQueue.async {
            self.beginBackgroundUpdateTask()

            // Do something with the result.
            self.saveAppData()
            
            // End the background task.
            self.endBackgroundUpdateTask()
        }
    }

}
