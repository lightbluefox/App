//
//  SingleNewsPushHandler.swift
//  RCG Personnel
//
//  Created by iFoxxy on 16.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleNewsPushHandler: BasePushHandler {

    override func supportedFeatureName() -> String {
        return "singlenews"
    }
    
    override func doHandleNotification(notification: PushNotification) {
        let featureName = notification.payload["feature"] as! String
        if notification.mode == .Background {
            NSLog("%@", "Remote notification received in offline state. Feature: " + featureName)
            
            if featureName == "singlenews" {
                let guid = notification.payload["guid"] as! String
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                if let singleNewsViewController = storyboard.instantiateViewControllerWithIdentifier("SingleNews") as? SingleNewsViewController {
                    singleNewsViewController.newsGuid = guid
                    if let newsViewController = storyboard.instantiateViewControllerWithIdentifier("News") as? NewsViewController {
                        if let navController = self.tabBar.viewControllers?.first as? UINavigationController {
                            dispatch_async(dispatch_get_main_queue()) {
                                //navController.pushViewController(singleNewsViewController, animated: false)
                                navController.setViewControllers([newsViewController, singleNewsViewController], animated: false)
                                self.tabBar.selectedViewController = navController
                            }
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
