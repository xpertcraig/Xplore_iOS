//
//  NotificationTableViewCell.swift
//  XploreProject
//
//  Created by iMark_IOS on 17/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    //MARK:- Iboutlets
    @IBOutlet weak var userImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var notificationTxtLbl: UILabel!
    @IBOutlet weak var notificationTimeLbl: UILabel!
    
    @IBOutlet weak var removeNotificationBtn: UIButton!
}
