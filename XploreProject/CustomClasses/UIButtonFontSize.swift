//
//  UIButtonFontSize.swift
//  SureshotGPS
//
//  Created by Piyush Gupta on 9/12/16.
//  Copyright © 2016 Piyush Gupta. All rights reserved.
//

import UIKit

class UIButtonFontSize: UIButton {

    override func awakeFromNib() {
        changeSize()
        
    }
    
    fileprivate func changeSize() {
        let currentSize = self.titleLabel?.font.pointSize
        let fontDescriptor = self.titleLabel?.font.fontDescriptor
        if (UIScreen.main.bounds.height != 736){
            self.titleLabel?.font = UIFont(descriptor: fontDescriptor!, size: currentSize!-3)
        }
        
         }

   
/*
fileprivate func changeColor() {
    if (UserDefaults.standard.value(forKey: USER_DEFAULT_GENDER_Key)) as! String == "Female" {
        self.tintColor = UIColor(red: 0.9 , green: 0.2 , blue: 0.7 , alpha:1.0)
    }
    else{
        self.tintColor = UIColor(red: 60/255 , green: 177/255 , blue: 255/255 , alpha:1.0)
    }
    
}
*/


   }
