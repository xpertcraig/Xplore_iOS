//
//  ReviewTableViewCell.swift
//  XploreProject
//
//  Created by iMark_IOS on 10/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {

    //MARK:- Iboutlets
    @IBOutlet weak var reviewGivenNameLbl: UILabel!
    @IBOutlet weak var reviewGivenUserImgView: UIImageViewCustomClass!
    @IBOutlet weak var reviewGivenDateLbl: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var reviewDescriptionLbl: UILabelCustomClass!
    
    @IBOutlet weak var tapProfilePicBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
