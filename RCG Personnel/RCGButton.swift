//
//  RCGButton.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGButton: UIButton {
    
    var disabled = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let color = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0);
        self.tintColor = UIColor.whiteColor()
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal) //в сториборде сд
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        
        if let newTitleText = titleLabel?.text {
            titleLabel?.font = UIFont.systemFontOfSize(12)
            //titleLabel?.font = UIFont(name: "Roboto", size: 12)
            self.setTitle(newTitleText.uppercaseString, forState: .Normal)
        }
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, self.bounds)
    }
}
