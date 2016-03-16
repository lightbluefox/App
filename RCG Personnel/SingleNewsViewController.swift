//
//  SingleNewsViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 20.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class SingleNewsViewController : UIViewController {
    
    var newsGuid: String?
    let newsReceiver = NewsReceiver()
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsDateDay: UILabel!
    @IBOutlet weak var newsDateMonthYear: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsFullText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ЛЕНТА НОВОСТЕЙ";

        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружается новость
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        self.newsReceiver.getSingleNews(self.newsGuid!, completionHandlerNews: {(success: Bool, result: String) in
            if success {
                //MARK: получаем только первую фотку из массива, т.к. требований к нескольким фотографиям еще не было
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
                loadingNotification.hide(true)
                
            }
            else if !success
            {
                loadingNotification.hide(true)
                
                let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                failureNotification.mode = MBProgressHUDMode.Text
                failureNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
                failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                failureNotification.labelText = "Ошибка"
                failureNotification.detailsLabelText = result
                failureNotification.hide(true, afterDelay: 3)
                
            }
        })
    }
    func leftNavButtonClick(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
