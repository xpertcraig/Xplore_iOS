//
//  PaymentHistoryTableViewCell.swift
//  XploreProject
//
//  Created by Dharmendra on 13/08/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var transactionAmount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
