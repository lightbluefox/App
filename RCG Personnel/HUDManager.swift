
//
//  HUDManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 09.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

enum HUDType {
    case Processing
    case Failure
    case Alert
    case Success
}

/// Shows different HUDs - processing, failure, alerts etc.
class HUDManager {
    
    var parentViewController: UIViewController?
    
    func showHUD(label: String?, details: String?, type: HUDType) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(parentViewController?.view, animated: true)
        
        switch type {
        case .Processing :
            hud.mode = MBProgressHUDMode.Indeterminate
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            hud.labelFont = UIFont(name: "Roboto Regular", size: 12)
            hud.labelText = label ?? ""
            return hud
        
        case .Failure :
            hud.mode = MBProgressHUDMode.CustomView
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            hud.labelFont = UIFont(name: "Roboto Regular", size: 12)
            hud.labelText = label ?? ""
            hud.detailsLabelText = details ?? ""
            hud.hide(true, afterDelay: 3)
            return hud
            
        case .Success :
            hud.mode = MBProgressHUDMode.CustomView
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            let imageView = UIImageView();
            imageView.image = UIImage(named: "checkmark");
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
            imageView.contentMode = UIViewContentMode.Center;
            hud.customView = imageView
            hud.hide(true, afterDelay: 3)
            return hud
        
        default :
            hud.mode = MBProgressHUDMode.CustomView
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            hud.labelFont = UIFont(name: "Roboto Regular", size: 12)
            hud.labelText = label ?? ""
            hud.detailsLabelText = details ?? ""
            hud.hide(true, afterDelay: 3)
            return hud
        }
        /*
        if type == .Processing {
            hud.mode = MBProgressHUDMode.Indeterminate
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            hud.labelFont = UIFont(name: "Roboto Regular", size: 12)
            hud.labelText = label
        }
        else if type == .Failure {
            hud.mode = MBProgressHUDMode.CustomView
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            hud.labelFont = UIFont(name: "Roboto Regular", size: 12)
            hud.labelText = label
            hud.detailsLabelText = details
            hud.hide(true, afterDelay: 3)
        }
        else if type == .Success {
            hud.mode = MBProgressHUDMode.CustomView
            hud.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            let imageView = UIImageView();
            imageView.image = UIImage(named: "checkmark");
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
            imageView.contentMode = UIViewContentMode.Center;
            hud.customView = imageView
            hud.hide(true, afterDelay: 3)
        }
        return hud*/
    }
    
    ///Shows alert with 2 buttons - cancelation and custom action
    ///
    ///**title** - Alert title
    ///
    ///**message** - Alert message
    ///
    ///**cancelButtonTitle** - title for default cancelation button
    ///
    ///**action** - custom UIAlertAction called on 2nd button tap
    
    func showAlertWithСancelButton(title: String, message: String, cancelButtonTitle: String, action: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil)

        alertController.addAction(defaultAction)
        alertController.addAction(action)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.parentViewController!.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func hideHUD(hud: MBProgressHUD) {
        hud.hide(true)
    }
    
    /*init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }*/
}