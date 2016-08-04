//
//  SingleNewsCommentsFooterCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 05.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class SingleNewsCommentsFooterCell : UITableViewCell {
    
    var tapAction : (() -> Void)?
    
    @IBOutlet weak var showMoreButton: UIButton!
    
    @IBAction func showMoreButtonTouched(sender: AnyObject) {
        tapAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}