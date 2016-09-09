//
//  SingleNewsViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 20.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleNewsViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newsGuid: String?
    let hudManager = HUDManager()
    let newsReceiver = NewsReceiver()
    let shareManager = ShareManager()
    
    var hideMoreCommentsButton = false
    
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsDateDay: UILabel!
    @IBOutlet weak var newsDateMonthYear: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsFullText: UILabel!
    
    @IBOutlet weak var addCommentButton: RCGButton!
    
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hudManager.parentViewController = self
        self.shareManager.fbShareManager.parentViewController = self
        self.shareManager.twShareManager.parentViewController = self
        self.shareManager.vkShareManager.parentViewController = self
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "leftBackGround")!)
        self.navigationItem.title = "ЛЕНТА НОВОСТЕЙ";
        newsTableView.separatorStyle = .None
        newsTableView.keyboardDismissMode = .Interactive
        //Mark: Скрывать, клавиатуру при тапе по newsTableView
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)));
        tapGesture.cancelsTouchesInView = false
        newsTableView.addGestureRecognizer(tapGesture)
                setCellStyle()
        
        
        setTableViewSqueezeOnKeyboardAppearance()
        loadNews()
        loadComments()
    }
    
    private func loadNews() {
        guard let newsGuid = newsGuid else { return }
        
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружается новость
        let loadingNotification = setLoadingNotification()
        
        self.newsReceiver.getSingleNews(newsGuid) { success, result in
            loadingNotification.hide(true)
            
            if success {
                self.newsTableView.reloadData()
            } else {
                self.showFailureNotification(result)
            }
        }
    }
    
    private func loadComments() {
        guard let newsGuid = newsGuid else {return}
        
        self.newsReceiver.getComments(newsGuid) { success, result, moreCommentsAvailable in
            if success {
                //Проставить кол-во комментариев в соотв поле
                if self.newsReceiver.singleNews.comments.count == 0 {
                    //Комментариев нет, надо написать сообщение об этом в ячейке
                    self.hideMoreCommentsButton = true
                }
                else {
                    //self.newsTableView.reloadSections(NSIndexSet(index:1), withRowAnimation: .Automatic)
                    self.newsTableView.reloadData()
                    if !moreCommentsAvailable {
                        //Спрятать кнопку "Показать еще"
                        self.hideMoreCommentsButton = true
                    }
                }
            }
            else {
                self.showFailureNotification(result)
            }
        }
    }
    
    private func setTableViewSqueezeOnKeyboardAppearance() {
        //Mark: Сжимать размер скрол вью при появлении клавы
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.newsTableView.reloadData()
    }
    
    private func setLoadingNotification() -> AnyObject {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        
        return loadingNotification
    }
    
    func hideKeyboard(sender: AnyObject) {
        self.newsTableView.endEditing(true)
    }
    
    func keyboardWillShowNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.tableViewBottomConstraint.constant = frame.size.height  - 45 //-45, т.к. над клавиатурой появляется широкий белый отступ.
                
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
        self.tableViewBottomConstraint.constant = 0
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

    private func setCellStyle() {
        self.newsTableView.backgroundColor = UIColor.clearColor()
        //self.newsTableView.estimatedRowHeight = 80
        self.newsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func showFailureNotification(result: String) {
        let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        failureNotification.mode = MBProgressHUDMode.Text
        failureNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        failureNotification.labelText = "Ошибка"
        failureNotification.detailsLabelText = result
        failureNotification.hide(true, afterDelay: 3)
    }
    
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return self.newsReceiver.singleNews.comments.count
        }
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if let cell = self.newsTableView.dequeueReusableCellWithIdentifier("SingleNewsCommentsHeader") as? SingleNewsCommentsHeaderCell {
                cell.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 0.4)
                cell.commentsCountText.text = "КОММЕНТАРИИ"
                cell.commentsCountText?.textColor = UIColor.whiteColor()
                cell.commentsCountNumber.text = String(self.newsReceiver.singleNews.commentsTotal)
                return cell
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 600
        }
        if indexPath.section == 1 {
            return 100
        }
        if indexPath.section == 3 {
            return 200
        }
        else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { //Полное содержимое новости
            let cell = self.newsTableView.dequeueReusableCellWithIdentifier("SingleNewsFields", forIndexPath: indexPath) as? SingleNewsContentCell
            cell?.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 0)
            
            //MARK: получаем только первую фотку из массива, т.к. отображение нескольких пока не закладывалось
            var imageUrl : NSURL?
            var image : UIImage?
            if self.newsReceiver.singleNews.images.isEmpty
            {
                cell?.newsImageView.image = UIImage(named: "noimage")
            }
            else {
                imageUrl = NSURL(string: self.newsReceiver.singleNews.images[0])
                cell?.newsImageView.sd_setImageWithURL(imageUrl) {
                    (result) in
                        image = result.0
                }
            }
            cell?.newsImageView.clipsToBounds = true
            cell?.newsDateDay.text = self.newsReceiver.singleNews.addedDate.dayFromDdMmYyyy
            cell?.newsDateMonthYear.text = self.newsReceiver.singleNews.addedDate.monthYearFromDdMmYyyy
            cell?.newsTitle.text = self.newsReceiver.singleNews.topic
            cell?.newsFullText.text = self.newsReceiver.singleNews.fullText
            
            cell?.fbTapAction = {
                self.shareManager.fbShareManager.share(cell?.newsTitle.text ?? "", description: cell?.newsFullText.text ?? "", url: NSURL(string: Constants.appStoreUrl)!, imageURL: imageUrl)
            }
            cell?.vkTapAction = {
                self.shareManager.vkShareManager.share(cell?.newsTitle.text ?? "", image: image, url: NSURL(string: Constants.appStoreUrl)!, urlTitle: "Больше новостей")
            }
            
            cell?.twTapAction = {
                self.shareManager.twShareManager.share(cell?.newsTitle.text ?? "", image: image, url: NSURL(string: Constants.appStoreUrl)!)
            }
    
            return cell!
        }
        else if indexPath.section == 2 { //Область под комментариями, с кнопкой "Загрузить еще"
            let cell = self.newsTableView.dequeueReusableCellWithIdentifier("SingleNewsCommentsFooter", forIndexPath: indexPath) as? SingleNewsCommentsFooterCell
            cell?.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 0)
            cell?.tapAction = {
                self.loadComments()
            }
            if self.hideMoreCommentsButton {
                cell?.hidden =  true
            }
            
            return cell!
        }
        else if indexPath.section == 3 { //Область с отправкой комментария
            let cell = self.newsTableView.dequeueReusableCellWithIdentifier("SingleNewsCommentsAddNew", forIndexPath: indexPath) as? SingleNewsCommentsAddNewCell
            
            cell?.backgroundColor = UIColor.clearColor()
            cell?.addCommentTextView.textColor = UIColor.whiteColor()
            cell?.addCommentTextView.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.2)
            cell?.addCommentTextView.contentInset = UIEdgeInsetsMake(4,4,0,-4)
            
            if let canComment = self.newsReceiver.singleNews.canComment {
                if canComment {
                    //Если может комментировать, то кнопка активна, добавляем отправку комментария по нажатию
                    cell?.addCommentButton.setBackgroundColor(UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0), forUIControlState: .Normal)
                    cell?.addCommentButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                    
                    cell?.tapCompletionHandler = {(success: Bool) -> Void  in
                        if success {
                            cell?.addCommentTextView.text = ""
                        }
                    }
                    cell?.tapAction = {
                        (sender:RCGButton) -> Void in
                        if let comment = cell?.addCommentTextView.text {
                            self.sendComment(comment) {
                                (success: Bool) -> Void in
                                if success {
                                    cell?.addCommentTextView.text = ""
                                }
                            }
                        }
                    }
                }
                else {
                    //Если не может - это из-за того, что он не в группе
                    cell?.addCommentButton.setBackgroundColor(UIColor.grayColor(), forUIControlState: .Normal)
                    cell?.addCommentButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                    cell?.addCommentButton.addTarget(self, action: #selector(self.showMessageThatUserIsNotApprovedYet), forControlEvents: .TouchUpInside)
                }
            }
            else {
                cell?.addCommentButton.setBackgroundColor(UIColor.grayColor(), forUIControlState: .Normal)
                cell?.addCommentButton.removeTarget(self, action: nil, forControlEvents: .TouchUpInside)
                cell?.addCommentButton.addTarget(self, action: #selector(self.showMessageThatUserIsNotAuthenticated), forControlEvents: .TouchUpInside)
            }
            return cell!
        }
        else { //Остальные секции (секция с комментариями)
            let cell = self.newsTableView.dequeueReusableCellWithIdentifier("SingleNewsComment", forIndexPath: indexPath) as? SingleNewsCommentCell
            cell?.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 0)
            
            let comment = self.newsReceiver.singleNews.comments[indexPath.row]
            cell?.commentData.text = comment.date
            cell?.commentText.text = comment.text
            cell?.commentUserName.text = (comment.userLastName ?? "").uppercaseString + " " + (comment.userFirstName ?? "").uppercaseString
                if comment.userPhoto == "" {
                    cell?.commentUserPhoto.image = user.noPhotoImage
                }
                else {
                    cell?.commentUserPhoto.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: comment.userPhoto ?? ""), andPlaceholderImage: user.noPhotoImage, options: .RetryFailed, progress: nil, completed: nil)
                }
            return cell!
        }
    }
    
    func showMessageThatUserIsNotApprovedYet() {
        hudManager.showHUD("Дождитесь подтверждения модератора", details: "Только подтвержденные пользователи могут писать комментарии. Обычно это занимает около часа :)", type: .Failure)
    }
    
    func showMessageThatUserIsNotAuthenticated() {
        hudManager.showHUD("Войдите в приложение", details: "Только авторизованные пользователи могут писать комментарии", type: .Failure)
    }
    
    func sendComment(comment: String, completionHandler: (success: Bool) -> Void) {
        if comment == "" {
            hudManager.showHUD(":(", details: "Не надо отправлять пустой комментарий.", type: .Failure)
        }
        else {
            let hud = hudManager.showHUD("Отправляем...", details: nil, type: .Processing)
            newsReceiver.sendCommentForNews(newsReceiver.singleNews.guid, comment: comment) {
                (success: Bool, result: String) -> Void in
                if success {
                    self.hudManager.hideHUD(hud)
                    self.hudManager.showHUD("Комментарий отправлен!", details: "Он появится сразу же после одобрения модератора.", type: .Failure)
                    completionHandler(success: true)
                }
                else {
                    self.hudManager.hideHUD(hud)
                    self.hudManager.showHUD("Ошибка", details: result, type: .Failure)
                    completionHandler(success: false)
                }
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
