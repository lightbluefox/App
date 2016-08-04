//
//  AuthorizationManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import VK_ios_sdk
import Alamofire

enum AuthenticationType {
    case VK //через ВК
    case FB //через фэйсбук
    case TW //через Твиттер
    case Native //через логин и пароль
}

class AuthenticationManager: NSObject {

    var parentViewController: UIViewController?
    let vkAuthenticationHandler = VKAuthenticationHandler()
    let fbAuthenticationHandler = FBAuthenticationHandler()
    let nativeAuthenticationHandler = NativeAuthenticationHandler()
    
    func authenticate(authenticationType: AuthenticationType) {
        if authenticationType == .VK {
            NSLog("%@", "Trying to authenticate via Vkontakte.")
            vkAuthenticationHandler.performAuthentication(self.parentViewController)
        }
        
        else if authenticationType == .FB {
            NSLog("%@", "Trying to authenticate via Facebook.")
            //Тут где-то добавить dismissViewControllerAnimated!
            fbAuthenticationHandler.loginToFacebookWithSuccess({print("Authentication via Facebook succeed!")}, andFailure: { (error: NSError?) -> () in
                print("Authentication via Facebook failed!")
                print(error)
            })
        }
            
        else if authenticationType == .TW {
            NSLog("%@", "Trying to authenticate via Twitter.")
        }
        
        else if authenticationType == .Native {
            nativeAuthenticationHandler.performAuthentication(self.parentViewController)
            NSLog("%@", "Trying to authenticate via login and password.")
        }
    }
    
    func logoff(tabBarController: UITabBarController) {
        //Ребилд стэка навигации, чтобы все контроллеры были в исходном положении
        //Презентовать LoginViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if  let loginViewController = storyboard.instantiateViewControllerWithIdentifier("Login") as? LoginViewController {
            if let navController = tabBarController.viewControllers?[1] as? UINavigationController {
                dispatch_async(dispatch_get_main_queue()) {
                    if let vacsViewController = storyboard.instantiateViewControllerWithIdentifier("Vacancies") as? VacanciesViewController {
                            navController.setViewControllers([vacsViewController], animated: false)
                    }
                }
            }
            
            if let navController = tabBarController.viewControllers?[0] as? UINavigationController {
                dispatch_async(dispatch_get_main_queue()) {
                    if let newsViewController = storyboard.instantiateViewControllerWithIdentifier("News") as? NewsViewController {
                        navController.setViewControllers([newsViewController], animated: false)
                        tabBarController.selectedViewController = navController
                        navController.presentViewController(loginViewController, animated: true, completion: nil)
                    }
                }
            }
            
            if let navController = tabBarController.viewControllers?[2] as? UINavigationController {
                dispatch_async(dispatch_get_main_queue()) {
                    if let feedBackViewController = storyboard.instantiateViewControllerWithIdentifier("FeedBack") as? FeedBackViewController {
                        navController.setViewControllers([feedBackViewController], animated: false)
                    }
                }
            }
        }
        //разлогиниться из приложения вк, фб, и тв
        vkAuthenticationHandler.performLogoff()
        fbAuthenticationHandler.performLogoff()
        
        //очистить все из дефаултсов (там хранится токен)
        clearDefaults()
        
