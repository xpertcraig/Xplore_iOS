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
    
    func cellConfig(indexV: NSDictionary) {
         if String(describing: (DataManager.userId)) == String(describing: (indexV.value(forKey: "userId"))!) {
            self.getUserInfo(userId: String(describing: (indexV.value(forKey: "othersUserId"))!))
            
        } else {
            self.getUserInfo(userId: String(describing: (indexV.value(forKey: "userId"))!))
        }
        
        self.notificationTxtLbl.text! = String(describing: (indexV.value(forKey: "last_msg"))!)
        
        if (String(describing: (indexV.value(forKey: "last_msgTime"))!)) != "" {
            self.notificationTimeLbl.text! = CommonFunctions.changeUNXTimeStampToTIme(recUnxTimeStamp: (Double(String(describing: (indexV.value(forKey: "last_msgTime"))!))!))
            
        }
    }
    
    func getUserInfo(userId: String) {
        let ref = Database.database().reference().child("UsersProfile")
        ref.child(userId).observe(.value, with: { (shot) in
            
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                print(postDict)
                self.userNameLbl.text! = String(describing: postDict["username"]!)
                
                self.userImgView.sd_setShowActivityIndicatorView(true)
                self.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                self.userImgView.sd_setImage(with: URL(string: String(describing: postDict["userProfileImage"]!)), placeholderImage: UIImage(named: ""))
                
            }
        })
    }
}
