//
//  RCGUISwitch.swift
//  RCG Personnel
//
//  Created by iFoxxy on 12.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGUISwitch: UISwitch {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.onTintColor = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0)
    }
}
