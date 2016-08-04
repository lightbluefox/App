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
    var hudManager = HUDManager()
    let newsReceiver = NewsReceiver()
    var hideMoreCommentsButton = false
    
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsDateDay: UILabel!
    @IBOutlet weak var newsDateMonthYear: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsFullText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hudManager.parentViewController = self
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "leftBackGround")!)
        self.navigationItem.title = "ЛЕНТА НОВОСТЕЙ";
        newsTableView.separatorStyle = .None
        newsTableView.keyboardDismissMode = .Interactive
        setCellStyle()
        
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
    
    private func setCellStyle() {
        self.newsTableView.backgroundColor = UIColor.clearColor()
        //self.newsTableView.estimatedRowHeight = 80
        self.newsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /*private func setupNewsFields() {
        //MARK: получаем только первую фотку из массива, т.к. отображение нескольких пока не закладывалось
        if self.newsReceiver.singleNews.images.isEmpty
        {
            self.newsImageView.image = UIImage(named: "noimage")
        }
        else {
            self.newsImageView.sd_setImageWithURL(NSURL(string: self.newsReceiver.singleNews.images[0]))
        }
        self.newsImageView.clipsToBounds = true
        self.newsDateDay.text = self.newsReceiver.singleNews.addedDate.dayFromDdMmYyyy
        self.newsDateMonthYear.text = self.newsReceiver.singleNews.addedDate.monthYearFromDdMmYyyy
        self.newsTitle.text = self.newsReceiver.singleNews.topic
        self.newsFullText.text = self.newsReceiver.singleNews.fullText
    }*/
    
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
            if self.newsReceiver.singleNews.images.isEmpty
            {
                cell?.newsImageView.image = UIImage(named: "noimage")
            }
            else {
                cell?.newsImageView.sd_setImageWithURL(NSURL(string: self.newsReceiver.singleNews.images[0]))
            }
            cell?.newsImageView.clipsToBounds = true
            cell?.newsDateDay.text = self.newsReceiver.singleNews.addedDate.dayFromDdMmYyyy
            cell?.newsDateMonthYear.text = self.newsReceiver.singleNews.addedDate.monthYearFromDdMmYyyy
            cell?.newsTitle.text = self.newsReceiver.singleNews.topic
            cell?.newsFullText.text = self.newsReceiver.singleNews.fullText
            
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
            if !user.isAuthenticated {
                //cell?.addCommentButton.disabled = true
                //cell?.addCommentButton.backgroundColor = UIColor.darkGrayColor()
                cell?.tapAction = { (sender:RCGButton) -> Void in
                    _ = self.hudManager.showHUD("Ошибка", details: "Авторизуйтесь для отправки комментариев", type: .Failure)
                }
            }
                
                else {
                    //cell?.addCommentButton.disabled = false
                    //cell?.addCommentButton.backgroundColor =
                cell?.tapAction = {
                    (sender:RCGButton) -> Void in
                    self.hudManager.showHUD("", details: "", type: .Success)
                }
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
