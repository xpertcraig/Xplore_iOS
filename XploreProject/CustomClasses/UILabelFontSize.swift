//
//  UILabelFontSize.swift
//  SureshotGPS
//
//  Created by Piyush Gupta on 9/12/16.
//  Copyright © 2016 Piyush Gupta. All rights reserved.
//

import UIKit

class UILabelFontSize: UILabel {
    
    override func awakeFromNib() {
        changeSize()
    }
    
    fileprivate func changeSize() {
        let currentSize = self.font.pointSize
        if (UIScreen.main.bounds.height != 736){
            self.font = self.font.withSize(currentSize-3)
        }
    }
}

