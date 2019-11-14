//
//  CustomStatusbar.swift
//  PAYGESS
//
//  Created by shikha kochar on 02/02/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class CustomStatusbar: UILabel {
    override func awakeFromNib() {
        changeSize()
    }
    
    fileprivate func changeSize() {
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
        {
            let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)
            self.frame.size.height = 44;
            self .addConstraint(heightConstraint)
            self.updateConstraints()
            self.layoutIfNeeded()
        }
        else
        {
            let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
            self.frame.size.height = 20;
            self .addConstraint(heightConstraint)
            self.updateConstraints()
            self.layoutIfNeeded()
        }
    }
}
