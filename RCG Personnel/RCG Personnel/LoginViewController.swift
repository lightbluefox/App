//
//  LoginViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController, RegisterViewControllerDelegate {
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var code: UITextField!
    var hudManger = HUDManager()
    var authenticationManager = AuthenticationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.authenticationManager.parentViewController = self
        self.hudManger.parentViewController = self
    }
    
    @IBAction func textFieldEditingDidEnd(sender: RCGTextFieldClass) {
        sender.validate()
    }
    
    
    @IBAction func closeButton(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
        
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
    
    @IBAction func loginNative(sender: AnyObject) {
        if phone.text == "" || code.text == "" {
            hudManger.showHUD("Ошибка", details: "Введите номер телефона и код", type: .Failure)
        }
        else {
            authenticationManager.authenticate(.Native)
        }
    }
    
    @IBAction func registerButtonTouched(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerViewController = storyboard.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController {
            registerViewController.modalPresentationStyle = .OverFullScreen
            registerViewController.delegate = self
            self.showDetailViewController(registerViewController, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code.secureTextEntry = true
        code.keyboardType = .NumberPad
    }
    
    func didFinishRegistering(sender: RegisterViewController) {
        self.phone.text = sender.phoneNumber.text
        self.code.text = sender.validationCode
        print("Finished registering with: Phone \(phone.text) and code \(code.text). Authenticating now.")
        authenticationManager.parentViewController = self
        authenticationManager.authenticate(.Native)
    }
}