//
//  NotificationTableViewCell.swift
//  XploreProject
//
//  Created by iMark_IOS on 17/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage

class NotificationTableViewCell: UITableViewCell {

    //MARK:- Iboutlets
    @IBOutlet weak var userImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var notificationTxtLbl: UILabel!
    @IBOutlet weak var notificationTimeLbl: UILabel!
    
    @IBOutlet weak var removeNotificationBtn: UIButton!
    
    @IBOutlet weak var unreadMsgView: UIViewCustomClass!
    @IBOutlet weak var unreadMsgCountLbl: UILabel!
    
    func cellConfig(indexV: NSDictionary) {
        self.unreadMsgView.isHidden = true
        if let uCount = indexV["unread_\(DataManager.userId)"] as? Int {
            if uCount != 0 {
                self.unreadMsgView.isHidden = false
                if uCount < 10 {
                    self.unreadMsgCountLbl.text! = "\(uCount)"
                } else {
                    self.unreadMsgCountLbl.text! = "\(9)+"
                }
            } else {
                self.unreadMsgView.isHidden = true
            }
        }
         if String(describing: (DataManager.userId)) == String(describing: (indexV.value(forKey: "userId"))!) {
            self.getUserInfo(userId: String(describing: (indexV.value(forKey: "othersUserId"))!), indexV: indexV)
        } else {
            self.getUserInfo(userId: String(describing: (indexV.value(forKey: "userId"))!), indexV: indexV)
        }
    }
    
    func getUserInfo(userId: String, indexV: NSDictionary) {
        let ref = Database.database().reference().child("UsersProfile")
        ref.child(userId).observe(.value, with: { (shot) in
            
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
          //      print(postDict)
                self.userNameLbl.text! = String(describing: postDict["username"]!)
                
                self.userImgView.sd_setShowActivityIndicatorView(true)
                self.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                if let img =  postDict["userProfileImage"] as? String {
                    self.userImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
                }
                
             //   self.userImgView.sd_setImage(with: URL(string: String(describing: postDict["userProfileImage"]!)), placeholderImage: UIImage(named: ""))
                
            } else {
              //  print(indexV)
                if userId == String(describing: (indexV.value(forKey: "userId"))!) {
                    self.userNameLbl.text! = String(describing: (indexV.value(forKey: "username"))!)
                    
                    self.userImgView.sd_setShowActivityIndicatorView(true)
                    self.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    if let img =  (indexV.value(forKey: "userProfileImage")) as? String {
                        self.userImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
                    }
                    
                  //  self.userImgView.sd_setImage(with: URL(string: String(describing: (indexV.value(forKey: "userProfileImage"))!)), placeholderImage: UIImage(named: ""))
                } else {
                    self.userNameLbl.text! = String(describing: (indexV.value(forKey: "otherUsername"))!)
                    
                    self.userImgView.sd_setShowActivityIndicatorView(true)
                    self.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    
                    if let img =  (indexV.value(forKey: "otherUserProfileImage")) as? String {
                        self.userImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
                    }
                  //  self.userImgView.sd_setImage(with: URL(string: String(describing: (indexV.value(forKey: "otherUserProfileImage"))!)), placeholderImage: UIImage(named: ""))
                }
            }
            self.notificationTxtLbl.text! = String(describing: (indexV.value(forKey: "last_msg"))!)
            if (String(describing: (indexV.value(forKey: "last_msgTime"))!)) != "" {
                self.notificationTimeLbl.text! = CommonFunctions.changeUNXTimeStampToTIme(recUnxTimeStamp: (Double(String(describing: (indexV.value(forKey: "last_msgTime"))!))!))
                
            }
        })
    }
}
