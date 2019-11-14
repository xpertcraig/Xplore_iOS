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
    
    //Cell DescriptionCell    
}
