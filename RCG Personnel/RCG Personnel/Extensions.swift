//
//  extensions.swift
//  RCG Personnel
//
//  Created by iFoxxy on 20.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

extension UIImage {
    var rounded: UIImage {
        let imageView = UIImageView(image: self);
        imageView.layer.cornerRadius = size.height < size.width  ? size.height/30 : size.width/30
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }
    static func image(withColor color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    func encodeToBase64() -> String? {
        let imageData = UIImagePNGRepresentation(self)
        if let encoded = imageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength) {
            return encoded
        }
        return nil
    }
}
extension NSDate {
    var gmc0: NSDate {
        let dateformatter = NSDateFormatter()
        dateformatter.timeZone = .localTimeZone()
        let seconds = -dateformatter.timeZone.secondsFromGMT
        return NSDate(timeInterval: Double(seconds), sinceDate: self)
    }
}

extension String {
    ///Converts string to DD.MM.YYYY format
    var formatedDate: String {
        
        if let doubleSelf = Double(self) {
            let timeinterval : NSTimeInterval = doubleSelf/1000
            let dateObject = NSDate(timeIntervalSince1970: timeinterval)
        
            let dateformatter = NSDateFormatter()
            dateformatter.timeZone = .localTimeZone()
            dateformatter.dateFormat = "dd.MM.YYYY"
            return dateformatter.stringFromDate(dateObject);
        }
        else {
            return ""
        }
    }
    ///Converts string to DD.MM.YY format
    var formatedDateDDMMYY: String {
        let timeinterval : NSTimeInterval = Double(self)!/1000
        let dateObject = NSDate(timeIntervalSince1970: timeinterval)
        let dateformatter = NSDateFormatter();
        dateformatter.timeZone = .localTimeZone();
        dateformatter.dateFormat = "dd.MM.YY"
        return dateformatter.stringFromDate(dateObject);
    }
    ///Returns Day from String in DD.MM.YYYY format
    var dayFromDdMmYyyy: String? {
        if let index = self.rangeOfString(".")?.startIndex {
            return self.substringWithRange(self.startIndex ..< index)
        } else {
            return nil
        }
    }
    ///Returns Month from String in DD.MM.YYYY format
    var monthYearFromDdMmYyyy: String? {
        if let index = self.rangeOfString(".")?.endIndex {
            return self.substringWithRange(index ..< self.endIndex)
        }
        else {
            return nil
        }
        
    }
    ///Returns BIGINT from String in dd.MM.yyyy format
    var timeIntervalSince1970FromDdMmYyyy: String? {
        let dateformatter = NSDateFormatter()
        //dateformatter.timeZone = .localTimeZone()
        dateformatter.dateFormat = "dd.MM.yyyy"
        if let date = dateformatter.dateFromString(self) {
            let newdate = String(IntMax(date.timeIntervalSince1970*1000))
            return newdate
        }
        else {
            return nil
        }
    }
    
    subscript (i: Int) -> String {
        if self.characters.count > i {
            return String(Array(arrayLiteral: self)[i])
        }
        return ""
    }
    
    func indexAt(theInt:Int)->String.Index {
        return self.startIndex.advancedBy(theInt)
    }
    
    func decodeUIImageFromBase64() -> UIImage? {
        if let data = NSData(base64EncodedString: self, options: .IgnoreUnknownCharacters) {
            if let decoded = UIImage(data: data) {
                return decoded
            }
        }
        return nil
    }
    
}

extension UIApplication {
    class func appName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    }
    
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
extension UIButton {
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(UIImage.image(withColor: color, size: bounds.size), forState: state)
    }
}


