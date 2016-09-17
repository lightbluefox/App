//
//  SingelNewsCommentsHeaderCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 03.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleNewsCommentsHeaderCell : UITableViewCell {
    
    @IBOutlet weak var commentsCountText: UILabel!
    
    @IBOutlet weak var commentsCountNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
