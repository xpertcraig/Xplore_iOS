//
//  CustomCell.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Cosmos

class CustomCell: UICollectionViewCell {
  
    @IBOutlet weak var featuredReviewImgView: UIImageView!
    @IBOutlet weak var imagLocNameLbl: UILabel!    
    @IBOutlet weak var ttlRatingLbl: UILabel!
    @IBOutlet weak var ttlReviewLbl: UILabel!
    @IBOutlet weak var reviewFeaturedStarView: CosmosView!
    @IBOutlet weak var locationAddressLbl: UILabel!
    
    @IBOutlet weak var userProfileAndNameView: UIView!
    @IBOutlet weak var autherImgView: UIImageViewCustomClass!
    @IBOutlet weak var autherNameLbl: UILabel!
    @IBOutlet weak var tapProfilePicBtn: UIButton!
    
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var favBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var viewAll: UIButton!
    
    @IBOutlet weak var removeDraftBtn: UIButton!    
    
    @IBOutlet weak var addressTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editDraftBtn: UIButton!
    @IBOutlet weak var editPencilImgView: UIImageView!
    
    @IBOutlet weak var numberOfCellLbl: UILabel!
    
    @IBOutlet weak var showImgBtn: UIButton!
    
    @IBOutlet weak var noImgLbl: UILabel!
    
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var followUnfollowBtn: UIButtonCustomClass!
    @IBOutlet weak var shareCampBtn: UIButton!
    
    
    override func awakeFromNib() {
        self.gradientView.gradientBackground(from: UIColor.white.withAlphaComponent(0.0), to: UIColor.white.withAlphaComponent(0.1), to: UIColor.white.withAlphaComponent(0.2), to: UIColor.black.withAlphaComponent(0.2), to: UIColor.black.withAlphaComponent(1.0), direction: .topToBottom)
       
    }
}
