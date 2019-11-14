//
//  MarkerUserInfo.swift
//  XploreProject
//
//  Created by iMark_IOS on 23/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

protocol MapMarkerUserDelegate: class {
    func didTapViewProfileButton(data: NSDictionary)
}

class MarkerUserInfo: UIView {
    @IBOutlet weak var userImgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    
    weak var delegate: MapMarkerUserDelegate?
    var spotData: NSDictionary?
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapViewProfileButton(data: spotData!)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerUserInfo", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}
