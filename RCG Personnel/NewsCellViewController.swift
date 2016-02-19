//
//  NewsCellViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 19.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class NewsCellView: UITableViewCell {
    
    @IBOutlet weak var newsCellImageView: UIImageView!
    
    @IBOutlet weak var dateDay: UILabel!
    @IBOutlet weak var dateMonthYear: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsAnnounce: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}