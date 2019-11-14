//
//  UILabelCustomClass.swift
//  SureshotGPS
//
//  Created by Piyush Gupta on 8/26/16.
//  Copyright © 2016 Piyush Gupta. All rights reserved.
//

import UIKit

@IBDesignable class UILabelCustomClass: UILabelFontSize {
    
    @IBInspectable var borderWidth:CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor:UIColor {
        get { return UIColor(cgColor: layer.borderColor!) }
        set { layer.borderColor = newValue.cgColor }
    }
    
    @IBInspectable var cornerRadius:CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
}

