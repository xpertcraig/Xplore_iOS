//
//  HomeVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

import SimpleImageViewer

class HomeVc: UIViewController, PayPalPaymentDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var homeScrollView: UIScrollView!
    @IBOutlet weak var myCurrentLocation: UILabel!
    @IBOutlet weak var myCurrentLocationState: UILabel!
    @IBOutlet weak var mycurrentLocationImage: UIImageView!
    @IBOutlet weak var currentLocView: UIView!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tripsCollectionView: UICollectionView!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    @IBOutlet weak var markAsFavBtn: UIButton!
    @IBOutlet weak var reviewCollView: UICollectionView!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var tripsCollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewBasedCollHeight: NSLayoutConstraint!
    @IBOutlet weak var tripsPageController: UIPageControl!
    @IBOutlet weak var reviewBasedPageController: UIPageControl!
    @IBOutlet weak var topButtonContainerView: UIView!
    
    //MARK:- Variable Declaration
    var featuredArr: NSArray = []
    var reviewBasedArr: NSArray = []
    var tripsCollScroll: Bool = true
    var campId: Int = -1
    var campIndex: Int = -1
    var campType: String = ""
    let disptchG = DispatchGroup()
    var fromCross: Bool = false
    private let commonDataViewModel = CommonUseViewModel()
    
    //Pappal Config Object
    var payPalConfig = PayPalConfiguration() // default
    //PayPal Environment Closure
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
            
        }
    }
    ///
    var homeRefreshControl = UIRefreshControl()
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moveToControllerAfterLogin()
        var vcArray = (applicationDelegate.window?.rootViewController as! UINavigationController).viewControllers
        print(vcArray)
        
        self.getLocationNameAndImage()
        
        self.homeScrollView.isHidden = true
        self.recallAPIView.isHidden = true
        
        self.overlayView.isHidden = true
        self.favoriteMarkView.isHidden = true
        favMarkbottomConstraint.constant = 150
//        let tapper = UITapGestureRecognizer(target: self, action:#selector(endEditing))
//        self.overlayView.addGestureRecognizer(tapper)
        
        self.searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSearchView)))
        
        self.currentLocView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCurrentImg)))
