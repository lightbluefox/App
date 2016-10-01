//
//  RCGPhoneTextFieldClass.swift
//  RCG Personnel
//
//  Created by iFoxxy on 10.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGPhoneTextField : RCGTextFieldClass {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        //Чтобы запретить вставлять что-либо в поле с тел номером: http://stackoverflow.com/questions/29596043/how-to-disable-pasting-in-a-textfield-in-swift
        
        return false
        /*if action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)*/
    }
    
    override func validate() {
        isValid = false
        if self.text?.characters.count == 16 {
            isValid = true
        }
        setRightImage()
    }
    
    ///Removes all characters but 0123456789 from text.
    ///
    ///This is done, because server works only with phones formatted as 79161112233
    func unmaskText() -> String? {
        
        if let unwrappedtext = self.text {
            let result = removeInvalidCharacters(unwrappedtext, charactersString: "0123456789")
            return result
        }
        else {
            return nil
        }
    }
    
    func removeInvalidCharacters(s: String, charactersString: String) -> String {
        let invalidCharactersSet = NSCharacterSet(charactersInString: charactersString).invertedSet
        return s.componentsSeparatedByCharactersInSet(invalidCharactersSet).joinWithSeparator("")
    }

}
