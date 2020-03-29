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

class MyProfileVC: UIViewController, updateProfileDelegate {
    //MARK:- IbOutlets
    @IBOutlet weak var myProfileImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userEmailLbl: UILabel!
    
    @IBOutlet weak var savedCapsiteView: UIViewCustomClass!
    @IBOutlet weak var myCampsitView: UIViewCustomClass!
    @IBOutlet weak var messageView: UIViewCustomClass!
    @IBOutlet weak var myProfileScrollVIew: UIScrollView!
    @IBOutlet weak var addCampsiteView: UIViewCustomClass!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variable Declaration
    var myProfileDict: NSDictionary = [:]
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.myProfileScrollVIew.isHidden = true
        
        self.savedCapsiteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSavedCampSiteView)))
        self.myCampsitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMyCampSiteView)))
        self.messageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapMessageView)))
        self.addCampsiteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAddCampsiteView)))
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        if Singleton.sharedInstance.myProfileDict.count > 0 {
            self.setInfo(retValue: Singleton.sharedInstance.myProfileDict)
            
        }
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        //api
        self.callAPI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definition
    func setInfo(retValue: NSDictionary) {
        DataManager.name = String(describing: (retValue.value(forKey: "name"))!) as AnyObject
        DataManager.contactNum = String(describing: (retValue.value(forKey: "phoneNumber"))!) as AnyObject
        DataManager.profileImage = String(describing: (retValue.value(forKey: "profileImage"))!) as AnyObject
        
        self.myProfileDict = retValue
        
        self.userNameLbl.text! = retValue.value(forKey: "name") as! String
        self.userEmailLbl.text! = retValue.value(forKey: "email") as! String
        
        if let profileImg = (retValue.value(forKey: "profileImage") as? String) {
            
            self.myProfileImgView.sd_setShowActivityIndicatorView(true)
            self.myProfileImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            self.myProfileImgView.sd_setImage(with: URL(string: profileImg), placeholderImage: UIImage(named: ""))
            
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
        if connectivity.isConnectedToInternet() {
            self.profilesAPIHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
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
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    @objc func tapSavedCampSiteView() {
        let tabbbar = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
        tabbbar.selectedIndex = 2
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "savedCompositeVc") as! savedCompositeVc
        vc.comeFrom = myProfile
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func tapMyCampSiteView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyCampsiteVc") as! MyCampsiteVc
        vc.comeFrom = myProfile
        self.navigationController?.pushViewController(vc, animated: true)
        
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
}

extension UIImagePickerController {
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return nil
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
}
