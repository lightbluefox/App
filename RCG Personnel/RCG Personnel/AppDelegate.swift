//
//  AppDelegate.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tokenReceiveAttempts = 0
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: Push-notifications
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        //MARK: Setting application colors and fonts
        let navBarFont = UIFont(name: "Roboto-Regular", size: 17.0) ?? UIFont.systemFontOfSize(17.0);
        
        let navBar = UINavigationBar.appearance();
        let tabBar = UITabBar.appearance();
        navBar.barStyle = UIBarStyle.BlackOpaque;
        navBar.barTintColor = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 1.0);
        tabBar.barTintColor = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 1.0);
        tabBar.tintColor = UIColor.whiteColor();
        
        navBar.tintColor = UIColor.whiteColor() //цвет 
        
        //Стиль заголовка
        navBar.titleTextAttributes = [NSFontAttributeName: navBarFont, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        sendToken(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
        print(error.description)
    }
    
    func sendToken(deviceTokenString: String) {
        let request = HTTPTask();
        let requestUrl = Constants.apiUrl + "api/devices"
        let params: Dictionary<String,AnyObject> = ["token":deviceTokenString]
        tokenReceiveAttempts++
        
        request.POST(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                print("error: " + err.localizedDescription)
                if self.tokenReceiveAttempts < 5 {
                    let seconds = 10.0
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        //code perfomed with delay
                        print("Trying to send token again for the \(self.tokenReceiveAttempts) time")
                        self.sendToken(deviceTokenString)
                    })
                }
                else {
                    print("Stopped trying :(")
                }
                
            }
            else if let resp: AnyObject = response.responseObject {
                let responsedata = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding)
                print(responsedata)
            }
        })
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