//        //api
//        self.callAPI()
//        self.checkSubscription()
        
        //refresh controll
        self.refreshData()
        
        //Paypal
        self.setUpPaypal()
        
        self.notificationCountLbl.animShow()
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Singleton.sharedInstance.notiType == "chatMessage" {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.comeFrom = "Notification"
            vc.receiverId = Singleton.sharedInstance.messageSentUserId
            vc.userInfoDict = ["othersUserId": Singleton.sharedInstance.messageSentUserId]
            Singleton.sharedInstance.notiType = ""
            Singleton.sharedInstance.messageSentUserId = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if Singleton.sharedInstance.myCurrentLocDict.count > 0 {
            self.setMyCurrentLoc()
            
        } else if userDefault.value(forKey: myCurrentLocStr) != nil {
            Singleton.sharedInstance.myCurrentLocDict = userDefault.value(forKey: myCurrentLocStr) as! [String: Any]
            userDefault.removeObject(forKey: myCurrentLocStr)
            self.setMyCurrentLoc()
        }
        
        if Singleton.sharedInstance.homeReviewBasedCampsArr.count > 0 {
            self.reloadTbl()
            
        } else if userDefault.value(forKey: homeReviewBasedStr) != nil {
            Singleton.sharedInstance.homeReviewBasedCampsArr = userDefault.value(forKey: homeReviewBasedStr) as! NSArray
            userDefault.removeObject(forKey: homeReviewBasedStr)
            self.reloadTbl()
        }
        
        if Singleton.sharedInstance.homeFeaturesCampsArr.count > 0 {
            self.reloadTbl()
            
        } else if userDefault.value(forKey: homeFeaturesStr) != nil {
            Singleton.sharedInstance.homeFeaturesCampsArr = userDefault.value(forKey: homeFeaturesStr) as! NSArray
            userDefault.removeObject(forKey: homeFeaturesStr)
            self.reloadTbl()
        }
        
        //api
        self.callAPI()
        
        //PayPal
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotiCount(_:)), name: NSNotification.Name(rawValue: "notificationRec"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil);
    }
    
    //MARK:- Function Definitions
    @objc func updateNotiCount(_ notification: NSNotification) {
        if let notiCount = notification.userInfo?["count"] as? Int {
            // An example of animating your label
            self.notificationCountLbl.animShow()
            if notiCount > 9 {
                self.notificationCountLbl.text! = "\(9)+"
            } else {
                self.notificationCountLbl.text! = "\(notiCount)"
            }
        }
    }
    
    func moveToControllerAfterLogin() {
        let sing = Singleton.sharedInstance
        if sing.loginComeFrom == fromAddCamps {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromNearByuser {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromProfile {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromNoti {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromAddCamps {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromSearch {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "SearchCampVC") as! SearchCampVC
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else if sing.loginComeFrom == fromCampDes {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
            swRevealObj.campId = sing.campId
            sing.campId = ""
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        }
    }
    
    func setMyCurrentLoc() {
        if let img = Singleton.sharedInstance.myCurrentLocDict["mycurLocImg"] as? UIImage {
            self.mycurrentLocationImage.image = img
        }
        if let locName = Singleton.sharedInstance.myCurrentLocDict["locName"] as? String {
            self.myCurrentLocation.text = locName
            
        }
        if let locState = Singleton.sharedInstance.myCurrentLocDict["locState"] as? String {
            self.myCurrentLocationState.text = locState
            
        }
        
    }
    
    func reloadTbl() {
        self.featuredArr = Singleton.sharedInstance.homeFeaturesCampsArr
        self.reviewBasedArr = Singleton.sharedInstance.homeReviewBasedCampsArr
        
        self.homeScrollView.isHidden = false
        
        self.setDelegateAndDataSource()
    }
    
    func setDelegateAndDataSource() {
        self.tripsCollectionView.delegate = self
        self.tripsCollectionView.dataSource = self
        
        //pageControl
        self.tripsPageController.numberOfPages = self.featuredArr.count
        self.tripsCollectionView.reloadData()
        
        self.reviewCollView.delegate = self
        self.reviewCollView.dataSource = self
        
        //pageControl
        self.reviewBasedPageController.numberOfPages = self.reviewBasedArr.count
        self.reviewCollView.reloadData()
        
    }
    
    @objc func tapCurrentImg() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.mycurrentLocationImage
            
        }
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        
       // print(placeID)
        
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
                self.mycurrentLocationImage.image = photo;
                
                Singleton.sharedInstance.myCurrentLocDict.updateValue(self.mycurrentLocationImage.image!, forKey: "mycurLocImg")
                //self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        })
    }
    
    func hitLogoutApi() {
        self.logOutAPI()
        
    }
    
    func setUpPaypal() {
        //PayPal SetUp
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Xplore"//Your Company Name
        
        //Url's are just Paypal Merchant Policy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //language in which paypal sdk is shown. 0 for default language of app
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //If you use paypal, it is use address which is register in paypal. if you use both customer have the option to choose different or use paypal address
        payPalConfig.payPalShippingAddressOption = .both
        
    }
    
    //MARK:- Paypal Button Pressed
    //By Palpal
    func payPalButtonPressed() {
        //these are items which are being sold by merchant
        //if there is no amount in "NSDecimalNumber" paypal gives message "Payment not processalbe" and amount sholud be what the user enter reward for help request
        // NSDecimalNumber(string: "\(bidamount)")
        
        let amnt: String = (amountLbl.text!).replacingOccurrences(of: "$", with: "")
        
        let item1 = PayPalItem(name: "Subscription", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(amnt)"), withCurrency: "USD", withSku: "Hip-0037")
        
        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Subscription", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            UINavigationBar.appearance().barTintColor = appThemeColor
            UINavigationBar.appearance().tintColor = nil
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
    }
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        print("PayPal Payment Success !")
        
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
//
//            self.paypalTransaction_id = String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!)
//
//            print(self.paypalTransaction_id)
            
            self.paymentDoneSendToBackendAPI(transactionId: String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!))
            
            // self.postHelpRequestWeb()
            
        })
    }
    
    @objc func tapSearchView() {
       // if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchCampVC") as! SearchCampVC
            vc.searchType = "Home"
            self.navigationController?.pushViewController(vc, animated: false )
            
//        } else {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
//            Singleton.sharedInstance.loginComeFrom = fromSearch
//            self.navigationController?.pushViewController(vc, animated: false)
//
//        }
    }
    
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
                            //applicationDelegate.dismissProgressView(view: self.view)
                            if connectivity.isConnectedToInternet() {
                                //CommonFunctions.showAlert(self, message: serverError, title: appName)

                            } else {
                                CommonFunctions.showAlert(self, message: noInternet, title: appName)

                            }
                        }
                        
                        self.myCurrentLocation.text = placemark?.subLocality
                        self.myCurrentLocationState.text = placemark!.locality
                        
                        Singleton.sharedInstance.myCurrentLocDict.updateValue(self.myCurrentLocation.text!, forKey: "locName")
                        Singleton.sharedInstance.myCurrentLocDict.updateValue(self.myCurrentLocationState.text!, forKey: "locState")
                    }
                }
            }
        }
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.disptchG.enter()
            self.HomeAPIHit()
            if DataManager.isUserLoggedIn! {
                applicationDelegate.notificationCountApi()
                self.disptchG.enter()
                self.checkSubscription()
            }
        } else {
            if self.featuredArr.count == 0 && self.reviewBasedArr.count == 0  {
                self.recallAPIView.isHidden = false
                                
            }
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
        }
    }
    
    func refreshData() {
        self.homeRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.homeRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.homeScrollView.addSubview(self.homeRefreshControl)
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.callAPI()
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    //MARK:- Button Actions
    @IBAction func tapClosePaymentView(_ sender: Any) {
        self.view.endEditing(true)
        self.fromCross = true
        self.hitLogoutApi()
        
    }
    
    
    @IBAction func profileAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.loginAlertFunc(vc: "profile")
        }
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "nearByUser")
            
       }
    }
    
    @IBAction func addCamp(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "addCamps")
            
        }
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "fromNoti")
            
        }
    }
    
    @IBAction func closeFavouritesView(_ sender: Any) {
        favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayView.isHidden = true
            self.view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func tapfavUnfavBtn(_ sender: UIButton) {
        self.overlayView.isHidden = true
        
        if connectivity.isConnectedToInternet() {
            let indexPath = NSIndexPath(item: self.campIndex, section: 0)
            if self.campType == "featured" {
                let cell = self.tripsCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                
                if cell.favouriteButton.currentImage == #imageLiteral(resourceName: "Favoutites") {
                    cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                    
                } else {
                    cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                    
                }
               // cell.favouriteButton.isUserInteractionEnabled = false
            } else {
                let cell = self.reviewCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                
                if cell.favouriteButton.currentImage == #imageLiteral(resourceName: "Favoutites") {
                    cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                    
                } else {
                    cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                    
                }
            }
            self.FavUnfavAPIHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapSaveCampSiteBtn(_ sender: UIButton) {
        self.overlayView.isHidden = true
        var tempArr: NSMutableArray = []
        
        if userDefault.value(forKey: mySavesCamps) != nil {
            tempArr = (NSKeyedUnarchiver.unarchiveObject(with: (userDefault.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            
            var matched: Bool = false
            for i in 0..<tempArr.count {
                if self.campType == "featured" {
                    if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: ((self.featuredArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "campId"))!) {
                        matched = true
                        break
                    }
                } else {
                    if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: ((self.reviewBasedArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "campId"))!) {
                        matched = true
                        break
                    }
                }
            }
            
            if matched == false {
                if self.campType == "featured" {
                    tempArr.add((self.featuredArr.object(at: self.campIndex) as! NSDictionary))
                    userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                    
                } else {
                    tempArr.add((self.reviewBasedArr.object(at: self.campIndex) as! NSDictionary))
                    userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                    
                }
                CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            } else {
                matched = false
                DispatchQueue.main.async {
                    CommonFunctions.showAlert(self, message: alreadySavedCampAlert, title: appName)
                    
                }
            }
        } else {
            if self.campType == "featured" {
                tempArr.add((self.featuredArr.object(at: self.campIndex) as! NSDictionary))
                
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                
            } else {
                tempArr.add((self.reviewBasedArr.object(at: self.campIndex) as! NSDictionary))
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                
            }
            CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            
        }
    }
    
    @IBAction func tapRetryBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.recallAPIView.isHidden = true
        if connectivity.isConnectedToInternet() {
            self.disptchG.enter()
            self.HomeAPIHit()
            
        } else {
            if self.featuredArr.count == 0 && self.reviewBasedArr.count == 0  {
                self.recallAPIView.isHidden = false
                
            }
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func featuredViewAllBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeaturedVc") as! FeaturedVc
        vc.comeFrom = featuredBased
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapFeaturedReviewBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeaturedVc") as! FeaturedVc
        vc.comeFrom = reviewBased
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapViewAllCampsBtn(_ sender: Any) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeaturedVc") as! FeaturedVc
        vc.comeFrom = allCamps
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapPayNowBtn(_ sender: UIButton) {
        self.payPalButtonPressed()
        
    }
    
    @IBAction func tapLogoutBtn(_ sender: UIButton) {
        hitLogoutApi()
        
    }
}

//MARK:- CollectionView Delegate and Datsource
extension HomeVc :UICollectionViewDataSource ,UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> () {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        
        if self.tripsCollScroll == false {
            self.reviewBasedPageController.currentPage = Int(pageNumber)
            
        } else {
            self.tripsPageController.currentPage = Int(pageNumber)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return self.featuredArr.count
            
        } else if collectionView.tag == 2 {
            return self.reviewBasedArr.count
            
        }
        
        return 0
    }
    
    
    @objc func tapTripsShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = tripsCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    @objc func tapReviewShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = reviewCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CustomCell()
        if collectionView.tag == 1 {
            self.tripsCollScroll = true
            
            let cell = self.tripsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
            
            cell.numberOfCellLbl.text! =  String(describing: (indexPath.row + 1)) + "/" + String(describing: (self.featuredArr.count))
            
            cell.favouriteButton.tag = indexPath.row
            cell.favouriteButton.addTarget(self, action:#selector(favoutiteAction(sender:)), for:.touchUpInside)
            
            if ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
                
                cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
                cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                
                
                cell.featuredReviewImgView.sd_setImage(with: URL(string: (String(describing: (((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0))))), placeholderImage: UIImage(named: "loading"))
                
                cell.noImgLbl.isHidden = true
            } else {
                cell.featuredReviewImgView.image = UIImage(named: "")
                cell.noImgLbl.isHidden = false
                
            }
            cell.imagLocNameLbl.text = ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as? String)//((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campState") as? String)
            
            if let img = ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
                
                cell.autherImgView.sd_setShowActivityIndicatorView(true)
                cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
                
            }
            cell.autherNameLbl.text = ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
            
            cell.ttlRatingLbl.text! = String(describing: ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!) //String(describing: (reducedNumberSum))
            cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
            cell.ttlReviewLbl.text! = (String(describing: (((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
            
            if ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
                cell.locationAddressLbl.text! = ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
                
            }
            
            if String(describing: ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                
            } else {
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            }
            
            if String(describing: ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
             
                cell.playImg.isHidden = false
                
                cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
                cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
                
            } else {
                cell.playImg.isHidden = true
                
            }
            cell.tapProfilePicBtn.tag = indexPath.row
            cell.tapProfilePicBtn.addTarget(self, action: #selector(tapFeaturedProfilePicBtn(sender:)), for: .touchUpInside)
            
            return cell
            
        } else if collectionView.tag == 2 {
            self.tripsCollScroll = false
            
            let cell = self.reviewCollView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! CustomCell
            
            cell.numberOfCellLbl.text! =  String(describing: (indexPath.row + 1)) + "/" + String(describing: (self.reviewBasedArr.count))
            
            cell.favouriteButton.tag = indexPath.row
            cell.favouriteButton.addTarget(self, action:#selector(revfavAction(sender:)), for:.touchUpInside)
            
            if ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
                
                cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
                cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.featuredReviewImgView.sd_setImage(with: URL(string: String(describing: (((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0)))), placeholderImage: UIImage(named: "loading"))
                
                cell.noImgLbl.isHidden = true
            } else {
                cell.featuredReviewImgView.image = UIImage(named: "")
                cell.noImgLbl.isHidden = false
                
            }
            
            if ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as? String) != nil {
                cell.imagLocNameLbl.text! = ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as! String)
                
            }
            
            cell.ttlRatingLbl.text! = String(describing: ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!)
            cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
            cell.ttlReviewLbl.text! = (String(describing: (((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
            
            if ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
                cell.locationAddressLbl.text! = ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
                
            }
            
            if let img = ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
                
                cell.autherImgView.sd_setShowActivityIndicatorView(true)
                cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
                
            }
            cell.autherNameLbl.text = ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
            
            if String(describing: ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                
            } else {
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            }
            if String(describing: ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
               // cell.playBtn.isHidden = true
                cell.playImg.isHidden = false
                
                cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
                cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
                
            } else {
               // cell.playBtn.isHidden = true
                cell.playImg.isHidden = true
                
            }
            
            cell.tapProfilePicBtn.tag = indexPath.row
            cell.tapProfilePicBtn.addTarget(self, action: #selector(tapReviewProfilePicBtn(sender:)), for: .touchUpInside)
            
            return cell
            
        }
        
        return cell
    }
    
    @objc func tapFeaturedProfilePicBtn(sender: UIButton) {
        if String(describing: ((self.featuredArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!) == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            if DataManager.isUserLoggedIn! == false {
                self.loginAlertFunc(vc: "viewProfile")
                
            } else {
                let indexVal: NSDictionary = (self.featuredArr.object(at: sender.tag) as! NSDictionary)
                
                if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.loginAlertFunc(vc: "viewProfile")
                  
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                    vc.userInfoDict = indexVal
                    self.navigationController?.pushViewController(vc, animated: true)
                  
                }
            }
        }
    }
    
    @objc func tapReviewProfilePicBtn(sender: UIButton) {
        if String(describing: ((self.featuredArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!) == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            if DataManager.isUserLoggedIn! == false {
                self.loginAlertFunc(vc: "viewProfile")
                
            } else {
                let indexVal: NSDictionary = (self.reviewBasedArr.object(at: sender.tag) as! NSDictionary)
                
                if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                    vc.userInfoDict = indexVal
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
        if collectionView.tag == 1 {
            vc.campId = String(describing: ((self.featuredArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
        } else {
            vc.campId = String(describing: ((self.reviewBasedArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
        }
        if vc.campId == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 1) {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        } else {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

extension HomeVc : UITextFieldDelegate {
    @objc func buttonPressed(_ sender: UIButton) {
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "FeaturedVc") as! FeaturedVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
    
    @objc func favoutiteAction(sender: UIButton) {
        if String(describing: ((self.featuredArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!) == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            if DataManager.isUserLoggedIn! {
                self.campIndex = sender.tag
                openfavView(index: sender.tag)
                
            } else {
                self.loginAlertFunc(vc: "markFav")
                Singleton.sharedInstance.favIndex = sender.tag
                
            }
        }
    }
    
    func openfavView(index: Int) {
        self.campIndex = index
        if String(describing: ((self.featuredArr.object(at: index) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
            
        } else {
            self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
            
        }
        self.scrollToSelectedIndex(selColl: self.tripsCollectionView, index: index)
        self.campType = "featured"
        self.campId = Int(String(describing: ((self.featuredArr.object(at: index) as! NSDictionary).value(forKey: "campId"))!))!
        self.favMarkbottomConstraint.constant = 150
        self.overlayView.tag = index
        self.overlayView.isHidden = false
        self.favoriteMarkView.isHidden = false
        self.paymentView.isHidden = true
        self.view.layoutIfNeeded()
        
    }
    
    func openRevFavView(index: Int) {
        self.campIndex = index
        if String(describing: ((self.reviewBasedArr.object(at: index) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
            
        } else {
            self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
            
        }
        
        self.scrollToSelectedIndex(selColl: self.reviewCollView, index: index)
        self.campType = "reviewBased"
        self.campId = Int(String(describing: ((self.reviewBasedArr.object(at: index) as! NSDictionary).value(forKey: "campId"))!))!
        self.favMarkbottomConstraint.constant = 150
        self.overlayView.tag = index
        self.overlayView.isHidden = false
        self.favoriteMarkView.isHidden = false
        self.paymentView.isHidden = true
        self.view.layoutIfNeeded()
        
    }
    
    @objc func revfavAction(sender: UIButton) {
        if String(describing: ((self.featuredArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!) == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            if DataManager.isUserLoggedIn! {
                self.campIndex = sender.tag
                openRevFavView(index: sender.tag)
                
            } else {
                self.loginAlertFunc(vc: "markFav")
                Singleton.sharedInstance.favIndex = sender.tag
            }
        }
    }
    
    func scrollToSelectedIndex(selColl: UICollectionView, index: Int) {
        selColl.scrollToItem(at:IndexPath(item: index, section: 0), at: .right, animated: false)
        
    }
    
    @objc func endEditing () {
        favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayView.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension HomeVc {
    func HomeAPIHit() {
        if (Singleton.sharedInstance.homeFeaturesCampsArr.count == 0 && userDefault.value(forKey: homeFeaturesStr) == nil){
            applicationDelegate.startProgressView(view: self.view)
            
        }
        // start the timer
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var userId: String = ""
            if let userId1 = DataManager.userId as? String {
                userId = userId1
                
            } else {
                userId = ""
                
            }
            let param: NSDictionary = ["userId": userId, "latitude": myCurrentLatitude, "longitude": myCurrentLongitude, "country": countryOnMyCurrentLatLong]
            
            print(param)
            
            AlamoFireWrapper.sharedInstance.getPost(action: "home.php", param: param as! [String : Any], onSuccess: { (responseData) in
                
                self.disptchG.leave()
                applicationDelegate.dismissProgressView(view: self.view)
                
                self.homeRefreshControl.endRefreshing()
                
                if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                    if (String(describing: (dict["success"])!)) == "1" {
                        let retValues = (dict["result"]! as! NSDictionary)
                        
                        print(retValues)
                        
                        self.homeScrollView.isHidden = false
                        self.recallAPIView.isHidden = true
                        self.getLocationNameAndImage()
                        
                        self.featuredArr = retValues.value(forKey: "featuredCampsite") as! NSArray
                        self.reviewBasedArr = retValues.value(forKey: "reviewBased") as! NSArray
                        
                        Singleton.sharedInstance.homeFeaturesCampsArr = self.featuredArr
                        Singleton.sharedInstance.homeReviewBasedCampsArr = self.reviewBasedArr
                        
                        //
                        self.setDelegateAndDataSource()

                    } else {
                        CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                        
                    }
                }
            }) { (error) in
                self.disptchG.leave()
                if Singleton.sharedInstance.homeFeaturesCampsArr.count == 0 && Singleton.sharedInstance.homeReviewBasedCampsArr.count == 0{
                    self.recallAPIView.isHidden = false
                    
                }
                applicationDelegate.dismissProgressView(view: self.view)
                if connectivity.isConnectedToInternet() {
                    CommonFunctions.showAlert(self, message: serverError, title: appName)
                    
                } else {
                    CommonFunctions.showAlert(self, message: noInternet, title: appName)
                    
                }
            }
         }
    }
    
    func checkSubscription() {
        //applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "isPaid.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            self.disptchG.leave()
           // applicationDelegate.dismissProgressView(view: self.view)
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                   // print(dict)
                    if String(describing: (dict["result"])!) == "1" {
                        
                        let tabBarControllerItems = self.tabBarController?.tabBar.items
                        if let tabArray = tabBarControllerItems {
                            let tabBarItem1 = tabArray[0]
                            let tabBarItem2 = tabArray[1]
                            let tabBarItem3 = tabArray[2]
                            let tabBarItem4 = tabArray[3]
                            let tabBarItem5 = tabArray[4]
                            
                            tabBarItem1.isEnabled = true
                            tabBarItem2.isEnabled = true
                            
                            tabBarItem3.isEnabled = true
                            tabBarItem4.isEnabled = true
                            tabBarItem5.isEnabled = true
                            
                        }
                        let sing = Singleton.sharedInstance
                        if sing.loginComeFrom == fromFavCamps {
                            self.openfavView(index: sing.favIndex)
                            sing.favIndex = -1
                        } else if sing.loginComeFrom == fromRevFavCamp {
                            self.openRevFavView(index: sing.favIndex)
                            sing.favIndex = -1
                        }
                    } else {
                        self.subscriptionCargesAPIHit()
                        
                        self.overlayView.isHidden = false
                        self.paymentView.isHidden = false
                        self.favoriteMarkView.isHidden = true
                        
                        let tabBarControllerItems = self.tabBarController?.tabBar.items
                        
                        if let tabArray = tabBarControllerItems {
                            let tabBarItem1 = tabArray[0]
                            let tabBarItem2 = tabArray[1]
                            let tabBarItem3 = tabArray[2]
                            let tabBarItem4 = tabArray[3]
                            let tabBarItem5 = tabArray[4]
                            
                            tabBarItem1.isEnabled = false
                            tabBarItem2.isEnabled = false
                            
                            tabBarItem3.isEnabled = false
                            tabBarItem4.isEnabled = false
                            tabBarItem5.isEnabled = false
                           
                        }
                        
//                        let alert = UIAlertController(title: appName, message: LogoutMessage, preferredStyle: .alert)
//                        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
//                            alert.dismiss(animated: true, completion: nil)
//
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UpdatePaymentVC") as! UpdatePaymentVC
//                            self.navigationController?.pushViewController(vc, animated: true)
//
//                        })
//
//                        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
//                            alert.dismiss(animated: true, completion: nil)
//
//                            self.hitLogoutApi()
//                        })
//                        alert.addAction(yesBtn)
//                        alert.addAction(noBtn)
//                        self.present(alert, animated: true, completion: nil)
                        
                    }
                } else {
                    //CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.disptchG.leave()
            //applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func paymentDoneSendToBackendAPI(transactionId: String) {
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["userId": DataManager.userId, "transactionId": transactionId, "transactionAmount": (amountLbl.text!).replacingOccurrences(of: "$", with: "")]
        
     //   print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "paypalpayment.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let alert = UIAlertController(title: appName, message: paySuccAlert, preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: okBtnTitle, style: .default, handler: { (UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                       
                        self.overlayView.isHidden = true
                        
                    })
                    
                    alert.addAction(okBtn)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }

    func logOutAPI() {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "unRegisterFirebaseToken.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    DataManager.isUserLoggedIn = false
                    
                    //   userDefault.set(false,forKey: login.USER_DEFAULT_LOGIN_CHECK_Key)
                    let loginVcObj = storyboard.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
                    var vcArray = (applicationDelegate.window?.rootViewController as! UINavigationController).viewControllers
                    vcArray.removeAll()
                    vcArray.append(loginVcObj)
                    
                    if self.fromCross == true {
                        self.overlayView.isHidden = true
                        self.fromCross = false
                        return
                        
                    }
                    self.commonDataViewModel.removeDataonLogout()
                    
                    (applicationDelegate.window?.rootViewController as! UINavigationController).setViewControllers(vcArray, animated: false)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Api's Hit
    func FavUnfavAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "markFavourite.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
            
            if self.campType == "featured" {
                let cell = self.tripsCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
                
            } else {
                let cell = self.reviewCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
                
            }
            self.campIndex = -1
            self.campId = -1
            ///////
           // applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                  //  print(dict)
                    self.disptchG.enter()
                    self.HomeAPIHit()
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            if self.campType == "featured" {
                let cell = self.tripsCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
                
            } else {
                let cell = self.tripsCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
                
            }
            
            ////
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func subscriptionCargesAPIHit() {
       // applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "subscriptioncharges.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
          //  applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    //  print(dict)
                    self.amountLbl.text = "$" + String(describing: ((dict["result"] as! NSDictionary).value(forKey: "charges"))!)
                    
                } else {
                    // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
         //   applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
}

//MARK:- login alert
extension HomeVc {
    func loginAlertFunc(vc: String) {
        let alert = UIAlertController(title: appName, message: loginRequired, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
            if vc == "profile" {
                Singleton.sharedInstance.loginComeFrom = fromProfile
                
            } else if vc == "nearByUser" {
                Singleton.sharedInstance.loginComeFrom = fromNearByuser
               
            } else if vc == "addCamps" {
                Singleton.sharedInstance.loginComeFrom = fromAddCamps
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromNoti
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromFavCamps
                
            } else if vc == "viewProfile" {
                Singleton.sharedInstance.loginComeFrom = fromViewProfile
                
            }
            self.navigationController?.pushViewController(controller, animated: false)
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
}
