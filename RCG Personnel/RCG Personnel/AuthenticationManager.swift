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

final class AuthenticationManager {

    var parentViewController: UIViewController?
    let vkAuthenticationHandler = VKAuthenticationHandler()
    let fbAuthenticationHandler = FBAuthenticationHandler()
    let nativeAuthenticationHandler = NativeAuthenticationHandler()
    
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ()) {
        switch method {
        
        case .Native(let login, let password):
            nativeAuthenticationHandler.performAuthentication(login: login, password: password, completion: completion)
        
        case .Social(.VKontakte):
            vkAuthenticationHandler.performAuthentication(nil) { [weak self] result in
                // TODO
            }
        
        case .Social(.Facebook):
            break   // TODO
        case .Social(.Twitter):
            break   // TODO
        }
    }
    
    func old_and_ugly_authenticate(authenticationType: AuthenticationType) {
        if authenticationType == .VK {
            NSLog("%@", "Trying to authenticate via Vkontakte.")
//            vkAuthenticationHandler.performAuthentication(self.parentViewController)
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
//            nativeAuthenticationHandler.performAuthentication(self.parentViewController)
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
    
    func requestNewPassword(for login: String, completionHandler: (success:Bool, result: String?) -> Void) {
        
        let requestUrl = Constants.apiUrl + "api/v01/users/recover"
        let params = ["login": login]
        
        Alamofire.request(.POST, requestUrl, parameters: params).responseString {
            response in
            switch response.result {
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                    if let error = json["error"].string {
                        if error == "wait" {
                            let remainingTime = json["time"].intValue
                            completionHandler(success: false, result: "Повторная отправка смс возможна через \(remainingTime) сек.")
                        }
                        else
                        {
                            completionHandler(success: false, result: error)
                        }
                    }
                    else {
                        completionHandler(success: true, result: nil)
                    }
                    
                }
            case .Failure(let err):
                completionHandler(success: false, result: err.description)
            }
            
        }
    }
    
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
                                    self.requestNewPassword(for: user.phone ?? "") {
                                        (success: Bool, result: String?) -> Void in
                                        if success {
                                            registerViewController?.dismissViewControllerAnimated(true, completion: nil)
                                        }
                                        else {
                                            registerViewController?.hudManager.showHUD("Ошибка", details: result, type: .Failure)
                                        }
                                    }
                                 }
                                /*registerViewController?.hudManager.hideHUD(hud!)
                                let alertAction = UIAlertAction(title: "Выслать", style: .Default) {(_) -> Void in
                                    //registerViewController?.dismissViewControllerAnimated(true) {() -> Void in
                                        
                                        //Запросить восстановление пароля /api/recover
                                                                                //registerViewController?.parentViewController?.showViewController(<#T##vc: UIViewController##UIViewController#>, sender: <#T##AnyObject?#>)
                                        //отобразить вью контроллер для восстановления пароля хотя мб достаточно отразить главный VC
                                    }
                                }*/
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

enum AuthenticationType {
    case VK //через ВК
    case FB //через фэйсбук
    case TW //через Твиттер
    case Native //через логин и пароль
}

enum AuthenticationMethod {
    case Native(login: String, password: String)
    case Social(SocialNetwork)
}

enum SocialNetwork {
    case VKontakte
    case Facebook
    case Twitter
}

enum AuthenticationResult {
    case Success
    /// Незарегистрированный социальный юзер
    case Unregistered(socialNetwork: SocialNetwork, socialToken: String)
    case Failure(NSError?)
}