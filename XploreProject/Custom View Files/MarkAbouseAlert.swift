//
//  MarkAbouseAlert.swift
//  XploreProject
//
//  Created by iMark_IOS on 15/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MarkAbouseAlert: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var abouseTxtView: UITextView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MarkAbouseAlert", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
}
