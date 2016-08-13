//
//  AppDelegate.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import Alamofire
import VK_ios_sdk
import FBSDKLoginKit
import FBSDKCoreKit


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var deviceTokenString = ""
    var deviceTokenSent = false
    
    var appVersionOnServer = ""
    var versionChecked = false
    
    var userDataReceived = false
    
    var registeredForRemoteNotifications = false
    
    var pushManager = PushManager(handlers: [])
    private var reachability : Reachability!
    
    let user = User.sharedUser
    let userReceiver = UserReceiver()
    let authenticationManager = AuthenticationManager()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Временная папочка с дефаултсами
        print(NSTemporaryDirectory())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.checkForReachability(_:)), name: ReachabilityChangedNotification, object: nil);
        
        do {
            try
            self.reachability = Reachability.reachabilityForInternetConnection();
            try
            self.reachability.startNotifier()
        }
        catch {
            print(error)
        }
        
        setApplicationFontsAndColors()
        
        //App launch code
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //Optionally add to ensure your credentials are valid:
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in }
        
        
        /*if user.isAuthenticated {*/
            if let tabBarController = self.window?.rootViewController as? UITabBarController {
                pushManager = PushManager(handlers: [SingleNewsPushHandler(tabBar: tabBarController), SingleVacancyPushHandler(tabBar: tabBarController)])
            }
            //registerForPushNotifications()
            
            if let pushNotificationInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary! {
                handlePushWithPayload(pushNotificationInfo, mode: .Background)
            }
        /*}
        else {
            let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.presentViewController(rootViewController, animated: true, completion: nil)
        }*/
        
        
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        
        let isFacebookURL = url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return true
    }
    
    func checkForReachability(notification:NSNotification)
    {
        let networkReachability = notification.object as? Reachability;
        let remoteHostStatus = networkReachability?.currentReachabilityStatus
        
        if (remoteHostStatus == .NotReachable)
        {
            NSLog("Internet Not Reachable")
        }
        else
        {
            if remoteHostStatus == .ReachableViaWiFi {
                NSLog("Internet Reachable via Wifi")
            }
            else {
                NSLog("Internet Reachable")
            }
            if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
                registerForPushNotifications()
            }
            if !deviceTokenSent {
                if deviceTokenString != "" {
                    sendToken(deviceTokenString)
                }
            }
            if !user.isTokenChecked {
                if user.token != nil {
                    checkIfTokenIsValid({
                        self.userReceiver.getCurrentUser()
                    })
                }
            }
            if !versionChecked {
                getAppVersionFromServerAndShowAlertIfItDiffers()
            }
            
            
        }
    }
    
    func checkIfTokenIsValid(completion: () -> Void) {
        NSLog("TokenIsValidCheck. Started.")
        let headers = ["Authorization" : "Bearer " + user.token ?? ""]
        Alamofire.request(.GET, Constants.apiUrl + "api/v01/token/check", headers: headers)
            .responseData { response in
                switch response.result {
                case .Success:
                    if let responseData = response.data {
                        var jsonError: NSError?
                        let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                        let isAuthorized = json["authorized"]
                        if isAuthorized {
                            self.user.isAuthenticated = true
                            self.user.isTokenChecked = true
                            NSLog("TokenIsValidCheck. Done, result: Token is valid.")
                            completion()
                        }
                        else if !isAuthorized {
                            self.user.isAuthenticated = false
                            self.user.isTokenChecked = true
                            
                            NSLog("TokenIsValidCheck. Done, result: Token is not valid, isAuthenticated property set to false")
                        }
                    }
                    case .Failure:
                    NSLog("TokenIsValidCheck. Done, result: Request failed, see the description below.")
                    NSLog((response.result.error?.description)!)
                }}
    }
    
    func showNewVersionAvailableAlert() {
        let alertController = UIAlertController(title: "Доступна новая версия", message: "Загрузить из App Store?", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "Нет", style: .Default, handler: nil)
        let gotoItunesAction = UIAlertAction(title: "Загрузить", style: .Default) {(_) -> Void in
            let itunesURL = NSURL(string: Constants.appStoreUrl)
            UIApplication.sharedApplication().openURL(itunesURL!)
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(gotoItunesAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.window?.rootViewController!.presentViewController(alertController, animated: false, completion: nil)
        }
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if application.applicationState == .Active {
            handlePushWithPayload(userInfo, mode: .Foreground)
        }
        else if application.applicationState == .Inactive {
            handlePushWithPayload(userInfo, mode: .Background)
        }
            
    }
    
    func registerForPushNotifications() {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func handlePushWithPayload(payload: NSDictionary, mode: PushNotificationMode) {
        let notification = PushNotification(mode: mode, payload: payload)
        pushManager.handlePush(notification, sender: self)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        self.deviceTokenString = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        NSLog("%@", "Registration for Remote Notifications succeed: " + deviceTokenString)
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("%@", "Registration for Remote Notifications failed: " + error.description)
    }
    
    func setApplicationFontsAndColors() {
        //MARK: Setting application colors and fonts
        let navBarFont = UIFont(name: "Roboto-Regular", size: 17.0) ?? UIFont.systemFontOfSize(17.0)
        
        let navBar = UINavigationBar.appearance()
        let tabBar = UITabBar.appearance()
        navBar.barTintColor = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0)
        
        navBar.tintColor = UIColor.whiteColor()
        
        //Стиль заголовка
        navBar.titleTextAttributes = [NSFontAttributeName: navBarFont, NSForegroundColorAttributeName: UIColor.whiteColor()];
        
    }
    
    func sendToken(deviceTokenString: String) {
        
        let request = HTTPTask();
        let requestUrl = Constants.apiUrl + "api/v01/devices"
        let params: Dictionary<String,AnyObject> = ["token":deviceTokenString]
        
        request.POST(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                NSLog("error: " + err.localizedDescription)
            }
            else if let resp: AnyObject = response.responseObject {
                let responseData = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding)
                let requestedDataUnwrapped = responseData!;
                let jsonString = requestedDataUnwrapped;
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                    
                let json = JSON(jsonObject);
                    
                NSLog("%@", "Token successfully sent to the server with response: " + responseData!.description)
                self.deviceTokenSent = true
            }
        })
    }
    
    func getAppVersionFromServerAndShowAlertIfItDiffers() {
        let request = HTTPTask();
        let requestUrl = Constants.apiUrl + "api/v01/config"
        request.GET(requestUrl, parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                NSLog("%@", "Failed to get application version from server: " + err.localizedDescription)
            }
            else if let resp = response.responseObject as? NSData {
                let requestedData = NSString(data: resp, encoding: NSUTF8StringEncoding)
                let requestedDataUnwrapped = requestedData!;
                let jsonString = requestedDataUnwrapped;
                let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                
                let json = JSON(jsonObject);
                self.appVersionOnServer = json["versions"]["iPhone"]["num"] != nil ? json["versions"]["iPhone"]["num"].string! : ""
                NSLog("%@", "Got application version from server: " + self.appVersionOnServer)
                if self.appVersionOnServer != UIApplication.appVersion() {
                    NSLog("%@", "Application version is " + UIApplication.appVersion() + " and it differs from the version at server. (" + self.appVersionOnServer + ")")
                    self.showNewVersionAvailableAlert()
                }
                else {
                    NSLog("%@", "Application version is " + UIApplication.appVersion() + ". The same as version at server.")
                }
                
                self.versionChecked = true
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
            FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

