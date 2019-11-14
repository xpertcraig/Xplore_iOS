//
//  MenuTableViewCell.swift
//  NewsNavi
//
//  Created by Apple on 12/02/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    //MARK :- SettingCell Outlets
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var settingSwitchBtn: UISwitch!
    @IBOutlet weak var settingArrowImg: UIImageView!
    
    //MArk:- Amenitiesll Cell Outlet
    @IBOutlet weak var selectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
}
