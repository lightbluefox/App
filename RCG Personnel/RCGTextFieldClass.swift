//
//  RCGTextFieldClass.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGTextFieldClass: UITextField {
    
    var isValid = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        setRightImage()
        
        self.borderStyle = .RoundedRect
        self.font = UIFont.systemFontOfSize(14)
        self.textAlignment = .Left
    }
    ///В зависимости от значения isValid выставляется соответствующее изображение справа - с галочкой или без.
    func setRightImage() {
        let imageView = UIImageView();
        imageView.frame = CGRect(x: 0, y: 0, width: 27, height: 27);
        imageView.contentMode = UIViewContentMode.Left;
        if isValid {
            imageView.image = UIImage(named: "textRectangleOk");
        }
        else {
            imageView.image = UIImage(named: "textRectangle");
            
        }
        
        self.rightView = imageView;
        self.rightViewMode = UITextFieldViewMode.Always
    }
    
    func validate() {
        isValid = false
        if let text = self.text {
            if text != "" {
                isValid = true
            }
        }
        setRightImage()
    }
}
