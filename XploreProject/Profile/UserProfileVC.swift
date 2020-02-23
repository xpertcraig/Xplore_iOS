//
//  UserProfileVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 23/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserProfileVC: UIViewController {

    //MARK:- IbOutlets
    @IBOutlet weak var myProfileScrollVIew: UIScrollView!    
    @IBOutlet weak var myProfileImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var CampsitView: UIViewCustomClass!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variable Declaration
    var userInfoDict: NSDictionary = [:]
    var chatUnitId:String = ""
    var userId: String = ""
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.CampsitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCampSiteView)))
        
      //  print(userInfoDict)
        
        //set profile
        self.setUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definition
    func setUserProfile() {
      //  print(userInfoDict)
      
        self.myProfileImgView.sd_setShowActivityIndicatorView(true)
        self.myProfileImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        self.myProfileImgView.sd_setImage(with: URL(string: String(describing: userInfoDict.value(forKey: "profileImage")!)), placeholderImage: UIImage(named: ""))
        
        if let name = userInfoDict.value(forKey: "name") as? String {
            self.userNameLbl.text =  name
            self.userId = (String(describing: (self.userInfoDict.value(forKey: "userId"))!))
            
        } else if let name = userInfoDict.value(forKey: "authorName") as? String {
            self.userNameLbl.text =  name
            self.userId = (String(describing: (self.userInfoDict.value(forKey: "campAuthor"))!))
        }
    }
    
    @objc func tapCampSiteView() {
     //   print(userInfoDict)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FeaturedVc") as! FeaturedVc
        vc.comeFrom = myProfile
        vc.userId = self.userId
        
        if let name: String = self.userInfoDict["authorName"] as? String {
            vc.autherInfo.updateValue(name, forKey: "autherName")
            
        }
        if let img: String = self.userInfoDict["profileImage"] as? String {
            vc.autherInfo.updateValue(img, forKey: "autherImg")
            
        }
        
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
    
    @IBAction func tapMessageBtn(_ sender: UIButton) {
        
        if String(describing: (DataManager.userId)) < self.userId {
            chatUnitId = self.userId + "-" + String(describing: (DataManager.userId))
            
        }
        else {
            chatUnitId = String(describing: (DataManager.userId)) + "-" + self.userId
            
        }
        
        let ref = Database.database().reference().child("Users").child(chatUnitId)
       // let childRef = ref.childByAutoId()
        
     //   let ref = Database.database().reference()
        
        ref/*.child("Users")*/.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("chatUnitId"){
                print("true rooms exist")
                
                
            }else{
                print("false room doesn't exist")
                
              //  ref.child("Users").child(self.chatUnitId)
                var otherUserName: String = ""
                var otherUserId: String = ""
                if let name = self.userInfoDict.value(forKey: "name") as? String {
                    otherUserName =  name
                    otherUserId = self.userId
                    
                    
                } else if let name = self.userInfoDict.value(forKey: "authorName") as? String {
                    otherUserName =  name
                    otherUserId = (String(describing: (self.userInfoDict.value(forKey: "campAuthor"))!))
                }
                
                let dictMessage: [String: Any] = ["othersUserId": otherUserId ,"otherUserProfileImage": (String(describing: (self.userInfoDict.value(forKey: "profileImage"))!)),"otherUsername": otherUserName, "userId": String(describing: (DataManager.userId)), "username": String(describing: (DataManager.name)) , "userProfileImage": String(describing: (DataManager.profileImage)) ,"last_msg": "", "last_msgTime": ""]
                
                
                ref.updateChildValues(dictMessage)
                
            }
        })
        
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if String(describing: (DataManager.userId)) == self.userId {
            chatVC.receiverId = String(describing: (userInfoDict.value(forKey: "othersUserId"))!)
            
        } else {
            chatVC.receiverId = self.userId
            
        }
        chatVC.comeFrom = "UserProfile"
       // chatVC.receiverId = (String(describing: (userInfoDict.value(forKey: "userId"))!))
        chatVC.userInfoDict = userInfoDict
        self.navigationController?.pushViewController(chatVC, animated: true)

//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
