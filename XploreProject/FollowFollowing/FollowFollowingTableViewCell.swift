//
//  FollowFollowingTableViewCell.swift
//  XploreProject
//
//  Created by Dharmendra on 06/09/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class FollowFollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImg: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var followUnfollowRemoveBtn: UIButtonCustomClass!
    @IBOutlet weak var followUnfollowRemoveBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var profileImgBtn: UIButtonCustomClass!
    @IBOutlet weak var followYourFollowingBtn: UIButtonCustomClass!
    @IBOutlet weak var followYourFollowingBtnWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func cellConfig(indexDict: [String: Any], switchType: String) {
        self.userProfileImg.sd_setShowActivityIndicatorView(true)
        self.userProfileImg.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        
        if let img =  (indexDict["profileImage"] as? String) {
            self.userProfileImg.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                //
            }
        }
        if let name = (indexDict["name"] as? String) {
            self.userNameLbl.text! = name
        } else {
            self.userNameLbl.text! = ""
        }
        if let eMail = (indexDict["email"] as? String) {
            self.emailLbl.text! = eMail
        } else {
            self.emailLbl.text! = ""
        }
        
        if switchType == switchTypeStr.showFollower.rawValue {
            self.followUnfollowRemoveBtn.setTitle("Remove", for: .normal)
            self.followUnfollowRemoveBtn.setTitleColor(UIColor.black, for: .normal)
            self.followUnfollowRemoveBtn.layer.borderColor = UIColor.lightGray.cgColor
            self.followUnfollowRemoveBtnWidth.constant = 70
            
            print(Singleton.sharedInstance.followingListArr)
            print(indexDict)
            let IAmFollowingThisUser = Singleton.sharedInstance.followingListArr.filter { $0["userId"] as! Int == indexDict["userId"] as! Int }
            if IAmFollowingThisUser.count == 0 {
                self.followYourFollowingBtnWidth.constant = 55
                self.followYourFollowingBtn.isHidden = false
            } else {
                self.followYourFollowingBtnWidth.constant = 0
                self.followYourFollowingBtn.isHidden = true
            }
        } else {
            self.followUnfollowRemoveBtn.setTitle("Unfollow", for: .normal)
            self.followUnfollowRemoveBtn.setTitleColor(UIColor.appThemeGreenColor() , for: .normal)
            self.followUnfollowRemoveBtn.layer.borderColor = UIColor.appThemeGreenColor().cgColor
            self.followYourFollowingBtnWidth.constant = 0
            self.followYourFollowingBtn.isHidden = true
            self.followUnfollowRemoveBtnWidth.constant = 80
        }
    }
}
