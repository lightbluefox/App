//
//  LoginViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 21.04.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

final class LoginViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private let hudManager = HUDManager()
    private let authenticationService: AuthenticationService
    
    // MARK: - Outlets
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    
    // MARK: - UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        
        authenticationService = AuthenticationServiceImpl()     // TODO: DI
        
        super.init(coder: aDecoder)
        
        hudManager.parentViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: это все можно проставить в сториборде
        codeField.secureTextEntry = true
        codeField.keyboardType = .NumberPad
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldEditingDidEnd(sender: RCGTextFieldClass) {
        sender.validate()
    }
    
    @IBAction func closeButton(_: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loginTW(_: AnyObject) {
        authenticate(.Social(.Twitter))
    }
    
    @IBAction func loginFB(_: AnyObject) {
        authenticate(.Social(.Facebook))
    }
    
    @IBAction func loginVK(sender: UIButton) {
        authenticate(.Social(.VKontakte))
    }
    
    @IBAction func loginNative(sender: AnyObject) {
        if let login = phoneField.text, password = codeField.text where !login.isEmpty && !password.isEmpty {
            authenticate(.Native(login: login, password: password))
        } else {
            hudManager.showHUD("Ошибка", details: "Введите номер телефона и код", type: .Failure)
        }
    }
    
    @IBAction func registerButtonTouched(sender: AnyObject) {
        guard let registerViewController = storyboard?.instantiateViewControllerWithIdentifier("Register") as? RegisterViewController else {
            return assertionFailure("RegisterViewController not found")
        }
        
        registerViewController.modalPresentationStyle = .OverFullScreen
        registerViewController.onFinish = { [weak self] in
            // AuthenticationService в случае успешной регистрации сразу авторизует юзера, так что можно просто закрыть контроллер
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        showDetailViewController(registerViewController, sender: self)
    }
    
    // MARK: - Private
    
    private func authenticate(method: AuthenticationMethod) {
        
        weak var progressIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        authenticationService.authenticate(method) { [weak self] result in
            guard let strongSelf = self else { return }
            
            progressIndicator?.hide(true)
            
            switch result {
            
            case .Success:
                self?.dismissViewControllerAnimated(true, completion: nil)
                
                switch strongSelf.authenticationService.authenticationStatus {
                case .Intermediate:
                    // TODO: нужно показать контроллер регистрации для ввода обязательной регистрационной инфы
                    break
                default:
                    break
                }
            
            case .Failed(let error):
                self?.hudManager.showHUD("Ошибка", details: error?.localizedDescription, type: .Failure)
            }
        }
    }
}