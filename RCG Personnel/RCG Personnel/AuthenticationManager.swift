//
//  AuthorizationManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import VK_ios_sdk
import Alamofire
import SwiftyJSON

final class AuthenticationManager {

    var parentViewController: UIViewController? {
        didSet {
            vkAuthenticationService.parentViewController = parentViewController
            fbAuthenticationService.parentViewController = parentViewController
        }
    }
    
    private let vkAuthenticationService = VKAuthenticationService()
    private let fbAuthenticationService = FBAuthenticationService()
    private let twitterAuthenticationService = TwitterAuthenticationService()
    
    func authenticate(method: AuthenticationMethod, completion: AuthenticationResult -> ()) {
        switch method {
        case .Native:
            sendAuthenticationRequest(method, socialToken: nil, tokenSecret: nil, completion: completion)
        case .Social(.VKontakte):
            vkAuthenticationService.performAuthentication { [weak self] result in
                self?.handleSocialAuthenticationResult(result, method: method, completion: completion)
            }
        case .Social(.Facebook):
            fbAuthenticationService.performAuthentication { [weak self] result in
                self?.handleSocialAuthenticationResult(result, method: method, completion: completion)
            }
        case .Social(.Twitter):
            twitterAuthenticationService.performAuthentication { [weak self] result in
                switch result {
                case .Success(let token, let tokenSecret):
                    debugPrint("token = \(token), tokenSecret = \(tokenSecret)")
                    self?.sendAuthenticationRequest(method, socialToken: token, tokenSecret: tokenSecret, completion: completion)
                case .Failure(let error):
                    completion(.Failure(error))
                }
            }
        }
    }
    
