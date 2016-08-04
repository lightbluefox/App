//
//  SingleNewsContentCell.swift
//  RCG Personnel
//
//  Created by iFoxxy on 02.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class SingleNewsContentCell: UITableViewCell {

    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDateDay: UILabel!
    
    @IBOutlet weak var newsDateMonthYear: UILabel!
    
    @IBOutlet weak var newsFullText: UILabel!
    
    @IBAction func shareButtonTouched(sender: AnyObject) {
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