//
//  LoginViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController {
    
    var authenticationManager = AuthenticationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.authenticationManager.parentViewController = self
    }
    
    @IBAction func loginTW(sender: AnyObject) {
        authenticationManager.authenticate(.TW)
    }
    
    @IBAction func loginFB(sender: AnyObject) {
        authenticationManager.authenticate(.FB)
    }
    
    @IBAction func loginVK(sender: UIButton) {
        authenticationManager.authenticate(.VK)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}