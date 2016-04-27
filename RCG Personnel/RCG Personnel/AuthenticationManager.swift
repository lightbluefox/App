//
//  AuthorizationManager.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import VK_ios_sdk

enum AuthenticationType {
    case VK //через ВК
    case FB //через фэйсбук
    case TW //через Твиттер
    case Native //через логин и пароль
}

class AuthenticationManager: NSObject {
    
    var parentViewController: UIViewController?
    
    func authenticate(authenticationType: AuthenticationType) {
        if authenticationType == .VK {
            NSLog("%@", "Trying to authenticate via Vkontakte.")
            VKAuthenticationHandler().performAuthentication(self.parentViewController)
        }
        
        else if authenticationType == .FB {
            NSLog("%@", "Trying to authenticate via Facebook.")
        }
            
        else if authenticationType == .TW {
            NSLog("%@", "Trying to authenticate via Twitter.")
        }
        
        else if authenticationType == .Native {
            NSLog("%@", "Trying to authenticate via login and password.")
        }
    }
    
    func logoff(tabBarController: UITabBarController) {
        //Ребилд стэка навигации, чтобы все контроллеры были в исходном положении
        //Презентовать LoginViewController
        if  let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as? LoginViewController {
            if let newsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("News") as? NewsViewController {
                if let vacsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Vacancies") as? VacanciesViewController {
                    if let navController = tabBarController.viewControllers?.first as? UINavigationController {
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            //navController.pushViewController(singleNewsViewController, animated: false)
                            navController.setViewControllers([newsViewController, vacsViewController], animated: false)
                            tabBarController.selectedViewController = navController
                            navController.presentViewController(loginViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        //разлогиниться из приложения вк, фб, и тв
        VKAuthenticationHandler().performLogoff()
        //очистить nsdefaults
    }
}