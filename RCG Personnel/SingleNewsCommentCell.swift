//
//  SingleNewsCommentCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 07.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class SingleNewsCommentCell : UITableViewCell {
    
    
    @IBOutlet weak var commentUserPhoto: UIImageView!
    
    @IBOutlet weak var commentUserName: UILabel!
    
    @IBOutlet weak var commentText: UILabel!
    
    @IBOutlet weak var commentData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}