//
//  CustomInfoWindow.swift
//  XploreProject
//
//  Created by iMark_IOS on 16/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Cosmos

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
}

class CustomInfoWindow: UIView {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ttlRevierw: UILabel!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}

