//
//  ReviewDetailsVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 19/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Cosmos

class ReviewDetailsVC: UIViewController {

    //MARK:- Iboutlets
    @IBOutlet weak var reviewDetailScrollView: UIScrollView!
    @IBOutlet weak var userImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var overAllStarRating: CosmosView!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var imagesCollView: UICollectionView!
    @IBOutlet weak var gallaryImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dateOfStayLbl: UILabel!
    @IBOutlet weak var lengthOfStayInNight: UILabel!
    
    @IBOutlet weak var scenicBeautiStarView: CosmosView!
    @IBOutlet weak var locationStarView: CosmosView!
    @IBOutlet weak var familyStarView: CosmosView!
    @IBOutlet weak var privacyStarView: CosmosView!
    @IBOutlet weak var clinessStarView: CosmosView!
    @IBOutlet weak var bugFactorStarView: CosmosView!
    
    @IBOutlet weak var addTipLbl: UILabel!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variable Declarations
    var campId: String = ""
    var reviewId: String = ""
    var reviewDeatils: NSDictionary = [:]
    var myGallaryImagesArr: NSArray = []
    
    //MARK:- Inbuild FUnctions
    override func viewDidLoad() {
        super.viewDidLoad()

        //setData
        self.setreviewDetails()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
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
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func callAPI() {
        if connectivity.isConnectedToInternet() {
         //   self.reviewDetailApi()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func setreviewDetails() {
       // print(reviewDeatils)
        self.userImgView.sd_setShowActivityIndicatorView(true)
        self.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        self.userImgView.sd_setImage(with: URL(string: (String(describing: (self.reviewDeatils.value(forKey: "profileImage"))!))), placeholderImage: UIImage(named: ""))
        self.userNameLbl.text = (String(describing: (self.reviewDeatils.value(forKey: "name"))!))
        
        if !((self.reviewDeatils.value(forKey: "reviewDate")) is NSNull) {
            self.dateLbl.text! = convertDateFormater((self.reviewDeatils.value(forKey: "reviewDate") as! String))
            
        }
       
        self.overAllStarRating.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "reviewAverage"))!))!
        self.descriptionLbl.text = self.reviewDeatils.value(forKey: "description") as? String
        
        self.myGallaryImagesArr = (self.reviewDeatils.value(forKey: "reviewImages") as! NSArray)
        if self.myGallaryImagesArr.count == 0 {
            self.gallaryImageViewHeight.constant = 0
            
        } else {
            self.gallaryImageViewHeight.constant = 128
            self.imagesCollView.reloadData()
            
        }
        
        self.dateOfStayLbl.text = self.reviewDeatils.value(forKey: "dateofStay") as? String
        self.lengthOfStayInNight.text = String(describing: (self.reviewDeatils.value(forKey: "lengthofStay"))!)
        
        self.scenicBeautiStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "scienicBeauty"))!))!
        self.locationStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "location"))!))!
        self.familyStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "familyFriendly"))!))!
        self.privacyStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "privacy"))!))!
        self.clinessStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "cleanliness"))!))!
        self.bugFactorStarView.rating = Double(String(describing: (self.reviewDeatils.value(forKey: "bugFactor"))!))!
        
        self.addTipLbl.text = self.reviewDeatils.value(forKey: "tip") as? String
    }
  
    //MARK:- Call APi's
//    func reviewDetailApi() {
//        applicationDelegate.startProgressView(view: self.view)
//
//        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "reviewDetails.php/?campId="+self.campId+"&userId="+String(describing: (DataManager.userId))+"&reviewId="+self.reviewId, onSuccess: { (responseData) in
//
//            applicationDelegate.dismissProgressView(view: self.view)
//
//            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
//                if (String(describing: (dict["success"])!)) == "1" {
//                    let retValues = (dict["result"]! as! NSArray)
//
//                    print(retValues)
//
//                } else {
//                    // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
//
//                }
//            }
//        }) { (error) in
//            applicationDelegate.dismissProgressView(view: self.view)
//            if connectivity.isConnectedToInternet() {
//                //  CommonFunctions.showAlert(self, message: serverError, title: appName)
//
//            } else {
//                CommonFunctions.showAlert(self, message: noInternet, title: appName)
//
//            }
//        }
//    }
    
    //MARK:-  Button Actions
    @IBAction func tapViewAllBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GalleryVc") as! GalleryVc
        vc.campId = self.campId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func profileAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapUserImgView(_ sender: UIButton) {
        if String(describing: (DataManager.userId)) == String(describing: (self.reviewDeatils.value(forKey: "userId"))!) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.userInfoDict = self.reviewDeatils
            self.navigationController?.pushViewController(vc, animated: true)

        }
//
//        print(self.reviewDeatils)
//
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
//        vc.userInfoDict = self.reviewDeatils
//        self.navigationController?.pushViewController(vc, animated: true)        
    }
}

extension ReviewDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myGallaryImagesArr.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.imagesCollView.dequeueReusableCell(withReuseIdentifier: "CampImagesCollectionViewCell", for: indexPath) as! CampImagesCollectionViewCell
        
        cell.campImgVIew.sd_setShowActivityIndicatorView(true)
        cell.campImgVIew.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        cell.campImgVIew.sd_setImage(with: URL(string: (String(describing:self.myGallaryImagesArr.object(at: indexPath.row)))), placeholderImage: UIImage(named: ""))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.width))
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}
