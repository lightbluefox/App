//
//  RCGTextFieldClass.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGTextFieldClass: UITextField {
    
    //override init() {
    // super.init()
    //}
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        let imageView = UIImageView();
        imageView.image = UIImage(named: "textRectangle");
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 14);
        imageView.contentMode = UIViewContentMode.Left;
        self.rightView = imageView;
        self.rightViewMode = UITextFieldViewMode.Always
    }
}
