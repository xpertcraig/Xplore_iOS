//
//  myCustomSlider.swift
//  XploreProject
//
//  Created by Dharmendra on 12/05/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit


public class myCustomSlider: UISlider {
    
    var label: UILabel
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: ()->String = { "" }
    
    required public init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
        
        //self.addTarget(self, action: Selector(("onValueChanged:")), for: .valueChanged)
        
    }
    func setup(){
        labelXMin = frame.origin.x + 16
        labelXMax = frame.origin.x + self.frame.width - 14
        var labelXOffset: CGFloat = labelXMax! - labelXMin!
        var valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        var valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        var valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        var labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos, y: self.frame.origin.y - 25, width: 200, height: 25)
       
        label.text = "\(String(Int(self.value.rounded()))) KM"
        self.superview!.addSubview(label)
        
    }
    func updateLabel(){
        label.text = labelText()
        var labelXOffset: CGFloat = labelXMax! - labelXMin!
        var valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        var valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        var valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        var labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width/2, y: self.frame.origin.y - 25, width: 200, height: 25)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.darkGray
        
        self.superview!.addSubview(label)
    }
    public override func layoutSubviews() {
        labelText = { "\(String(Int(self.value.rounded()))) KM"  }
        setup()
        updateLabel()
        super.layoutSubviews()
        super.layoutSubviews()
    }
    @objc func onValueChanged(sender: myCustomSlider){
        updateLabel()
    }
}
