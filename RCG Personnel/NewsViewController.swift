//
//  NewsViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {

    @IBOutlet var newsTableViewController: UITableView!
    let newsReceiver = NewsReceiver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Убираем прозрачность таббара и навбара
        self.navigationItem.title = "НОВОСТИ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;

        //Задаем иконки в таббаре. Получилось только так, т.к. через сториборд unselected иконки становятся серыми
        //TODO: Сделать нормально (возможно через init(coder:)
        let tabBar = self.tabBarController?.tabBar;
        
        tabBar?.tintColor = UIColor.whiteColor();
        let tabItems = tabBar?.items;
        let tabItem0 = tabItems![0] ;
        tabItem0.image = UIImage(named:"news")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        tabItem0.selectedImage = UIImage(named:"newsSelected")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        
        let tabItem1 = tabItems![1] ;
        tabItem1.image = UIImage(named:"vacancy")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        tabItem1.selectedImage = UIImage(named:"vacancySelected")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        
        //MARK: задаем стиль ячеек
        self.newsTableViewController.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        self.newsTableViewController.rowHeight = 210
        
        //MARK: Описываем пул-ту-рефреш
        self.refreshControl = UIRefreshControl();
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Потяните вниз, чтобы обновить");
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружаются новости
        refresh(self)

    }
    override func viewWillAppear(animated: Bool) {
        newsTableViewController.reloadData();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        //println(itemsReceiver.newsStack.count);
        return newsReceiver.newsStack.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.newsTableViewController.dequeueReusableCellWithIdentifier("NewsCell") as! NewsCellViewController
        // Configure the cell...
        let currentNews = newsReceiver.newsStack[indexPath.row];
        
        cell.dateDay?.text = currentNews.addedDate.dayFromDdMmYyyy
        cell.dateMonthYear?.text = currentNews.addedDate.monthYearFromDdMmYyyy
        cell.newsTitle?.text = currentNews.topic
        cell.newsAnnounce?.text = currentNews.shortText
        cell.newsCellImageView?.sd_setImageWithURL(NSURL(string: currentNews.previewImageGuid))
        return cell
    }
    
    func refresh(sender:AnyObject) {
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружаются новости
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3);
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        self.newsReceiver.getAllNews({(success: Bool, result: String) in
            if success {
                loadingNotification.hide(true)
                self.newsTableViewController.reloadData()
            }
            else if !success
            {
                loadingNotification.hide(true)
                
                let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                failureNotification.mode = MBProgressHUDMode.Text
                failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                failureNotification.labelText = "Ошибка"
                failureNotification.detailsLabelText = result
                failureNotification.hide(true, afterDelay: 3)
                self.newsTableViewController.reloadData()
            }
        })
        newsTableViewController.reloadData();
        self.refreshControl?.endRefreshing();
    }

}
