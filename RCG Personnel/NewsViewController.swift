//
//  NewsViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 18.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class NewsViewController: BaseTableViewController {

    @IBOutlet var newsTableViewController: UITableView!
    let newsReceiver = NewsReceiver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        //MARK: Убираем прозрачность таббара и навбара
        self.navigationItem.title = "ЛЕНТА НОВОСТЕЙ";
        self.navigationController?.navigationBar.translucent = false;
        self.tabBarController?.tabBar.translucent = false;
        
        setTabBarIcons()
        setCellsStyle()
        addPullToRefresh()
        refreshWithProgressHUD(self)
    }
    
    
    
    func setTabBarIcons() {
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
        
        let tabItem2 = tabItems![2] ;
        tabItem2.image = UIImage(named:"feedBack")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        tabItem2.selectedImage = UIImage(named:"feedBackSelected")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
    }
    
    func addPullToRefresh() {
        //MARK: Описываем пул-ту-рефреш
        self.refreshControl = UIRefreshControl();
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Потяните вниз, чтобы обновить", attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 12)!, NSForegroundColorAttributeName:UIColor.whiteColor()])
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func setCellsStyle() {
        //MARK: задаем стиль ячеек
        self.newsTableViewController.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        self.newsTableViewController.rowHeight = 210
        self.newsTableViewController.separatorStyle = .None
    }
    
    func refresh(sender:AnyObject) {
        self.newsReceiver.getAllNews({(success: Bool, result: String) in
            if !success
            {
                let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                failureNotification.mode = MBProgressHUDMode.Text
                failureNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
                failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                failureNotification.labelText = "Ошибка"
                failureNotification.detailsLabelText = result
                failureNotification.hide(true, afterDelay: 3)
            }
        })
        newsTableViewController.reloadData();
        self.refreshControl?.endRefreshing();
    }
    
    func refreshWithProgressHUD(sender:AnyObject) {
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружаются новости
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4);
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        self.newsReceiver.getAllNews({(success: Bool, result: String) in
            if success {
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
            self.newsTableViewController.reloadData()
        })
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
        return newsReceiver.newsStack.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.newsTableViewController.dequeueReusableCellWithIdentifier("NewsCell") as! NewsCell
        // Configure the cell...
        let currentNews = newsReceiver.newsStack[indexPath.row];
        
        cell.dateDay?.text = currentNews.addedDate.dayFromDdMmYyyy
        cell.dateMonthYear?.text = currentNews.addedDate.monthYearFromDdMmYyyy
        cell.newsTitle?.text = currentNews.topic
        cell.newsAnnounce?.text = currentNews.fullText
        cell.newsCellImageView.clipsToBounds = true
        cell.newsCellImageView.contentMode = UIViewContentMode.ScaleAspectFill
        if currentNews.icons.isEmpty {
            cell.newsCellImageView?.image = UIImage(named: "noimage")
        }
        else {
            cell.newsCellImageView?.sd_setImageWithURL(NSURL(string: currentNews.icons[0]))
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        let newsViewController =  segue.destinationViewController as! SingleNewsViewController
        
        //sender is a tapped NewsCellViewController
        let cell = sender as! NewsCell
        let indexPath = self.newsTableViewController.indexPathForCell(cell);
        let currentNews = self.newsReceiver.newsStack[indexPath!.row];
        newsViewController.newsGuid = currentNews.guid
        
    }
}
