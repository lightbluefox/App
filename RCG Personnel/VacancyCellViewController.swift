//
//  VacancyCellViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class VacancyCellViewController: UITableViewCell {
 
    @IBOutlet weak var vacancyCellAnnounceImage: UIImageView!
    @IBOutlet weak var vacancyMaleImage: UIImageView!
    @IBOutlet weak var vacancyFemaleImage: UIImageView!
    
    @IBOutlet weak var vacancyDate: UILabel!
    @IBOutlet weak var vacancyTitle: UILabel!
    @IBOutlet weak var vacancyShortText: UILabel!
    @IBOutlet weak var vacancyMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
