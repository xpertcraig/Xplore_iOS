//
//  MyProfileVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 26/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage
import SimpleImageViewer

class MyProfileVC: UIViewController, updateProfileDelegate {
    //MARK:- IbOutlets
    @IBOutlet weak var myProfileImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var savedCapsiteView: UIViewCustomClass!
    @IBOutlet weak var myCampsitView: UIViewCustomClass!
    @IBOutlet weak var messageView: UIViewCustomClass!
    @IBOutlet weak var myProfileScrollVIew: UIScrollView!
    @IBOutlet weak var addCampsiteView: UIViewCustomClass!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var ttlFollowers: UIButton!
    @IBOutlet weak var ttlFolowings: UIButton!
    
    //MARK:- Variable Declaration
    var myProfileDict: NSDictionary = [:]
    var commonDataViewModel = CommonUseViewModel()
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myProfileScrollVIew.isHidden = true
        
        self.savedCapsiteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSavedCampSiteView)))
        self.myCampsitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMyCampSiteView)))
        self.messageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMessageView)))
        self.addCampsiteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddCampsiteView)))
        //
        
        self.ttlFollowers.titleLabel?.textAlignment = .center
        self.ttlFolowings.titleLabel?.textAlignment = .center
        let followTitleStr = "\(Singleton.sharedInstance.followerListArr.count)\nFollowers"
        
        self.ttlFollowers.setTitle(followTitleStr, for: .normal)
        self.ttlFolowings.setTitle("\(Singleton.sharedInstance.followingListArr.count)\nFollowing ", for: .normal)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        if Singleton.sharedInstance.myProfileDict.count > 0 {
            self.setInfo(retValue: Singleton.sharedInstance.myProfileDict)
            
        }
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        
        //api
        self.callAPI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        self.tabBarController?.tabBar.isHidden = false
        
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
    
    //MARK:- Function Definition
    func setInfo(retValue: NSDictionary) {
        DataManager.name = String(describing: (retValue.value(forKey: "name"))!)
        DataManager.contactNum = String(describing: (retValue.value(forKey: "phoneNumber"))!) as AnyObject
        DataManager.profileImage = String(describing: (retValue.value(forKey: "profileImage"))!) as AnyObject
        
        self.myProfileDict = retValue
        
        self.userNameLbl.text! = retValue.value(forKey: "name") as! String
        self.userEmailLbl.text! = retValue.value(forKey: "email") as! String
        
        if let profileImg = (retValue.value(forKey: "profileImage") as? String) {
            
            self.myProfileImgView.sd_setShowActivityIndicatorView(true)
            self.myProfileImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            
            self.myProfileImgView.loadImageFromUrl(urlString: profileImg, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                //
            }
        }
        
        Database.database().reference().child("UsersProfile").child(DataManager.userId as! String).child("username").setValue(self.userNameLbl.text!)
        Database.database().reference().child("UsersProfile").child(DataManager.userId as! String).child("userProfileImage").setValue(String(describing: (DataManager.profileImage)))
        self.myProfileScrollVIew.isHidden = false
        
    }
    
    func updateProfile(dict: NSDictionary) {
       // print(dict)
        self.userNameLbl.text! = dict.value(forKey: "name") as! String
        self.myProfileImgView.image = dict.value(forKey: "profileImage") as? UIImage
    }
    
    func callAPI() {
        let downloadGroup = DispatchGroup()
        if connectivity.isConnectedToInternet() {
            downloadGroup.enter()
            self.profilesAPIHit()
            downloadGroup.leave()
           
            downloadGroup.enter()
            self.commonDataViewModel.getFollowerListFromAPI(actionUrl: apiUrl.followerListApiStr.rawValue) { (rMsg) in
                self.ttlFollowers.setTitle("\(Singleton.sharedInstance.followerListArr.count)\nFollowers", for: .normal)
            }
            downloadGroup.leave()
        
            downloadGroup.enter()
            self.commonDataViewModel.getFollowerListFromAPI(actionUrl: apiUrl.followingListApiStr.rawValue) { (rMsg) in
                self.ttlFolowings.setTitle("\(Singleton.sharedInstance.followingListArr.count)\nFollowing", for: .normal)
            }
            downloadGroup.leave()
            
            downloadGroup.notify(queue: DispatchQueue.main) {
                self.ttlFollowers.setTitle("\(Singleton.sharedInstance.followerListArr.count)\nFollowers", for: .normal)
                self.ttlFolowings.setTitle("\(Singleton.sharedInstance.followingListArr.count)\nFollowing", for: .normal)
            }
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
        }
    }
    
    //MARK:- Api's Hit
    func profilesAPIHit(){
        if (Singleton.sharedInstance.myProfileDict.count == 0 && userDefault.value(forKey: myProfileStr) == nil){
            applicationDelegate.startProgressView(view: self.view)
            
        }        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "myProfile.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    let retValue = dict["result"] as! NSDictionary
                    Singleton.sharedInstance.myProfileDict = retValue
                    
                    self.setInfo(retValue: retValue)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            }
        }
    }
    
    @objc func tapSavedCampSiteView() {
        self.tabBarController?.selectedIndex = 2
        Singleton.sharedInstance.fromMyProfile = true
        if Singleton.sharedInstance.fromMyProfileTabbarIndex == 2 {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func tapMyCampSiteView() {
        self.tabBarController?.selectedIndex = 3
        Singleton.sharedInstance.fromMyProfile = true
        if Singleton.sharedInstance.fromMyProfileTabbarIndex == 3 {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func tapMessageView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatListingVC") as! ChatListingVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func tapAddCampsiteView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK:- Button Action
    @IBAction func tapProfileImgView(_ sender: Any) {
        self.view.endEditing(true)
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.myProfileImgView
            
        }
        present(ImageViewerController(configuration: configuration), animated: true)
    }
    
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapAddCampsiteBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapEditProfileBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        vc.myProfileInfoDict = self.myProfileDict
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapFollowerBtn(_ sender: Any) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowingVC") as! FollowFollowingVC
        vc.switchType = switchTypeStr.showFollower.rawValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapFollowingsBtn(_ sender: Any) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowFollowingVC") as! FollowFollowingVC
        vc.switchType = switchTypeStr.showFollowings.rawValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIImagePickerController {
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return nil
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
