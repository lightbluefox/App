//
//  RCGPhoneTextFieldClass.swift
//  RCG Personnel
//
//  Created by iFoxxy on 10.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class RCGPhoneTextField : RCGTextFieldClass {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        //Чтобы запретить вставлять что-либо в поле с тел номером: http://stackoverflow.com/questions/29596043/how-to-disable-pasting-in-a-textfield-in-swift
        
        if action == "paste:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}