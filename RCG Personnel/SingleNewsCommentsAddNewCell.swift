//
//  SingleNewsCommentsAddNewCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class SingleNewsCommentsAddNewCell : UITableViewCell {
    
    var tapAction: ((sender: RCGButton)  -> Void)?
    
    var tapCompletionHandler: ((success: Bool) -> Void)?
    
    
    @IBOutlet weak var addCommentTextView: UITextView!
    
    @IBOutlet weak var addCommentButton: RCGButton!
    
    @IBAction func addCommentButtonTouched(sender: RCGButton) {
        
        tapAction?(sender: sender)
        
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