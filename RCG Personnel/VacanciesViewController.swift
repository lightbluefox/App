
//
//  VacanciesViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class VacanciesViewController : UITableViewController {

    @IBOutlet var vacanciesTableViewController: UITableView!
    var vacanciesReceiver = VacanciesReceiver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Убираем прозрачность таббара и навбара, т.к. за счет прозрачонсти цвет становится не тем.
        self.navigationItem.title = "ЛЕНТА ВАКАНСИЙ"
        self.navigationController?.navigationBar.translucent = false
        self.tabBarController?.tabBar.translucent = false
        
        self.vacanciesTableViewController.rowHeight = 80
        
        addPullToRefresh()
        refreshWithProgressHUD(self)
        
    }
    
    private func addPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Потяните вниз, чтобы обновить", attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 12)!, NSForegroundColorAttributeName:UIColor.blackColor()])
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        vacanciesTableViewController.reloadData();
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return vacanciesReceiver.vacsStack.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.vacanciesTableViewController.dequeueReusableCellWithIdentifier("VacancyCell") as! VacancyCell
        // Configure the cell...
        let currentVac = vacanciesReceiver.vacsStack[indexPath.row];
        
        cell.vacancyTitle?.text = currentVac.topic;
        cell.vacancyDate?.text = currentVac.validTillDate.formatedDate;
        if currentVac.previewImageGuid != ""
        {
            cell.vacancyCellAnnounceImage.sd_setImageWithURL(NSURL(string: currentVac.previewImageGuid))
            cell.vacancyCellAnnounceImage.layer.cornerRadius = 3.0
            cell.vacancyCellAnnounceImage.layer.masksToBounds = true
        }
        else
        {
            cell.vacancyCellAnnounceImage.image = UIImage(named: "noimage")!
            cell.vacancyCellAnnounceImage.layer.cornerRadius = 3.0
            cell.vacancyCellAnnounceImage.layer.masksToBounds = true
        }
        
        switch currentVac.sex {
        case "male" : cell.vacancyFemaleImage?.image = UIImage(named: "femaleGray"); cell.vacancyMaleImage?.image = UIImage(named: "maleRed");
        case "female" : cell.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); cell.vacancyMaleImage?.image = UIImage(named: "maleGray");
        case "both" : cell.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); cell.vacancyMaleImage?.image = UIImage(named: "maleRed");
        default : cell.vacancyFemaleImage?.image = UIImage(named: "femaleRed"); cell.vacancyMaleImage?.image = UIImage(named: "maleRed");
        }
        
        cell.vacancyShortText?.text = currentVac.shortText;
        cell.vacancyMoney?.text = currentVac.money;
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        let vacancyViewController = segue.destinationViewController as! SingleVacancyViewController
        // Pass the selected object to the new view controller.
        let cell = sender as! VacancyCell
        
        let indexPath = self.vacanciesTableViewController.indexPathForCell(cell)
        let currentVac = self.vacanciesReceiver.vacsStack[indexPath!.row]
        vacancyViewController.vacGuid = currentVac.guid
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        navigationItem.backBarButtonItem = backButtonItem
    }
    
    func refresh(sender:AnyObject) {
        self.vacanciesReceiver.getAllVacs { (success: Bool, result: String) in
            if !success
            {
                let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                failureNotification.mode = MBProgressHUDMode.Text
                failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                failureNotification.labelText = "Ошибка"
                failureNotification.detailsLabelText = result
                failureNotification.hide(true, afterDelay: 3)
            }
            
            self.refreshControl?.endRefreshing();
        }
    }
    func refreshWithProgressHUD(sender: AnyObject) {
        //MARK: используя MBProgressHUD делаем экран загрузки, пока подгружаются вакансии
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        
        self.vacanciesReceiver.getAllVacs { (success: Bool, result: String) in
            
            if success
            {
                loadingNotification.hide(true)
            }
            else
            {
                loadingNotification.hide(true)
                
                let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
                failureNotification.mode = MBProgressHUDMode.Text
                failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
                failureNotification.labelText = "Ошибка"
                failureNotification.detailsLabelText = result
                failureNotification.hide(true, afterDelay: 3)
            }
            self.vacanciesTableViewController.reloadData();
            self.refreshControl?.endRefreshing();
        }
    }
}
