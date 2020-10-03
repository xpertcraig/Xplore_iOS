//
//  CampDescriptionVc.swift
//  XploreProject
//
//  Created by shikha kochar on 20/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import Cosmos
import MapKit

import AVKit
import AVFoundation

import SimpleImageViewer
import WebKit

class CampDescriptionVc: UIViewController, MKMapViewDelegate, AVPlayerViewControllerDelegate {

    //MARK:- IbOutlets
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var overlayview: UIView!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var noImage: UILabel!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var descriptionTableView: UITableView!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var revieTableHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var maincontentView: UIView!
    @IBOutlet weak var scroolView: UIScrollView!
    
    @IBOutlet weak var abuseImg: UIImageView!
    @IBOutlet weak var abouseBtn: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var markAsFavBtn: UIButton!
    
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var nearByView: UIView!
    @IBOutlet weak var gallaryView: UIView!
    @IBOutlet weak var mapImgView: UIImageView!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var myCampImgesCollView: UICollectionView!
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ttlReviewLbl: UILabel!
    @IBOutlet weak var mapBelowAddrLbl: UILabel!
    @IBOutlet weak var setMapView: MKMapView!
    
    //
    @IBOutlet weak var ttlRatingLbl: UILabel!
    @IBOutlet weak var ratingStarView: CosmosView!
    @IBOutlet weak var ttlReviewBelowLbl: UILabel!
    
    //
    @IBOutlet weak var fiveStarProgressBar: LinearProgressBar!
    @IBOutlet weak var fourStarProgressBar: LinearProgressBar!
    @IBOutlet weak var threeStarProgressBar: LinearProgressBar!
    @IBOutlet weak var twoStarProgressBar: LinearProgressBar!
    @IBOutlet weak var oneStarProgressBar: LinearProgressBar!
    
    //
    @IBOutlet weak var fiveStarRatingLbl: UILabel!
    @IBOutlet weak var fourStarRatingLbl: UILabel!
    @IBOutlet weak var ThreeStarRatingLbl: UILabel!
    @IBOutlet weak var twoStarRatingLbl: UILabel!
    @IBOutlet weak var oneStarRatingLbl: UILabel!
    
    @IBOutlet weak var abouseView: UIView!
    @IBOutlet weak var abouseTxtVIew: UITextView!
    
    @IBOutlet weak var reviewTblVIewContainingVIew: UIView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var beTheFirstLbl: UILabel!
    @IBOutlet weak var favImgView: UIImageView!
    
    @IBOutlet weak var autherImgView: UIImageViewCustomClass!
    @IBOutlet weak var autherNameLbl: UILabel!
    
    @IBOutlet weak var googleMapView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var topNavigationHeight: NSLayoutConstraint!
    @IBOutlet weak var followUnfollowBtn: UIButtonCustomClass!
    
    //MARK:- Variable Declaration
   // var nibContents = Bundle.main.loadNibNamed("MarkAbouseAlert", owner: nil, options: nil)
    var campId: String = ""
    var campDetailArr: NSArray = []
    var myCampImgArr: NSArray = []
    var detailLongLat: CLLocation!
    var reviewsArr: NSArray = []
    private let commonDataViewModel = CommonUseViewModel()
    var timer:Timer? = nil
    
    var selectedAnnotation: MKPointAnnotation?
    var campDetailDict: NSMutableDictionary = [:]
   