        //заполнить дефолтными значениями sharedUser'а
        clearSharedUser()
        
    }
    private func clearDefaults() {
        if let appDomain = NSBundle.mainBundle().bundleIdentifier {
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        }
    }
    
    func clearSharedUser() {
        User.sharedUser.isAuthenticated = false
        User.sharedUser.isTokenChecked = false
        User.sharedUser.birthDate = ""
        User.sharedUser.email = ""
        User.sharedUser.fbToken = ""
        User.sharedUser.firstName = ""
        User.sharedUser.gender = nil
        User.sharedUser.hasMedicalBook = false
        User.sharedUser.height = 0
        User.sharedUser.lastName = ""
        User.sharedUser.medicalBookNumber = ""
        User.sharedUser.metroStation = ""
        User.sharedUser.middleName = ""
        User.sharedUser.passportData = ""
        User.sharedUser.phone = ""
        User.sharedUser.photoUrl = ""
        User.sharedUser.size = 0
        User.sharedUser.twToken = ""
        User.sharedUser.vkToken = ""
    }
    /*func checkIfTokenIsValid(token: String) {
        let loginViewController = parentViewController as! LoginViewController
        
        let request = HTTPTask();
        let requestUrl = Constants.apiUrl + "api/v01/token"
        let params: Dictionary<String,AnyObject> = ["login":"admin", "password":"password"];
        //let params: Dictionary<String,AnyObject> = ["login":loginViewController.phone.text!, "password":parentViewController.code.text!];
        request.GET(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                print("error: " + err.localizedDescription)
            }
            else if let resp: AnyObject = response.responseObject {
                if let data = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding) {
                    let jsonData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    let jsonObject: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0))
                    let json = JSON(jsonObject)
                }
                NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: self)
            }
        })
    }*/
    
    func registerNewUser(parentViewController: UIViewController, user: User) {
        /*1. post /api/users/
        success: if already exists, alert
        if not, openPhoneConfirmationDialog(Phone)
         */
        let registerViewController = parentViewController as? RegisterViewController
        let hud = registerViewController?.hudManager.showHUD("Отправляем...", details: nil, type: .Processing)
        let requestURL = Constants.apiUrl + "api/v01/users"
        
        //Параметры только так, т.к. их много и XCODE зависает при индексации, ломает автокомплит и вообще плохо себя ведет =(
        //var params = ["":""]
        var params : Dictionary<String,AnyObject> = [
            "login": user.phone ?? "",
            "name": user.firstName ?? "",
            "surName": user.lastName ?? "",
            "fatherName": user.middleName ?? "",
            "email": user.email ?? ""
        ]
        params.updateValue(user.photoUrl ?? "", forKey: "avatar")
        params.updateValue(user.hasMedicalBook ?? false, forKey: "hasMedicalCard")
        params.updateValue(user.medicalBookNumber ?? "", forKey: "medicalCardNumber")
        params.updateValue(user.gender == .Male ? true : false, forKey: "ifMale")
        params.updateValue(user.metroStation ?? "", forKey: "subWayStation")
        params.updateValue(user.passportData ?? "", forKey: "passportData")
        params.updateValue(user.height ?? 0, forKey: "height")
        params.updateValue(user.size ?? 0, forKey: "clothesSize")
        params.updateValue(user.birthDate ?? "", forKey: "birthDate")
        
        Alamofire.request(.POST, requestURL, parameters: params, encoding: .URL).responseJSON {
            response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    if let login = json["login"].string {
                        //открыть форму подтверждения, передать на нее логин,
                        
                        registerViewController?.hudManager.hideHUD(hud!)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let validatePhoneViewController = storyboard.instantiateViewControllerWithIdentifier("ValidatePhone") as? ValidatePhoneViewController {
                            validatePhoneViewController.modalPresentationStyle = .OverFullScreen
                            validatePhoneViewController.phoneNumber = login
                            validatePhoneViewController.delegate = registerViewController
                            registerViewController?.showDetailViewController(validatePhoneViewController, sender: self)
                        }
                    }
                    else if let error = json ["error"].string {
                            if error == "empty login" {
                                registerViewController?.hudManager.hideHUD(hud!)
                                registerViewController?.hudManager.showHUD("Ошибка", details: error, type: .Failure)
                            }
                            else if error == "already exists" {
                                registerViewController?.hudManager.hideHUD(hud!)
                                let alertAction = UIAlertAction(title: "Выслать", style: .Default) {(_) -> Void in
                                    registerViewController?.dismissViewControllerAnimated(true) {() -> Void in
                                        //registerViewController?.parentViewController?.showViewController(<#T##vc: UIViewController##UIViewController#>, sender: <#T##AnyObject?#>)
                                        //отобразить вью контроллер для восстановления пароля хотя мб достаточно отразить главный VC
                                    }
                                }
                                registerViewController?.hudManager.showAlertWithСancelButton("Номер уже зарегистрирован", message: "Выслать на него новый пароль?", cancelButtonTitle: "Нет", action: alertAction)
                            }
                            else {
                                registerViewController?.hudManager.hideHUD(hud!)
                                registerViewController?.hudManager.showHUD("Упс", details: error, type: .Failure)
                            }
                    }

                }
            case .Failure(let error):
                registerViewController?.hudManager.hideHUD(hud!)
                registerViewController?.hudManager.showHUD("Ошибка", details: error.description, type: .Failure)
            }
            
        }
    }
    
    func confirmUserWithCode(parentViewController: UIViewController, user: User) {
        
    }
    
}