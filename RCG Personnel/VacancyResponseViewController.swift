//
//  VacancyReplyViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 26.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class VacancyResponseViewController : UIViewController {
    var vacancyId: String?
    
    @IBOutlet weak var name: RCGTextFieldClass!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var phone: RCGTextFieldClass!
    @IBOutlet weak var vkId: RCGTextFieldClass!
    
    @IBOutlet weak var scrollViewBottomMargin: NSLayoutConstraint!
    //Mark: константа для хранения значения нижнего отступа ScrollView
    var scrollViewBottomMarginConstant : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ОТКЛИК НА ВАКАНСИЮ"
        self.name.autocapitalizationType = UITextAutocapitalizationType.Words
        
        //Mark: Скрывать, клавиатуру при тапе по скрол вью
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:");
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
        phone.keyboardType = UIKeyboardType.NamePhonePad
        vkId.keyboardType = UIKeyboardType.NamePhonePad
        
        //Mark: Сжимать размер скрол вью при появлении клавы
        self.scrollViewBottomMarginConstant = self.scrollViewBottomMargin.constant;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
        
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
    @IBAction func submitButtonClick(sender: UIButton) {
        if name.text == "" || phone.text == ""
        {
            let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            failureNotification.mode = MBProgressHUDMode.Text
            failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
            failureNotification.labelText = "Ошибка"
            failureNotification.detailsLabelText = "Ваше имя и контактный телефон обязательны для заполнения"
            failureNotification.hide(true, afterDelay: 3)
        }
        else {
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
            loadingNotification.labelText = "Отправляем"
            
            let request = HTTPTask()
            //let replyText = "{\"lastname\":\"\(phone.text!)\",\"name\":\"\(name.text!)\",\"telephone\":\"\(vkId.text!)\"}"
            let requestUrl = Constants.apiUrl + "api/vacancies/\(vacancyId!)/replies"
            let params: Dictionary<String,AnyObject> = ["name":name.text!, "phone": phone.text!, "vkid": vkId.text!];
            
            request.POST(requestUrl, parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        loadingNotification.hide(true)
                        
                        let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                        failureNotification.mode = MBProgressHUDMode.Text
                        failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                        //failureNotification.color = UIColor(red: 194/255, green: 0, blue: 18/255, alpha: 0.8);
                        failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                        failureNotification.labelText = "Ошибка"
                        failureNotification.detailsLabelText = err.localizedDescription
                        failureNotification.hide(true, afterDelay: 3)
                    }
                    print("error: " + err.localizedDescription)
                }
                else if let resp: AnyObject = response.responseObject {
                    _ = NSString(data: resp as! NSData, encoding: NSUTF8StringEncoding)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        loadingNotification.hide(true)
                        
                        let successNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                        successNotification.mode = MBProgressHUDMode.CustomView
                        successNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                        let imageView = UIImageView();
                        imageView.image = UIImage(named: "checkmark");
                        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50);
                        imageView.contentMode = UIViewContentMode.Center;
                        successNotification.customView = imageView
                        
                        successNotification.hide(true, afterDelay: 3)
                    }
                }
            })
        }
    }

    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.scrollViewBottomMargin.constant = self.scrollViewBottomMarginConstant + frame.size.height  - 45 //-45, т.к. над клавиатурой появляется широкий белый отступ. Нет времени ковырять(
                
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
    
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //func keyboardWillShow(notification: NSNotification){
    
    //}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(sender: AnyObject) {
        self.scrollView.endEditing(true)
    }
}