    var playerController = AVPlayerViewController()
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tap gasture
        self.directionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDirectionView)))
        self.nearByView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapNearByView)))
        self.gallaryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGallaryView)))
        
        //MapView
        setMapView!.showsPointsOfInterest = true
        if let mapView = self.setMapView {
            mapView.delegate = self
            
        }
        
        self.scroolView.isHidden = true
        self.recallAPIView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.isUserLoggedIn! == true {
            self.topNavigationView.isHidden = false
            self.topNavigationHeight.constant = 44
            
        }
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        
        //camp Description
        self.callAPI()
        self.googleMapView.isHidden = true
        self.activityIndicator.isHidden = true
        
        self.googleMapView.uiDelegate = self
        //self.playerController.removeObserver(self)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
        if self.googleMapView != nil {
            self.googleMapView.isHidden = true
        }
        if self.activityIndicator != nil {
            self.activityIndicator.isHidden = true
        }
    }
    
    //MARK:- Function Definition
    func webViewSetUp(urlStr: String) {
        let myUrl = URL(string: urlStr)
        let myReq = URLRequest(url: myUrl!)
        self.googleMapView.load(myReq)
        
        self.googleMapView.isHidden = false
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.campDetailsApiHit()
            
        } else {
            if self.campDetailDict == [:] {
                self.recallAPIView.isHidden = false
                
            }
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
           // CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func setCampDetails(recDict: NSDictionary) {
        self.descriptionText.text = recDict.value(forKey: "campDescription") as? String
        self.detailLongLat = CLLocation(latitude: Double(String(describing: ((recDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "lat"))!))! , longitude: Double(String(describing: ((recDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "lng"))!))!)
        
        if let addr = (recDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as? String {
            var trimmedAddr: String = ""
             trimmedAddr = addr.replacingOccurrences(of: ", , , ", with: ", ")
             if trimmedAddr == "" {
                 trimmedAddr = addr.replacingOccurrences(of: ", , ", with: ", ")
             }
            self.addressLbl.text = trimmedAddr
        }
        self.addressLbl.text = ""
        
        self.mapBelowAddrLbl.text = (recDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as? String
        
        self.ratingLbl.text = String(describing: (recDict.value(forKey: "campRating"))!)
        self.ttlRatingLbl.text = String(describing: (recDict.value(forKey: "campRating"))!)
        
        if let img = (recDict.value(forKey: "profileImage") as? String) {
            
            self.autherImgView.sd_setShowActivityIndicatorView(true)
            self.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            self.autherImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit) { (rSuccess) in
                //
            }
        }        
        self.autherNameLbl.text = (recDict.value(forKey: "authorName") as? String)
        
      // set follow/unfollow status
        if String(describing: (DataManager.userId)) == String(describing: (recDict.value(forKey: "campAuthor"))!) {
            self.followUnfollowBtn.isHidden = true
        } else {
            let followStatus = "\(recDict.value(forKey: "follow") as? Int ?? 0)"
            self.setFollowUnfollowBtnApearance(status: followStatus)
        }
        
        self.ratingView.rating = Double(String(describing: (recDict.value(forKey: "campRating"))!))!
        self.ratingStarView.rating = Double(String(describing: (recDict.value(forKey: "campRating"))!))!
        self.ttlReviewLbl.text = String(describing: (recDict.value(forKey: "campTotalReviews"))!) + " reviews"
        self.ttlReviewBelowLbl.text = String(describing: (recDict.value(forKey: "campTotalReviews"))!) + " reviews"
        
        if String(describing: (recDict.value(forKey: "isFav"))!) == "0" {
            self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
            self.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
            
        } else {
            self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
            self.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
            
        }
        
        if String(describing: (recDict.value(forKey: "isAbuse"))!) == "0" {
            self.abuseImg.image = UIImage(named: "non-abuse")
        } else {
            self.abuseImg.image = UIImage(named: "Abuse")
//            self.abuseImg.image = self.abuseImg.image?.withRenderingMode(.alwaysTemplate)
//            self.abuseImg.tintColor = UIColor.appThemeGreenColor()
        }
        
        if (recDict.value(forKey: "ratingsArray") as! NSArray).count != 0 {
            self.fiveStarRatingLbl.text = String(describing: ((recDict.value(forKey: "ratingsArray") as! NSArray).object(at: 0)))
            self.fourStarRatingLbl.text = String(describing: ((recDict.value(forKey: "ratingsArray") as! NSArray).object(at: 1)))
            self.ThreeStarRatingLbl.text = String(describing: ((recDict.value(forKey: "ratingsArray") as! NSArray).object(at: 2)))
            self.twoStarRatingLbl.text = String(describing: ((recDict.value(forKey: "ratingsArray") as! NSArray).object(at: 3)))
            self.oneStarRatingLbl.text = String(describing: ((recDict.value(forKey: "ratingsArray") as! NSArray).object(at: 4)))
            
        } else {
            self.fiveStarRatingLbl.text = "0"
            self.fourStarRatingLbl.text = "0"
            self.ThreeStarRatingLbl.text = "0"
            self.twoStarRatingLbl.text = "0"
            self.oneStarRatingLbl.text = "0"
            
        }
        
        self.showLocation(latti: self.detailLongLat.coordinate.latitude, longi: self.detailLongLat.coordinate.longitude)
        
    }
    
    func setFollowUnfollowBtnApearance(status: String) {
        if status == "0" {
            self.followUnfollowBtn.backgroundColor = UIColor.appThemeGreenColor()
            self.followUnfollowBtn.setTitle("Follow", for: .normal)
            self.followUnfollowBtn.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.followUnfollowBtn.backgroundColor = UIColor.white
            self.followUnfollowBtn.setTitle("Unfollow", for: .normal)
            self.followUnfollowBtn.setTitleColor(UIColor.appThemeGreenColor(), for: .normal)
        }
        self.followUnfollowBtn.isHidden = false
    }
    
    func showLocation(latti: Double, longi: Double) {
        let orgLocation = CLLocationCoordinate2DMake(latti, longi)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = orgLocation
        setMapView!.addAnnotation(dropPin)
        self.setMapView?.setRegion(MKCoordinateRegionMakeWithDistance(orgLocation, 500, 500), animated: true)
        
        self.setMapView.userLocation.title = "hello"
        
//        self.setMapView.isScrollEnabled = false
//        self.setMapView.isZoomEnabled = false
    }
    
    @objc func tapDirectionView() {
        //Working in Swift new versions.
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            
           // self.webViewSetUp(urlStr: "comgooglemaps://?saddr=&daddr=\(self.detailLongLat.coordinate.latitude),\(self.detailLongLat.coordinate.longitude)&directionsmode=driving")
            
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(self.detailLongLat.coordinate.latitude),\(self.detailLongLat.coordinate.longitude)&directionsmode=driving")! as URL)
            
        } else {
            NSLog("Can't use com.google.maps://")
            CommonFunctions.showAlert(self, message: downloadGoogleMapApp, title: appName)
            
        }
    }
    
    @objc func tapNearByView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearbyVC") as! NearbyVC
        vc.recLat = String(describing: ((self.campDetailDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "lat"))!)
        vc.recLong = String(describing: ((self.campDetailDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "lng"))!)        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func tapGallaryView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GalleryVc") as! GalleryVc
        vc.campId = self.campId
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    @objc func tapProfilePicBtn(sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            if String(describing: (DataManager.userId)) == String(describing: ((self.reviewsArr.object(at: sender.tag) as! NSDictionary).value(forKey: "userId"))!) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                vc.userInfoDict = (self.reviewsArr.object(at: sender.tag) as! NSDictionary)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        } else {
            self.loginAlertFunc(vc: "profile", viewController: self)
        }
    }
    
    //MARK:- Button Action
    @IBAction func profileAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.loginAlertFunc(vc: "profile", viewController: self)
        }
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "nearByUser", viewController: self)
            
       }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "fromNoti", viewController: self)
            
        }
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "addCamps", viewController: self)
            
        }
    }
    
    @IBAction func addReviewAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            if String(describing: (DataManager.userId)) == String(describing: (self.campDetailDict.value(forKey: "campAuthor"))!) {
                CommonFunctions.showAlert(self, message: selfPost, title: appName)
                
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "addReviewVc") as! addReviewVc
                vc.campId = self.campId
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        } else {
            self.loginAlertFunc(vc: "campDescription", viewController: self)
            
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
        
    }
    
    @IBAction func viewAllReview(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewcontroller") as! ReviewViewcontroller
            vc.campId = self.campId
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "campDescription", viewController: self)
            
        }
    }
    
    @IBAction func abuseAction(_ sender: Any) {
        if DataManager.isUserLoggedIn! {
            if String(describing: (self.campDetailDict.value(forKey: "isAbuse"))!) == "0" {
                self.overlayview.isHidden = false
                self.favoriteMarkView.isHidden = true
                self.abouseView.isHidden = false
                
            } else {
                CommonFunctions.showAlert(self, message: alreadyMarkAbuseAlert, title: appName)
                
            }
        } else {
            self.loginAlertFunc(vc: "campDescription", viewController: self)
            
        }
    }
    
    @IBAction func tapRetryBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.recallAPIView.isHidden = true
        if connectivity.isConnectedToInternet() {
            self.campDetailsApiHit()
            
        } else {
            if self.campDetailDict == [:] {
                self.recallAPIView.isHidden = false
                
            }
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func favoutiteAction(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            self.campId = (String(describing: (self.campDetailDict.value(forKey: "campId"))!))
            
            self.favMarkbottomConstraint.constant = 0
            UIView.animate(withDuration: 1) {
                self.favMarkbottomConstraint.constant = 150
                
                self.overlayview.tag = sender.tag
                self.overlayview.isHidden = false
                self.favoriteMarkView.isHidden = false
                self.abouseView.isHidden = true
                self.view.layoutIfNeeded()
            }
        } else {
            self.loginAlertFunc(vc: "campDescription", viewController: self)
            
        }
    }
    
    @IBAction func tapfavUnfavBtn(_ sender: UIButton) {
        self.overlayview.isHidden = true
        
        if connectivity.isConnectedToInternet() {
            if self.markAsFavBtn.currentImage == #imageLiteral(resourceName: "Favoutites") {
              //  self.markAsFavBtn.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            } else {
               // self.markAsFavBtn.setImage(UIImage(named: "Favoutites"), for: .normal)
                
            }
            
            self.FavUnfavAPIHit()
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapSaveCampSiteBtn(_ sender: UIButton) {
        self.overlayview.isHidden = true
        var tempArr: NSMutableArray = []
       
        if userDefault.value(forKey: mySavesCamps) != nil {
           tempArr = (NSKeyedUnarchiver.unarchiveObject(with: (userDefault.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            
            var matched: Bool = false
            for i in 0..<tempArr.count {
                if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: (campDetailDict.value(forKey: "campId"))!) {
                    matched = true
                    break
                }
            }
            
            if matched == false {
                tempArr.add(self.campDetailDict)
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                
                CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            } else {
                matched = false
                CommonFunctions.showAlert(self, message: alreadySavedCampAlert, title: appName)
                
            }
        } else {
            tempArr.add(self.campDetailDict)
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
            
            CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            
        }
    }
    
    @IBAction func closeFavouritesView(_ sender: Any) {
        favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayview.isHidden = true
            self.view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
      //   backBtnPressedForPublished = true
        if self.googleMapView.isHidden == false {
           // self.googleMapView.isHidden = true
            
            UIView.animate(withDuration: 3.0, delay: 2.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.googleMapView.isHidden = true
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        } else {
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.overlayview.isHidden = true
        
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.overlayview.isHidden = true
        if self.abouseTxtVIew.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            CommonFunctions.showAlert(self, message: alreadyMarkAbuseAlert, title: appName)
            
        } else {
            self.markAbouseApiHit()
            
        }
    }
    
    @IBAction func tapAutherProfileImg(_ sender: Any) {
        self.view.endEditing(true)
        if DataManager.isUserLoggedIn! {
            if String(describing: (DataManager.userId)) == String(describing: (campDetailDict.value(forKey: "campAuthor"))!) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                let dict: NSDictionary = ["userId": String(describing: (campDetailDict.value(forKey: "campAuthor"))!), "profileImage": String(describing: (campDetailDict.value(forKey: "profileImage"))!), "name": String(describing: (campDetailDict.value(forKey: "authorName"))!)]
                
                vc.userInfoDict = dict
                self.navigationController?.pushViewController(vc, animated: true)

            }
        } else {
            self.loginAlertFunc(vc: "campDescription", viewController: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        
        self.selectedAnnotation?.title = (self.campDetailDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as? String
        
    }
    
    @IBAction func tapFollowUnfollowBtn(_ sender: Any) {
        self.view.endEditing(true)
        if String(describing: (self.campDetailDict.value(forKey: "campId"))!) == "0" {
            CommonFunctions.showAlert(self, message: noCampAtLoc, title: appName)
        } else {
            if DataManager.isUserLoggedIn! == false {
                self.loginAlertFunc(vc: "viewProfile", viewController: self)
                
            } else {
                if connectivity.isConnectedToInternet() {
                    applicationDelegate.startProgressView(view: self.view)
                    let indexVal: NSDictionary = self.campDetailDict
                    let param: [String: Any] = ["userId": "\(DataManager.userId)", "follow": String(describing: (indexVal.value(forKey: "campAuthor"))!)]
                    
                    var apiToBeCalled: String = ""
                    let followStatus = "\(indexVal.value(forKey: "follow") as? Int ?? 0)"
                    if followStatus == "0" {
                        apiToBeCalled = apiUrl.followApi.rawValue
                    } else {
                        apiToBeCalled = apiUrl.unFollowApi.rawValue
                    }
                   // print(param)
                    self.commonDataViewModel.followUnfollowUwser(actionUrl: apiToBeCalled, param: param) { (rMsg) in
                        print(rMsg)
                        applicationDelegate.dismissProgressView(view: self.view)
                       if followStatus == "0" {
                            self.campDetailDict["follow"] = 1
                            self.setFollowUnfollowBtnApearance(status: "1")
                       } else {
                            self.campDetailDict["follow"] = 0
                            self.setFollowUnfollowBtnApearance(status: "0")
                       }
                    }
                } else {
                    self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                    //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                }
            }
        }

        
    }
 
    @IBAction func tapShareBtn(_ sender: Any) {
        let indexP = IndexPath(item: 0, section: 0)
        let cell = self.myCampImgesCollView.cellForItem(at: indexP) as? CustomCell
        
        let indexVal = self.campDetailDict
        let campTitle = indexVal.value(forKey: "campTitle") as! String
        let campImgArr = indexVal.value(forKey: "campImages") as! [String]
        let campImg = campImgArr[0]
        
        self.commonDataViewModel.shareAppLinkAndImage(campTitle: "\(campTitle)\n" , campImg: (cell?.featuredReviewImgView.image)!, campimg1: campImg, sender: sender as! UIButton, vc: self)
    }
}

extension CampDescriptionVc {
    func getSymbolForCurrencyCode(code: String) -> String? {
        let result = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first { $0.currencyCode == code }
        return result?.currencySymbol
    }
    
    func campDetailsApiHit() {
        if self.campDetailDict == [:] {
            applicationDelegate.startProgressView(view: self.view)
            
        }
        var userLId: String = ""
        if let userId = (DataManager.userId as? String) {
            userLId = userId
            
        }
        let api: String = "campDetails.php?userId=\(userLId)&campId=\((self.campId))"
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retDict = (dict["result"] as! NSDictionary)
                   
                 //   print(retDict)
                    self.scroolView.isHidden = false
                    self.recallAPIView.isHidden = true
                    self.campDetailDict = retDict.mutableCopy() as! NSMutableDictionary
                    
                    let typeStr = (retDict.value(forKey: "campgroundType") as! NSArray).componentsJoined(by: ", ") // "1,2,3"
                    let bstMnth = (retDict.value(forKey: "bestMonth") as! NSArray).componentsJoined(by: ", ")
                    //let hookups = (retDict.value(forKey: "hookupsAvailable") as! NSArray).componentsJoined(by: ", ")
                    let amenties = (retDict.value(forKey: "campsiteamenities") as! NSArray).componentsJoined(by: ", ")
                    
                    var webUrl: String = ""
                    if retDict.value(forKey: "webUrl") as? String == "" {
                        webUrl = "N/A"
                        
                    } else {
                        webUrl = retDict.value(forKey: "webUrl") as! String
                        
                    }
                    
                    var price: String = ""
                    if let addr = (retDict.value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as? String {
                        
                        let splistAddr = addr.components(separatedBy: ", ")
                        if let cName = self.currency(recStr: splistAddr.last ?? "India") {
                            
                            let strArr = Array(cName)
                            if cName.count >= 3 {
                                let sym = "\(self.getSymbolForCurrencyCode(code: "\(strArr[0])\(strArr[1])\(strArr[2])")!)"
                                
                                price = "\(sym)\(String(describing: ((retDict.value(forKey: "price")))!))"
                            } else if cName.count == 2 {
                                price = "\(self.getSymbolForCurrencyCode(code: "\(strArr[0])\(strArr[1])")!)\(String(describing: ((retDict.value(forKey: "price")))!))"
                            } else {
                                price = (String(describing: ((retDict.value(forKey: "price")))!))
                            }
                        } else {
                            price = (String(describing: ((retDict.value(forKey: "price")))!))
                        }
                    }
                    
                    self.campDetailArr = [["key": "Campground Type","value": typeStr], ["key": "Climate", "value": (retDict.value(forKey: "climate") as! String)], ["key": "Elevation","value": String(describing: ((retDict.value(forKey: "elevation")))!)], ["key": "Best Month to Visit","value": bstMnth], ["key": "Number Of Sites","value": String(describing: ((retDict.value(forKey: "numberofSites")))!)], ["key": "Price","value": price], /*["key": "Hookups Available","value": hookups],*/ ["key": "Amenities","value": amenties], ["key": "Website","value": webUrl]]
                    
                    self.descriptionTableView.dataSource = self
                    self.descriptionTableView.delegate = self
                    
                    self.descriptionTableView.reloadData()
                    self.descriptionTableView.layoutIfNeeded()
                    
                    //print(self.descriptionTableView.contentSize.height)
                    self.descriptionHeight.constant = self.descriptionTableView.contentSize.height
                    
                    ///
                    self.setCampDetails(recDict: retDict)
                    
                    ///
                    self.reviewsArr = retDict.value(forKey: "review") as! NSArray
                    
                    if self.reviewsArr.count == 0 {
                        self.reviewTblVIewContainingVIew.isHidden = true
                        
                        self.beTheFirstLbl.isHidden = false
                        
                    } else {
                        self.reviewTblVIewContainingVIew.isHidden = false
                        self.beTheFirstLbl.isHidden = true
                    }
                    self.reviewTableView.reloadData()
                    
                    self.revieTableHeight.constant = self.reviewTableView.contentSize.height
                    self.reviewTableView.layoutIfNeeded()
                    
                    ///
                    self.myCampImgArr = retDict.value(forKey: "campImages") as! NSArray
                    //pageControl
                    self.pageControl.numberOfPages = self.myCampImgArr.count
                    self.myCampImgesCollView.reloadData()
                    
                } else {
                    self.scroolView.isHidden = true
                    self.recallAPIView.isHidden = false
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            if self.campDetailDict == [:] {
                self.recallAPIView.isHidden = false
                
            }
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Api's Hit
    func FavUnfavAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "markFavourite.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
            self.markAsFavBtn.isUserInteractionEnabled = true
            
            ///////
          //  applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    self.campDetailsApiHit()
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.markAsFavBtn.isUserInteractionEnabled = true
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func markAbouseApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["userId": DataManager.userId, "campId": self.campId, "description": self.abouseTxtVIew.text!]
        
       // print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "markAbuse.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title:appName, message: receivedAbouseAlert , preferredStyle: .alert)
                        // Create the actions
                        let YesAction = UIAlertAction(title:Ok, style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            
                            self.abouseTxtVIew.text! = ""
                            self.abuseImg.image = UIImage(named: "Abuse")
                            self.campDetailsApiHit()
                            
                        }
                        alertController.addAction(YesAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                 //   print(dict)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    @objc func doneButtonTextView(_ sender: UITextView) {
        self.view.endEditing(true)
        
    }
}

//MARK:- Collection View Delegate
extension CampDescriptionVc : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if self.myCampImgArr.count == 0 {
            self.noImage.isHidden = false
            
        } else {
            self.noImage.isHidden = true
            
        }
        
        return self.myCampImgArr.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
    
        cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
        cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        if let img =  (self.myCampImgArr.object(at: indexPath.row)) as? String {
            
            cell.gradientView.isHidden = true
            cell.featuredReviewImgView.contentMode = .center
//            cell.featuredReviewImgView.sd_setImage(with: URL(string: img)) { (image, error, cache, url) in
//                // Your code inside completion block
//                cell.gradientView.isHidden = false
//                cell.featuredReviewImgView.contentMode = .scaleAspectFill
//                
//            }

            cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill) { (rSuccess) in
                //
            }
            cell.gradientView.isHidden = false
            
            //cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill)
        }
        
      //  cell.featuredReviewImgView.sd_setImage(with: URL(string: (String(describing: (self.myCampImgArr.object(at: indexPath.row))))), placeholderImage: UIImage(named: ""))
       
        cell.imagLocNameLbl.text = (self.campDetailDict.value(forKey: "campTitle") as? String)
        
        if (self.campDetailDict.value(forKey: "videoindex") as! String) != "-1" && (self.campDetailDict.value(forKey: "videoindex") as! String) != "0" && (self.campDetailDict.value(forKey: "videoindex") as! String) != "" && (self.campDetailDict.value(forKey: "campsiteVideo") as! String) != "" {
            if indexPath.row == Int(self.campDetailDict.value(forKey: "videoindex") as! String)! - 1 {
                cell.playBtn.isHidden = false
                cell.playImg.isHidden = false

                cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
                cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)

            } else {
                cell.playBtn.isHidden = true
                cell.playImg.isHidden = true

            }
        } else {
            cell.playBtn.isHidden = true
            cell.playImg.isHidden = true

        }
        cell.playBtn.tag = indexPath.row
        cell.playBtn.addTarget(self, action: #selector(tapPlayBtn), for: .touchUpInside)
        
        return cell
        
    }
    
    @objc func tapPlayBtn(sender: UIButton) {
        if (self.campDetailDict.value(forKey: "campsiteVideo") as! String) != "" {
            let player = AVPlayer(url: URL(string: (self.campDetailDict.value(forKey: "campsiteVideo") as! String))!)
            playerController = AVPlayerViewController()
            NotificationCenter.default.addObserver(self, selector: #selector(didfinishplaying(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            playerController.player = player
            playerController.allowsPictureInPicturePlayback = true
            playerController.delegate = self
            playerController.player?.play()            
            self.present(playerController,animated:true,completion:nil)
            
        } else {
            CommonFunctions.showAlert(self, message: "Video corrupted", title: appName)
            
        }
    }
    
    @objc func didfinishplaying(note : NSNotification) {
        playerController.dismiss(animated: true,completion: nil)
//        let alertview = UIAlertController(title:"Finished",message:"Video Finished",preferredStyle: .alert)
//        alertview.addAction(UIAlertAction(title:"Ok",style: .default, handler: nil))
//        self.present(alertview,animated:true,completion: nil)
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let currentviewController =  navigationController?.visibleViewController
        
        if currentviewController != playerViewController {
            currentviewController?.present(playerViewController,animated: true,completion:nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexPath = NSIndexPath(row: indexPath.row, section: 0)
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cell.featuredReviewImgView
        }
        present(ImageViewerController(configuration: configuration), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> () {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        pageControl.currentPage = Int(pageNumber)
    }
    
    //
    //After you've received data from server or you are ready with the datasource, call this method. Magic!
    func reloadCollectionView() {
        self.myCampImgesCollView.reloadData()
        
        // Invalidating timer for safety reasons
        self.timer?.invalidate()
        
        // Below, for each 3.5 seconds MyViewController's 'autoScrollImageSlider' would be fired
        self.timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(autoScrollImageSlider), userInfo: nil, repeats: true)
        
        //This will register the timer to the main run loop
        RunLoop.main.add(self.timer!, forMode: .commonModes)
        
    }
    
    @objc func autoScrollImageSlider() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let firstIndex = 0
                let lastIndex = 4
                
                let visibleIndices = self.myCampImgesCollView.indexPathsForVisibleItems
                let nextIndex = visibleIndices[0].row + 1
                
                let nextIndexPath: IndexPath = IndexPath.init(item: nextIndex, section: 0)
                let firstIndexPath: IndexPath = IndexPath.init(item: firstIndex, section: 0)
                
                if nextIndex > lastIndex {
                    self.myCampImgesCollView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
                    self.pageControl.currentPage = (firstIndexPath.row)
                    
                } else {
                    self.myCampImgesCollView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                    self.pageControl.currentPage = (nextIndexPath.row)
                    
                }
            }
        }
    }
}

//MARK:- Table View Delegate
extension CampDescriptionVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.descriptionTableView {
            return self.campDetailArr.count
        } else {
            return self.reviewsArr.count
        }
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.descriptionTableView {
            let cell = self.descriptionTableView.dequeueReusableCell(withIdentifier: "CampDetailsTableViewCell", for: indexPath) as! CampDetailsTableViewCell
           
            cell.campTypeLbl.text = (self.campDetailArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "key") as? String
            
            if (self.campDetailArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "value") as? String == "" {
               // cell.campInfoLbl.textColor = UIColor.white
                cell.campInfoLbl.text = "-"
                
            } else {
                cell.campInfoLbl.textColor = UIColor(red: 110/255, green: 111/255, blue: 115/255, alpha: 1.0)
                cell.campInfoLbl.text = (self.campDetailArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "value") as? String
                
            }
            return cell
            
        } else {
            let cell = self.reviewTableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
            
            if let name = (self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as? String {
                cell.reviewGivenNameLbl.text = name
                
            } else {
                cell.reviewGivenNameLbl.text = ""
                
            }
            
            cell.reviewGivenUserImgView.sd_setShowActivityIndicatorView(true)
            cell.reviewGivenUserImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            if let img =  ((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
                cell.reviewGivenUserImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                    //
                }
            }
            
          //  cell.reviewGivenUserImgView.sd_setImage(with: URL(string: ((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String)!), placeholderImage: UIImage(named: ""))
            
            if !(((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewDate")) is NSNull) {
                cell.reviewGivenDateLbl.text! = convertDateFormater(((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewDate") as! String))
                
            }
         //   cell.reviewGivenDateLbl.text = (self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewDate") as? String
            cell.ratingView.rating = Double(String(describing: ((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewAverage"))!))!
            cell.reviewDescriptionLbl.text = (self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "description") as? String
            
            //add target
            cell.tapProfilePicBtn.tag = indexPath.row
            cell.tapProfilePicBtn.addTarget(self, action: #selector(tapProfilePicBtn(sender:)), for: .touchUpInside)
            
            return cell            
        }        
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == self.reviewTableView {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewDetailsVC") as! ReviewDetailsVC
            vc.campId = self.campId
            vc.reviewDeatils = (self.reviewsArr.object(at: indexPath.row) as! NSDictionary)
           
            vc.reviewId = (String(describing: ((self.reviewsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewId"))!))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CampDescriptionVc: UITextViewDelegate, UITextFieldDelegate  {   
    //MARK:- UItextView DElegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.abouseTxtVIew.text! == "Add reason"{
            self.abouseTxtVIew.text = ""
            self.abouseTxtVIew.textColor = UIColor.darkGray
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.abouseTxtVIew.text! == "" {
            self.abouseTxtVIew.text = "Add reason"
            self.abouseTxtVIew.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .darkGray
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneButtonTextView(_:)))
        doneButton.tintColor = UIColor.white
        let items:Array = [doneButton]
        toolbar.items = items
        
        if textView == self.abouseTxtVIew {
            textView.inputAccessoryView = toolbar
        }
        return true
    }
}

extension CampDescriptionVc: WKUIDelegate, UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.isHidden = false
        self.googleMapView.isHidden = false
        self.activityIndicator.startAnimating()
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.googleMapView.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.startAnimating()
        
    }
    
}
