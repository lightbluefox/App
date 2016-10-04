//
//  FeedBackViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import SwiftyJSON

class FeedBackViewController : BaseViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var themeTextField: RCGTextFieldClass!
    @IBOutlet weak var nameTextField: RCGTextFieldClass!
    @IBOutlet weak var emailTextField: RCGTextFieldClass!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextRectangle: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //Mark: константа для хранения значения нижнего отступа ScrollView
    var scrollViewBottomMarginConstant : CGFloat = 0
    
    var pickerData = [String]()
    let hudManager = HUDManager()
    
    @IBOutlet weak var scrollViewBottomMargin: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hudManager.parentViewController = self
        
        self.navigationItem.title = "ОБРАТНАЯ СВЯЗЬ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;
        
        nameTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        
        setShowingPickerViewOnTap(themeTextField)
        
        //MARK: Скрывать, клавиатуру при тапе по скрол вью
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedBackViewController.hideKeyboard(_:)));
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        setScrollViewSqueezeOnKeyboardAppearаnce()
        getDataFromProfile()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.getDataFromProfile), name: NSNotificationCenterKeys.notifyThatUserHaveBeenUpdated, object: nil)
    }
    
    func getDataFromProfile() {
        if let email = user.email {
            self.emailTextField.text = email
        }
        if let fullName = user.fullName {
            self.nameTextField.text = fullName
        }
    }
    
    private func setShowingPickerViewOnTap(sender: UITextField) {
        let pickerView = UIPickerView.init(frame: CGRectMake(0, 50, 100, 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        self.pickerData = ["Работа приложения", "Работа на акциях", "Предложения", "Другое"]
        sender.inputView = pickerView
        
        //Делегируем полю, чтобы в функции textField() запретить пользователям вставлять текст.
        sender.delegate = self
    }
    
    private func setScrollViewSqueezeOnKeyboardAppearаnce() {
        self.scrollViewBottomMarginConstant = self.scrollViewBottomMargin.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedBackViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedBackViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        messageTextView.textContainerInset = UIEdgeInsetsMake(8, 3, 8, 30)
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        messageTextRectangle.selected = false;
        
        messageTextView.delegate = self
        messageTextView.text = "Текст сообщения *"
        messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        
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
    
    @IBAction func textFieldEditingDone(sender: UITextField) {
        if sender.text != "" {
            let imageView = UIImageView();
            imageView.image = UIImage(named: "textRectangleOk");
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 14);
            imageView.contentMode = UIViewContentMode.Left;
            sender.rightView = imageView;
        }
        else
        {
            let imageView = UIImageView();
            imageView.image = UIImage(named: "textRectangle");
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 14);
            imageView.contentMode = UIViewContentMode.Left;
            sender.rightView = imageView;
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if messageTextView.textColor == UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        {
            messageTextView.text = ""
            messageTextView.textColor = UIColor.darkGrayColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if messageTextView.text == ""
        {
            messageTextView.text = "Текст сообщения"
            messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
            messageTextRectangle.selected = false
        }
        else
        {
            messageTextRectangle.selected = true
        }
        
    }
    
    @IBAction func submitButtonClick(sender: UIButton) {
        if messageTextView.textColor == UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1) || nameTextField.text == "" || emailTextField.text == "" || themeTextField.text == ""
        {
            hudManager.showHUD("Ошибка", details: "Все поля обязательны для заполнения", type: .Failure)
        }
        else
        {
            let hud = hudManager.showHUD("Отправляем...", details: nil, type: .Processing)
            
            let requestUrl = Constants.apiUrl + "api/v01/feedback"
            let params: Dictionary<String,AnyObject> = ["name":nameTextField.text!, "email":emailTextField.text!, "text":messageTextView.text, "topic":themeTextField.text!];
            
            Alamofire.request(.POST, requestUrl, parameters: params).responseString { response in
                
                self.hudManager.hideHUD(hud)
                switch response.result {
                case .Failure(let err):
                    self.hudManager.showHUD("Ошибка", details: err.localizedDescription, type: .Failure)
                    NSLog("Error sending feedback: \(err.localizedDescription)")

                case .Success:
                    if let responseData = response.data {
                        var jsonError: NSError?
                        let json = JSON(data: responseData, options: .AllowFragments, error: &jsonError)
                        if let error = json["error"].string {
                            self.hudManager.showHUD("Ошибка", details: error, type: .Failure)
                            NSLog("Error sending feedback: \(error)")
                        }
                        else {
                            self.hudManager.showHUD(nil, details: nil, type: .Success)
                            self.clearView()
                        }
                    }
                }
            }
        }
    }
    
    private func clearView() {
        messageTextView.text = "Текст сообщения"
        messageTextView.textColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
        messageTextRectangle.selected = false
        nameTextField.text = ""
        textFieldEditingDone(nameTextField)
        themeTextField.text = ""
        textFieldEditingDone(themeTextField)
        emailTextField.text = ""
        textFieldEditingDone(emailTextField)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(sender: AnyObject) {
        self.scrollView.endEditing(true)
    }
    
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //Mark: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    //MARK: UIPickerView
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.themeTextField.text = pickerData[row]
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
