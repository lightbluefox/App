
//
//  ValidatePhoneViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 09.06.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import Foundation
import Alamofire

class ValidatePhoneViewController: BaseViewController, UITextFieldDelegate {
    
    var hudManager = HUDManager()
    
    var phoneNumber : String?
    var onFinish: (() -> ())?
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var backGroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code.keyboardType = .NumberPad
        code.delegate = self
        hudManager.parentViewController = self
        addGestureRecognizerForDismissingViewOnBackgroundTap()
        
    }
    
    private func addGestureRecognizerForDismissingViewOnBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissView(_:)))
        self.backGroundView.userInteractionEnabled = true
        self.backGroundView.addGestureRecognizer(tap)
        
    }
    
    func dismissView(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
    
    @IBAction func codeFieldEditingChanged(sender: UITextField) {
        if sender.text?.characters.count == 6 {
            sendCode()
        }
    }
    
    ///Send code to the server
    ///
    ///If code is correct, dismissing VC
    ///
    ///If code is incorrect, present failure message
    func sendCode() {
        print(code.text)
        print(phoneNumber)
        
        let hud = hudManager.showHUD("Отправляем...", details: nil, type: .Processing)
        
        let requestUrl = Constants.apiUrl + "api/v01/users/confirm"
        /*
         Метод подтверждения пользователя, принимает 3 параметра: login, sms, password.
         Возвращает:
         а) Если недостаточно параметров - "need more params"
         б) Если нет пользователя с таким телефоном - "no such user"
         в) Если у пользователя нет группы unconfirmed - "already confirmed"
         г) Если у пользователя
         - нет смсок или
         - есть активная СМСка и количество попыток на нее < 5,
         надо запросить новую СМСку: "request new SMS"
         д) Если пароль короче 5 символов - "short password",
         е) Если некорректная СМСка - "wrong SMS"
         ж) Если все ок - прийдет просто "status OK"
         */
        let params : [String: AnyObject] = [
            "login":phoneNumber ?? "",
            "password":code.text ?? "",
            "sms":code.text ?? ""
        ]
        Alamofire.request(.POST, requestUrl, parameters: params)
            .responseString { [weak self] response in
                switch response.result {
                case .Success:
                    self?.hudManager.hideHUD(hud)
                    self?.dismissViewControllerAnimated(false, completion: nil)
                    self?.onFinish?()
                case .Failure(let error):
                    print("Error: \(error)")
                    self?.hudManager.hideHUD(hud)
                    self?.hudManager.showHUD("Ошибка", details: error.description, type: .Failure)
                }
        }
  
    }
}