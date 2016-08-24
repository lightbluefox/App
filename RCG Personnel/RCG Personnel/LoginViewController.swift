//
//  LoginViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController, RegisterViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var phone: RCGPhoneTextField!
    @IBOutlet weak var code: RCGTextFieldClass!
    
    private let hudManger = HUDManager()
    private let authenticationManager = AuthenticationManager()
    
    private var oldNumber = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        authenticationManager.parentViewController = self
        hudManger.parentViewController = self
    }
    
    @IBAction func textFieldEditingDidEnd(sender: RCGTextFieldClass) {
        sender.validate()
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginTW(sender: AnyObject) {
        performAuthentication(.Social(.Twitter))
    }
    
    @IBAction func loginFB(sender: AnyObject) {
        performAuthentication(.Social(.Facebook))
    }
    
    @IBAction func loginVK(sender: UIButton) {
        performAuthentication(.Social(.VKontakte))
    }
    
    @IBAction func loginNative(sender: AnyObject) {
        
        phone.validate()
        code.validate()
        
        if phone.isValid && code.isValid {
            performNativeAuthentication()
        } else {
            hudManger.showHUD("Ошибка", details: "Введите номер телефона и код", type: .Failure)
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
    
    @IBAction func requestNewPasswordButtonTouchUpInside(sender: AnyObject) {
        
        if !phone.isValid {
            hudManger.showHUD("Ошибка", details: "Введите корректный номер телефона, на него будет повторно отправлен код.", type: .Failure)
        }
        else {
            let hud = hudManger.showHUD("Отправяем смс...", details: "", type: .Processing)
            authenticationManager.requestNewPassword(for: phone.unmaskText() ?? "") {
                (success: Bool, result: String?) -> Void in
                if success {
                    self.hudManger.hideHUD(hud)
                    self.hudManger.showHUD("", details: "", type: .Success)
                }
                else {
                    self.hudManger.hideHUD(hud)
                    self.hudManger.showHUD("Ошибка", details: result, type: .Failure)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code.secureTextEntry = true
        code.keyboardType = .NumberPad
        phone.keyboardType = .NumberPad
        phone.delegate = self
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == phone {
            if textField.text?.characters.count < 3 {
                textField.text = "+7"
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phone {
            
            textField.addTarget(self, action: #selector(applyMaskToPhoneField(_:)), forControlEvents: .EditingChanged)
            let invalidCharacters = NSCharacterSet(charactersInString: "+()-0123456789").invertedSet
            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        }
        
        return false
    }
    
    func applyMaskToPhoneField(textField: RCGPhoneTextField) {
        let count = phone.text?.characters.count
        if count < 3 {
            textField.text = "+7"
        }
        if oldNumber.characters.count < phone.text?.characters.count {
            //если символов меньше - цифры номера добавляются, нужно применять форматирование
            if let text = textField.text {
                if count == 3 {
                    let result = String(format: "%@(%@",
                                        text.substringToIndex(text.startIndex.advancedBy(2)),
                                        text.substringWithRange(text.startIndex.advancedBy(2) ... text.startIndex.advancedBy(2)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 7 {
                    let result = String(format: "%@)%@",
                                        text.substringToIndex(text.startIndex.advancedBy(6)),
                                        text.substringWithRange(text.startIndex.advancedBy(6) ... text.startIndex.advancedBy(6)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 11 {
                    let result = String(format: "%@-%@",
                                        text.substringToIndex(text.startIndex.advancedBy(10)),
                                        text.substringWithRange(text.startIndex.advancedBy(10) ... text.startIndex.advancedBy(10)))
                    textField.text = result
                    oldNumber = result
                }
                if count == 14 {
                    let result = String(format: "%@-%@",
                                        text.substringToIndex(text.startIndex.advancedBy(13)),
                                        text.substringWithRange(text.startIndex.advancedBy(13) ... text.startIndex.advancedBy(13)))
                    textField.text = result
                    oldNumber = result
                }
                if count > 16 {
                    let result = String(format: "%@",
                                        text.substringToIndex(text.startIndex.advancedBy(count!-1)))
                    textField.text = result
                    oldNumber = result
                }
            }
        }
        else if oldNumber.characters.count > textField.text?.characters.count {
            //если символов больше - цифры удаляются, нужно отменять форматирование
            if let text = textField.text {
                if count == 3 || count == 7 || count == 11 || count == 14{
                    let result = String(format: "%@",
                                        text.substringToIndex(text.startIndex.advancedBy(count!-1)))
                    textField.text = result
                    oldNumber = result
                }
            }
        }
        textField.validate()
    }
    
    func removeInvalidCharacters(s: String, charactersString: String) -> String {
        let invalidCharactersSet = NSCharacterSet(charactersInString: charactersString).invertedSet
        return s.componentsSeparatedByCharactersInSet(invalidCharactersSet).joinWithSeparator("")
    }
    
    func didFinishRegistering(sender: RegisterViewController) {
        self.phone.text = sender.phoneNumber.text
        self.code.text = sender.validationCode
        NSLog("Finished registering with: Phone \(phone.text) and code \(code.text). Authenticating now.")
        authenticationManager.parentViewController = self
        
        performNativeAuthentication()
    }
    
    private func performNativeAuthentication() {
        performAuthentication(.Native(
            login: self.phone.unmaskText() ?? "",
            password: self.code.text ?? ""
        ))
    }
    
    private func performAuthentication(method: AuthenticationMethod) {
        weak var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        authenticationManager.authenticate(method) { [weak self] result in
            hud?.hide(true)
            
            switch result {
            
            case .Success:
                self?.dismissViewControllerAnimated(true, completion: nil)
            
            case .UserNotFound(let socialNetwork, let socialToken, let tokenSecret):
                guard let registrationViewController = self?.storyboard?.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController else {
                    return assertionFailure("RegisterViewController not found")
                }
                
                registrationViewController.socialNetwork = socialNetwork
                registrationViewController.socialToken = socialToken
                registrationViewController.tokenSecret = tokenSecret
                
                self?.presentViewController(registrationViewController, animated: true, completion: nil)
            
            case .Failure(let error):
                self?.hudManger.showHUD("Ошибка", details: error?.localizedDescription ?? "Неизвестная ошибка", type: .Failure)
            }
        }
    }
}