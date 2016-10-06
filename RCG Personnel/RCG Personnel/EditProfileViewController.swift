//
//  EditProfileViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 04.05.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import MBProgressHUD

final class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let authenticationManager = AuthenticationManager()
    
    @IBAction func logoffButtonPressed(sender: AnyObject) {
        //Показать алерт - "Вы уверены?"
        //Очистить данные о пользователе - все токены и пр (в том числе из NSDefaults)
        //Перейти на NewsViewController
        //Презентовать LoginViewController
        let logOffAction = UIAlertAction(title: "Да", style: .Default) { (_) -> Void in
            self.authenticationManager.logoff(self.tabBarController!)
        }
        hudManager.showAlertWithСancelButton("Точно?", message: "Вы не сможете писать комментарии и откликаться на вакансии", cancelButtonTitle: "Нет", action: logOffAction)
        
    }
    
    @IBAction func editingDidEnd(sender: RCGTextFieldClass) {
        if sender.text != "" {
            sender.isValid = true
            print(fieldsAreValid.indexForKey(sender))
            print(fieldsAreValid.values)
            fieldsAreValid.updateValue(sender.isValid, forKey: sender)
        }
        else {
            sender.isValid = false
            fieldsAreValid.updateValue(sender.isValid, forKey: sender)
        }
        sender.setRightImage()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userPhoto: UIImageView!
    var clearPhone = ""
    @IBOutlet weak var phoneNumber: RCGPhoneTextField!
    @IBOutlet weak var firstName: RCGTextFieldClass!
    @IBOutlet weak var middleName: RCGTextFieldClass!
    @IBOutlet weak var lastName: RCGTextFieldClass!
    @IBOutlet weak var sex: RCGTextFieldClass!
    @IBOutlet weak var email: RCGTextFieldClass!
    @IBOutlet weak var birthDate: RCGTextFieldClass!
    @IBOutlet weak var height: RCGTextFieldClass!
    @IBOutlet weak var clothesSize: RCGTextFieldClass!
    @IBOutlet weak var hasMedicalCard: RCGUISwitch!
    @IBOutlet weak var scrollViewBottomMargin: NSLayoutConstraint!
    var scrollViewBottomMarginConstant: CGFloat = 0
    @IBAction func hasMedicalCardSwitched(sender: UISwitch) {
        if sender.on {
            medicalCardNumber.hidden = false
            fieldsAreValid.updateValue(medicalCardNumber.isValid, forKey: medicalCardNumber)
            subwayStationTopMarginFromMedicalCardUISwitch.constant = 60 //высота поля 30 + 2 отступа по 15
        }
        else {
            medicalCardNumber.hidden = true
            fieldsAreValid.removeValueForKey(medicalCardNumber)
            subwayStationTopMarginFromMedicalCardUISwitch.constant = 15
            
        }
    }
    
    @IBOutlet weak var medicalCardNumber: RCGTextFieldClass!
    @IBOutlet weak var subwayStationTopMarginFromMedicalCardUISwitch: NSLayoutConstraint!
    @IBOutlet weak var subwayStation: RCGTextFieldClass!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var twButton: UIButton!

    var fieldsAreValid = [UITextField : Bool]()
    var hudManager = HUDManager()
    var genderPickerData = [String]()
    let imagePicker = UIImagePickerController()
    let userReceiver = UserReceiver()
    var photoDidChange = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.hudManager.parentViewController = self
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        self.fieldsAreValid = [
            phoneNumber : phoneNumber.isValid,
            firstName : firstName.isValid,
            middleName : middleName.isValid,
            lastName :lastName.isValid,
            sex : sex.isValid,
            email : email.isValid,
            birthDate : birthDate.isValid,
            height : height.isValid,
            clothesSize : clothesSize.isValid,
            subwayStation : subwayStation.isValid
        ]
        addGenderPickerViewOnTap(forTextField: sex)
        addDatePickerViewOnTap(forTextField: birthDate)
        imagePicker.delegate = self
        
        vkButton.addTarget(self, action: #selector(onSocialButtonTap(_:)), forControlEvents: .TouchUpInside)
        fbButton.addTarget(self, action: #selector(onSocialButtonTap(_:)), forControlEvents: .TouchUpInside)
        twButton.addTarget(self, action: #selector(onSocialButtonTap(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(fillInInputValues),
            name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated,
            object: nil
        )
    }
    
    @objc private func onSocialButtonTap(button: UIButton) {
        guard let socialNetwork = socialNetworkForButton(button) else { return }
        
        let socialId = user.tokenForSocialNetwork(socialNetwork)
        
        weak var hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        if socialId?.isEmpty == false {    // соцсеть привязана
            authenticationManager.unbindSocialNetwork(socialNetwork) { [weak self] error in
                hud?.hideAnimated(true)
                if let error = error {
                    self?.hudManager.showHUD("Ошибка", details: error.localizedDescription, type: .Failure)
                } else {
                    self?.hudManager.showHUD(nil, details: nil, type: .Success)
                }
            }
        } else {    // соцсеть не привязана
            authenticationManager.bindSocialNetwork(socialNetwork) { [weak self] error in
                hud?.hideAnimated(true)
                if let error = error {
                    self?.hudManager.showHUD("Ошибка", details: error.localizedDescription, type: .Failure)
                } else {
                    self?.hudManager.showHUD(nil, details: nil, type: .Success)
                }
            }
        }
    }
    
    private func socialNetworkForButton(button: UIButton) -> SocialNetwork? {
        switch button {
        case vkButton:
            return .VKontakte
        case fbButton:
            return .Facebook
        case twButton:
            return .Twitter
        default:
            return nil
        }
    }
    
    private func setupView() {
        prepareUserPhoto()
        fillInInputValues()
        prepareScrollView()
        firstName.autocapitalizationType = .Words
        lastName.autocapitalizationType = .Words
        middleName.autocapitalizationType = .Words
        subwayStation.autocapitalizationType = .Sentences
        phoneNumber.keyboardType = .PhonePad
        email.keyboardType = .EmailAddress
        height.keyboardType = .NumberPad
        clothesSize.keyboardType = .NumberPad
        
        //Чтобы в методе textView запретить вводить какие-либо значения кроме чисел
        height.delegate = self
        clothesSize.delegate = self
    }
    
    private func prepareUserPhoto() {
        userPhoto.image = user.noPhotoImage
        if let photoUrlString = user.photoUrl {
            if let photoUrl = NSURL(string: photoUrlString) {
                if UIApplication.sharedApplication().canOpenURL(photoUrl) {
                    userPhoto.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: user.photoUrl ?? ""), andPlaceholderImage: user.noPhotoImage, options: .RetryFailed, progress: nil, completed: nil)
                }
                else
                {
                    if let decodedFromBase64Image = user.photoUrl?.decodeUIImageFromBase64() {
                        userPhoto.image = decodedFromBase64Image
                    }
                }
            }
        }
        userPhoto.clipsToBounds = true
        userPhoto.contentMode = .ScaleAspectFill
        userPhoto.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePickerDialog(_:)))
        userPhoto.userInteractionEnabled = true
        userPhoto.addGestureRecognizer(tap)
    }
    
    @objc private func fillInInputValues() {
        self.phoneNumber.enabled = false
        self.phoneNumber.text = user.phone
        applyMaskToPhoneField(self.phoneNumber)
        self.phoneNumber.validate()
        self.firstName.text = user.firstName
        self.firstName.validate()
        self.lastName.text = user.lastName
        self.lastName.validate()
        self.middleName.text = user.middleName
        self.middleName.validate()
        self.email.text = user.email
        self.email.validate()
        if let gender = user.gender {
            switch gender {
                case .Male: self.sex.text = "Мужской"
                case .Female: self.sex.text = "Женский"
            }
            self.sex.validate()
        }
        self.birthDate.text = user.birthDate?.formatedDate
        self.birthDate.validate()
        self.height.text = String(user.height ?? 0)
        self.height.validate()
        self.clothesSize.text = String(user.size ?? 0)
        self.clothesSize.validate()
        self.subwayStation.text = user.metroStation
        self.subwayStation.validate()
        if user.hasMedicalBook ?? false {
            self.hasMedicalCard.setOn(true, animated: false)
            hasMedicalCardSwitched(hasMedicalCard)
            self.medicalCardNumber.text = user.medicalBookNumber
            self.medicalCardNumber.validate()
        }
        vkButton.setTitleColor(user.vkToken?.isEmpty == false ? .blueColor() : .grayColor(), forState: .Normal)
        fbButton.setTitleColor(user.fbToken?.isEmpty == false ? .blueColor() : .grayColor(), forState: .Normal)
        twButton.setTitleColor(user.twToken?.isEmpty == false ? .blueColor() : .grayColor(), forState: .Normal)
    }
    
    func prepareScrollView() {
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
        self.scrollViewBottomMarginConstant = self.scrollViewBottomMargin.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant + frame.size.height - 45//-45, т.к. над клавиатурой появляется широкий белый отступ.
                
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
        self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant
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
    
    override func setBarButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .Plain, target: self, action: #selector(EditProfileViewController.saveUserInfo))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .Plain, target: self, action: #selector(EditProfileViewController.hideEditProfileViewController))
    }

    func saveUserInfo() {
        /*
        Если фотка была изменена, отправляется фотка на сервер, обратно приходит url
         
        Значения полей отправляются на сервер, после успешной отправки они сохраняются в user, вызывается нотификейшн о том, что польз был обновлен - обновляются данные в ProfileVC
         
        */
        if fieldsAreValid.values.contains(false) {
            hudManager.showHUD("Ошибка", details: "Все поля обязательны для заполнения", type: .Failure)
        }
        else {
            if photoDidChange {
                let hud = hudManager.showHUD("Загружаем фотографию...", details: nil, type: .Processing)
                userReceiver.uploadPhoto(userPhoto.image!) {
                    (isSuccess, error) -> Void in
                    if isSuccess {
                        self.hudManager.hideHUD(hud)
                        self.updateUserOnServer()
                    }
                    else {
                        self.hudManager.hideHUD(hud)
                        self.hudManager.showHUD("Ошибка", details: error ?? "Не удалось отправить фотографию", type: .Failure)
                        self.photoDidChange = false
                        self.prepareUserPhoto()
                    }
                    
                }
            }
            else
            {
                updateUserOnServer()
            }
        }
    }
    
    func updateUserOnServer() -> Void {
        let hud = hudManager.showHUD("Сохраняем...", details: nil, type: .Processing)
        
        var gender = Gender.Male
        if sex.text == "Женский" {
            gender = Gender.Female
        }
        else {
            gender = Gender.Male
        }

        userReceiver.updateCurrentUserWithValues(user.photoUrl ?? "",
            firstName: firstName.text ?? "",
            middleName: middleName.text ?? "",
            lastName: lastName.text ?? "",
            email: email.text ?? "",
            birthDate: birthDate.text ?? "",
            medicalBookNumber: medicalCardNumber.text ?? "",
            metroStation: subwayStation.text ?? "",
            height: Int(height.text ?? "") ?? 0,
            size: Int(clothesSize.text ?? "") ?? 0,
            hasMedicalBook: hasMedicalCard.on,
            gender: gender,
            vkToken: nil,
            fbToken: nil,
            twToken: nil)
        {(success, result) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.hudManager.hideHUD(hud)
                    self.navigationController?.popViewControllerAnimated(false)
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.hudManager.hideHUD(hud)
                    self.hudManager.showHUD("Ошибка", details: result, type: .Failure)
                }
            }
        }
    }
    
    func showImagePickerDialog(sender: UITapGestureRecognizer) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imagedata = UIImageJPEGRepresentation(originalImage, 1.0)
            if imagedata != nil {
                let image = UIImage(data: imagedata!)
                userPhoto.image = image
                self.photoDidChange = true
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    //MARK: UIPickerViewDelegate
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.sex.text = genderPickerData[row]
    }
    
    ///Создает PickerView с выбором пола, который открывается при тапе на TextField
    private func addGenderPickerViewOnTap(forTextField sender: UITextField) {
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 50, 100, 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        self.genderPickerData = ["Мужской", "Женский"]
        sender.inputView = pickerView
        
        //Чтобы в функции textField() запретить пользователям вставлять или изменять
        sender.delegate = self
    }
    
    private func addDatePickerViewOnTap(forTextField sender: UITextField) {
        let datePickerView = UIDatePicker.init(frame: CGRectMake(0,50, 100,150))
        datePickerView.datePickerMode = .Date
        datePickerView.addTarget(self, action: #selector(setValueFromDatePickerToBirhDateTextField(_:)), forControlEvents: .ValueChanged)
        sender.inputView = datePickerView
        
        //Чтобы в функции textField() запретить пользователям вставлять или изменять
        sender.delegate = self
    }
    
    func setValueFromDatePickerToBirhDateTextField(datepicker: UIDatePicker) {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let selectedDate = dateFormatter.stringFromDate(datepicker.date)
        self.birthDate.text = selectedDate
       
    }
    
    //Mark: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if textField == phoneNumber {
            textField.addTarget(self, action: #selector(applyMaskToPhoneField(_:)), forControlEvents: .EditingChanged)
        }
        
        if textField == phoneNumber || textField == clothesSize || textField == height {
            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
            return string.rangeOfCharacterFromSet(invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
        }
        
        return false //для полей, у которых делегатом выставлен этот класс нельзя никаких значений заполнить по умолчанию
    }
    
    func applyMaskToPhoneField(textField: UITextField) {
        func formatPhone(s: String, _ mask: String) -> String {
            let result = String(format: mask, s.substringToIndex(s.startIndex.advancedBy(1)),
                                s.substringWithRange(s.startIndex.advancedBy(1) ... s.startIndex.advancedBy(3)),
                                s.substringWithRange(s.startIndex.advancedBy(4) ... s.startIndex.advancedBy(6)),
                                s.substringWithRange(s.startIndex.advancedBy(7) ... s.startIndex.advancedBy(8)),
                                s.substringWithRange(s.startIndex.advancedBy(9) ... s.startIndex.advancedBy(10))
            )
            return result
        }
        
        if textField.text?.characters.count == 11 {
                    textField.text = formatPhone(textField.text!, "+%@(%@)%@-%@-%@")
        }
    }
    
    func hideEditProfileViewController() {
        self.navigationController?.popViewControllerAnimated(false)
    }
}
