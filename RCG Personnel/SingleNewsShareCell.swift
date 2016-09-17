//
//  SingleNewsShareCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.08.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleNewsShareCell : UITableViewCell {
    
    var fbTapAction : (() -> Void)?
    var vkTapAction : (() -> Void)?
    var twTapAction : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
