//
//  LoginViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    var previousScrollViewBottomConstraintValue : CGFloat = 0
    
    
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
            performNativeAuthentication(withLogin: phone.unmaskText() ?? "", password: code.text ?? "")
        } else {
            hudManger.showHUD("Ошибка", details: "Введите номер телефона и код", type: .Failure)
        }
    }
    
    @IBAction func registerButtonTouched(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerViewController = storyboard.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController {
            registerViewController.modalPresentationStyle = .OverFullScreen
            registerViewController.onFinish = { [weak self] result in
                self?.handleRegistrationResult(result)
            }
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
        
        setupView()
    }
    
    private func setupView() {
        prepareScrollView()
        
        code.secureTextEntry = true
        code.keyboardType = .NumberPad
        phone.keyboardType = .NumberPad
        phone.delegate = self
    }
    
    private func prepareScrollView() {
        //MARK: Скрывать, клавиатуру при тапе по скрол вью
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)));
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap)
        setScrollViewSqueezeOnKeyboardAppearаnce()
    }
    
    func hideKeyboard(sender: AnyObject) {
        scrollView.endEditing(true)
    }
    
    private func setScrollViewSqueezeOnKeyboardAppearаnce() {
        self.previousScrollViewBottomConstraintValue = self.scrollViewBottomConstraint.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.scrollViewBottomConstraint.constant = self.previousScrollViewBottomConstraintValue + frame.size.height/2
                
                switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
                case let (.Some(duration), .Some(curve)):
                    
                    let options = UIViewAnimationOptions(rawValue: curve.unsignedLongValue)
                    
                    UIView.animateWithDuration(
                        NSTimeInterval(duration.doubleValue),
                        delay: 0,
                        options: options,
                        animations: {
                            UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
                            return
                        }, completion: { finished in
                    })
                default:
                    
                    break
                }
            }
        }
    }
    
    func keyboardWillHideNotification(notification: NSNotification){
        self.scrollViewBottomConstraint.constant = self.previousScrollViewBottomConstraintValue
        if let userInfo = notification.userInfo {
            
            switch (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.Some(duration), .Some(curve)):
                
                let options = UIViewAnimationOptions(rawValue: curve.unsignedLongValue)
                
                UIView.animateWithDuration(
                    NSTimeInterval(duration.doubleValue),
                    delay: 0,
                    options: options,
                    animations: {
                        UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
                        return
                    }, completion: { finished in
                })
            default:
                break
            }
        }
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
    
    private func handleRegistrationResult(result: RegistrationResult) {
        switch result {
        case .NativeSuccess(let login, let password):
            performNativeAuthentication(withLogin: login, password: password)
        case .SocialSuccess(let socialNetwork, let token, let tokenSecret):
            weak var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            authenticationManager.authenticate(socialNetwork, token: token ?? "", tokenSecret: tokenSecret) { [weak self] result in
                hud?.hide(true)
                self?.handleAuthenticationResult(result)
            }
        }
    }
    
    private func performNativeAuthentication(withLogin login: String, password: String) {
        performAuthentication(.Native(login: login, password: password))
    }
    
    private func performAuthentication(method: AuthenticationMethod) {
        weak var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        authenticationManager.authenticate(method) { [weak self] result in
            hud?.hide(true)
            self?.handleAuthenticationResult(result)
        }
    }
    
    private func handleAuthenticationResult(result: AuthenticationResult) {
        switch result {
            
        case .Success:
            dismissViewControllerAnimated(true, completion: nil)
            
        case .UserNotFound(let socialNetwork, let socialToken, let tokenSecret):
            if socialNetwork != nil {
                guard let registrationViewController = storyboard?.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController else {
                return assertionFailure("RegisterViewController not found")
                }
            
                registrationViewController.socialNetwork = socialNetwork
                registrationViewController.socialToken = socialToken
                registrationViewController.tokenSecret = tokenSecret
                registrationViewController.onFinish = { [weak self] result in
                    self?.handleRegistrationResult(result)
                }
            
                presentViewController(registrationViewController, animated: true, completion: nil)
            }
            else {
                hudManger.showHUD("Ошибка", details: "Неверный логин или пароль!", type: .Failure)
            }
            
        case .NotAllowedToLogin(let socialNetwork, let socialToken, let tokenSecret):
            if socialNetwork != nil {
                guard let registrationViewController = storyboard?.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController else {
                    return assertionFailure("RegisterViewController not found")
                }
                
                registrationViewController.socialNetwork = socialNetwork
                registrationViewController.socialToken = socialToken
                registrationViewController.tokenSecret = tokenSecret
                registrationViewController.onFinish = { [weak self] result in
                    self?.handleRegistrationResult(result)
                }
                
                presentViewController(registrationViewController, animated: true, completion: nil)
            }
            else {
                hudManger.showHUD("Ошибка", details: "Неверный логин или пароль!", type: .Failure)
            }
            
        case .IncorrectLoginOrPassword:
            hudManger.showHUD("Ошибка", details: "Неверный логин или пароль!", type: .Failure)
            
        case .Failure(let error):
            hudManger.showHUD("Ошибка", details: error?.localizedDescription ?? "Неизвестная ошибка", type: .Failure)
        }
    }
}