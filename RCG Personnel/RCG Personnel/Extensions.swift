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
        return result
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
    var formatedDate: String {
        let timeinterval : NSTimeInterval = Double(self)!/1000
        let dateObject = NSDate(timeIntervalSince1970: timeinterval)
        
        let dateformatter = NSDateFormatter()
        dateformatter.timeZone = .localTimeZone()
        dateformatter.dateFormat = "dd.MM.YYYY"
        return dateformatter.stringFromDate(dateObject);
    }
    var formatedDateDDMMYY: String {
        let timeinterval : NSTimeInterval = Double(self)!/1000
        let dateObject = NSDate(timeIntervalSince1970: timeinterval)
        let dateformatter = NSDateFormatter();
        dateformatter.timeZone = .localTimeZone();
        dateformatter.dateFormat = "dd.MM.YY"
        return dateformatter.stringFromDate(dateObject);
    }
    var dayFromDdMmYyyy: String {
        return self.substringWithRange(self.startIndex..<(self.rangeOfString(".")?.startIndex)!)
    }
    var monthYearFromDdMmYyyy: String {
        return self.substringWithRange((self.rangeOfString(".")?.endIndex)!..<self.endIndex)
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