    func authenticate(socialNetwork: SocialNetwork, token: String, tokenSecret: String?, completion: AuthenticationResult -> ()) {
        sendAuthenticationRequest(.Social(socialNetwork), socialToken: token, tokenSecret: tokenSecret, completion: completion)
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
        vkAuthenticationService.performLogoff()
        fbAuthenticationService.performLogoff()
        twitterAuthenticationService.performLogoff()
        
        //очистить все из дефаултсов (там хранится токен)
        clearUserTokenFromDefaults()
        
        //заполнить дефолтными значениями sharedUser'а
        clearSharedUser()
        
    }
    private func clearUserTokenFromDefaults() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(NSUserDefaultsKeys.tokenKey)
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
                        else if error == "user unconfirmed" {
                            completionHandler(success: false, result: "Пользователь не подтвержден. Пройдите повторную регистрацию.")
                        }
                        else if error == "no such user" {
                            completionHandler(success: false, result: "Нет пользователя с таким телефоном.")
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
    
    func registerNewUser(
        parentViewController: UIViewController,
        user: User,
        socialNetwork: SocialNetwork?,
        socialToken: String?,
        tokenSecret: String?)
    {
        /*1. post /api/users/
        success: if already exists, alert
        if not, openPhoneConfirmationDialog(Phone)
         */
        let registerViewController = parentViewController as? RegisterViewController
        let hud = registerViewController?.hudManager.showHUD("Отправляем...", details: nil, type: .Processing)
        let requestURL = Constants.apiUrl + "api/v01/users"
        
        //Параметры только так, т.к. их много и XCODE зависает при индексации, ломает автокомплит и вообще плохо себя ведет =(
        //var params = ["":""]
        var params : [String: AnyObject] = [
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
        params.updateValue(user.height ?? 0, forKey: "height")
        params.updateValue(user.size ?? 0, forKey: "clothesSize")
        params.updateValue(user.birthDate ?? "", forKey: "birthDate")
        
        if let socialNetwork = socialNetwork, token = socialToken {
            for (key, value) in parametersForSocialNetwork(socialNetwork, token: token, tokenSecret: tokenSecret) {
                params[key] = value
            }
        }
        
        Alamofire.request(.POST, requestURL, parameters: params, encoding: .URL).responseJSON { response in
            
            let responseString = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
            debugPrint(responseString)
            
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
                                registerViewController?.hudManager.showAlertWithСancelButton("Номер уже зарегистрирован", message: "Выслать на него новый пароль?", cancelButtonTitle: "Нет", action: alertAction)
                            }
                            else if error == "wait" {
                                let remainingTime = json["time"].intValue
                                registerViewController?.hudManager.hideHUD(hud!)
                                registerViewController?.hudManager.showHUD("Ошибка", details: "Повторная отправка смс возможна через \(remainingTime) сек.", type: .Failure)
                                //completionHandler(success: false, result: "Повторная отправка смс возможна через \(remainingTime) сек.")
                            }
                            else {
                                registerViewController?.hudManager.hideHUD(hud!)
                                registerViewController?.hudManager.showHUD("Ошибка", details: error, type: .Failure)
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
    
    // MARK: - Sending request
    
    private let user = User.sharedUser
    private let userReceiver = UserReceiver()
    
    private func handleSocialAuthenticationResult(
        result: SocialAuthenticationResult,
        method: AuthenticationMethod,
        completion: AuthenticationResult -> ())
    {
        switch result {
        case .Success(let socialToken):
            sendAuthenticationRequest(method, socialToken: socialToken, tokenSecret: nil, completion: completion)
        case .Cancelled:
            completion(.Failure(nil))
        case .Failure(let error):
            completion(.Failure(error))
        }
    }
    
    private func sendAuthenticationRequest(
        method: AuthenticationMethod,
        socialToken: String?,
        tokenSecret: String?,
        completion: AuthenticationResult -> ())
    {
        let requestUrl = Constants.apiUrl + "api/v01/token"
        let params = parametersForAuthenticationMethod(method, socialToken: socialToken, tokenSecret: tokenSecret)
        Alamofire.request(.PUT, requestUrl, parameters: params).responseString {
            response in
            switch response.result {
            case .Failure(let err):
                debugPrint("error: " + err.localizedDescription)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(.Failure(err))
                }
            case .Success:
                if let responseData = response.data {
                    var jsonError: NSError?
                    let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                
                    if let error = json["error"].string {
                        print("error: " + error)
                        dispatch_async(dispatch_get_main_queue()) {
                            if error == "no such a user" {
                                completion(.UserNotFound(socialNetwork: method.socialNetwork, socialToken: socialToken, tokenSecret: tokenSecret))
                            }
                            else if error == "not allowed to login" {
                                completion(.NotAllowedToLogin(socialNetwork: method.socialNetwork, socialToken: socialToken, tokenSecret: tokenSecret))
                            }
                            else if error == "Login or password invalid!" {
                                completion(.IncorrectLoginOrPassword)
                            }
                            else {
                                completion(.Failure(nil))
                            }
                        }
                    } else if let userToken = json["token"].string {
                        self.user.token = userToken
                        self.user.isAuthenticated = true
                        self.user.isTokenChecked = true
                        print("Native authentication completed, user token: \(userToken)")
                        self.userReceiver.getCurrentUser()
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(.Success)
                        }
                    }
                }
            }
        }
    }
    
    func bindSocialNetwork(socialNetwork: SocialNetwork, completion: NSError? -> ()) {
        
        authenticateInSocialNetwork(
            socialNetwork,
            onSuccess: { [weak self] token, tokenSecret in
                guard let strongSelf = self else { return }
                
                let request = Alamofire.request(
                    .PUT,
                    Constants.apiUrl + "api/v01/users/current/social",
                    parameters: strongSelf.parametersForSocialNetwork(socialNetwork, token: token, tokenSecret: tokenSecret),
                    headers: ["Authorization" : "Bearer " + User.sharedUser.token ?? ""]
                )
                
                request.responseJSON { response in
                    debugPrint("\(response)")
                    if let responseDict = response.result.value as? [String: AnyObject] {
                        if let error = responseDict["error"] {
                            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error]))
                        } else {
                            self?.userReceiver.getCurrentUser()
                            completion(nil)
                        }
                    } else {
                        completion(response.result.error ?? NSError(domain: "", code: 0, userInfo: nil))
                    }
                }
            },
            onFailure: { error in
                debugPrint(error)
            }
        )
    }
    
    func unbindSocialNetwork(socialNetwork: SocialNetwork, completion: NSError? -> ()) {
        
        let request = Alamofire.request(
            .POST,
            Constants.apiUrl + "api/v01/users/current/social",
            parameters: ["type": stringTypeForSocialNetwork(socialNetwork)],
            headers: ["Authorization" : "Bearer " + User.sharedUser.token ?? ""]
        )
        
        request.responseJSON { [weak self] response in
            debugPrint("\(response)")
            if let responseDict = response.result.value as? [String: AnyObject] {
                if let error = responseDict["error"] {
                    completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error]))
                } else {
                    self?.userReceiver.getCurrentUser()
                    completion(nil)
                }
            } else {
                completion(response.result.error ?? NSError(domain: "", code: 0, userInfo: nil))
            }
        }

    }
    
    // TODO: вынести в отдельный SocialAuthService
    private func authenticateInSocialNetwork(
        socialNetwork: SocialNetwork,
        onSuccess: (token: String, tokenSecret: String?) -> (),
        onFailure: (error: NSError?) -> ())
    {
        switch socialNetwork {
        
        case .VKontakte:
            vkAuthenticationService.performAuthentication { result in
                switch result {
                case .Success(let token):
                    onSuccess(token: token, tokenSecret: nil)
                case .Cancelled:
                    onFailure(error: nil)
                case .Failure(let error):
                    onFailure(error: error)
                }
            }
            
        case .Facebook:
            fbAuthenticationService.performAuthentication { result in
                switch result {
                case .Success(let token):
                    onSuccess(token: token, tokenSecret: nil)
                case .Cancelled:
                    onFailure(error: nil)
                case .Failure(let error):
                    onFailure(error: error)
                }
            }
            
        case .Twitter:
            twitterAuthenticationService.performAuthentication { result in
                switch result {
                case .Success(let token, let tokenSecret):
                    onSuccess(token: token, tokenSecret: tokenSecret)
                case .Failure(let error):
                    onFailure(error: error)
                }
            }
        }
    }
    
    private func parametersForAuthenticationMethod(method: AuthenticationMethod, socialToken: String?, tokenSecret: String?)
        -> [String: AnyObject]
    {
        switch method {
        case .Native(let login, let password):
            return ["login": login, "password": password]
        case .Social(let socialNetwork):
            return parametersForSocialNetwork(socialNetwork, token: socialToken ?? "", tokenSecret: tokenSecret)
        }
    }
    
    private func parametersForSocialNetwork(socialNetwork: SocialNetwork, token: String, tokenSecret: String?)
        -> [String: AnyObject]
    {
        switch socialNetwork {
        case .VKontakte, .Facebook:
            return [
                "type": stringTypeForSocialNetwork(socialNetwork),
                "token": token
            ]
        case .Twitter:
            return [
                "type": stringTypeForSocialNetwork(socialNetwork),
                "token": [
                    "token": token,
                    "secret": tokenSecret ?? ""
                ]
            ]
        }
    }
    
    private func stringTypeForSocialNetwork(socialNetwork: SocialNetwork) -> String {
        switch socialNetwork {
        case .VKontakte:
            return "vk"
        case .Facebook:
            return "fb"
        case .Twitter:
            return "tw"
        }
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
    
    var socialNetwork: SocialNetwork? {
        if case .Social(let socialNetwork) = self {
            return socialNetwork
        } else {
            return nil
        }
    }
}

enum SocialNetwork {
    case VKontakte
    case Facebook
    case Twitter
}

enum AuthenticationResult {
    case Success
    case UserNotFound(socialNetwork: SocialNetwork?, socialToken: String?, tokenSecret: String?)
    case NotAllowedToLogin(socialNetwork: SocialNetwork?, socialToken: String?, tokenSecret: String?)
    case IncorrectLoginOrPassword
    case Failure(NSError?)
}
