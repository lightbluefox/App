//
//  SingleVacancyPushHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 17.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class SingleVacancyPushHandler: BasePushHandler {
    
    override func supportedFeatureName() -> String {
        return "singlevacancy"
    }
    
    override func doHandleNotification(notification: PushNotification) {
        let featureName = notification.payload["feature"] as! String
        if notification.mode == .Background {
            NSLog("%@", "Remote notification received in offline state. Feature: " + featureName)
            
            if featureName == "singlevacancy" {
                let guid = notification.payload["guid"] as! String
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let singleVacancyViewController = storyboard.instantiateViewControllerWithIdentifier("SingleVacancy") as? SingleVacancyViewController {
                    singleVacancyViewController.vacGuid = guid
                    if let navController = self.tabBar.viewControllers?[1] as? UINavigationController {
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            singleVacancyViewController.parentViewController?.navigationItem.backBarButtonItem?.title = ""
                            navController.pushViewController(singleVacancyViewController, animated: false)
                            self.tabBar.selectedViewController = navController
                        }
                    }
                }
            }
        }
        else if notification.mode == .Foreground {
            let featureName = notification.payload["feature"] as! String
            NSLog("%@", "Remote notification received in active state. Feature: " + featureName)
        }
    }
}