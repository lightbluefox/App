
//
//  VacanciesViewController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 22.02.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class VacanciesViewController : BaseTableViewController {

    @IBOutlet var vacanciesTableViewController: UITableView!
    var vacanciesReceiver = VacanciesReceiver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Убираем прозрачность таббара и навбара, т.к. за счет прозрачонсти цвет становится не тем.
        self.navigationItem.title = "ЛЕНТА ВАКАНСИЙ"
        self.navigationController?.navigationBar.translucent = false
        self.tabBarController?.tabBar.translucent = false
        
        self.parentViewController?.view.backgroundColor = UIColor(patternImage: UIImage(named: "rightBackGround")!)
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        //self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "rightBackGround")!)

        self.vacanciesTableViewController.rowHeight = 80
        
        addPullToRefresh()
        refreshWithProgressHUD(self)
    }
    
    private func addPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Потяните вниз, чтобы обновить", attributes: [NSFontAttributeName:UIFont(name: "Roboto", size: 12)!, NSForegroundColorAttributeName:UIColor.whiteColor()])
        self.refreshControl?.addTarget(self, action: #selector(VacanciesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        let loadingNotification = showLoadingNotification()
        
        self.vacanciesReceiver.getAllVacs { (success: Bool, result: String) in
            
            if success
            {
                loadingNotification.hide(true)
            }
            else
            {
                loadingNotification.hide(true)
                self.showFailureNotification(result)
            }
            self.vacanciesTableViewController.reloadData();
            self.refreshControl?.endRefreshing();
        }
    }
    
    private func showLoadingNotification() -> AnyObject {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        loadingNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        loadingNotification.labelText = "Загрузка"
        
        return loadingNotification
    }
    private func showFailureNotification(result: String) {
        
        let failureNotification = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        failureNotification.mode = MBProgressHUDMode.Text
        failureNotification.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        failureNotification.labelFont = UIFont(name: "Roboto Regular", size: 12)
        failureNotification.labelText = "Ошибка"
        failureNotification.detailsLabelText = result
        failureNotification.hide(true, afterDelay: 3)
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
        cell.backgroundColor = UIColor.clearColor()
        // Получаем разницу в днях между сроком валидности вакансии и в зависимости от нее выводим разные сообщения в ячейке
        let currentDate = NSDate().gmc0
        let validTillDate = NSDate(timeIntervalSince1970: Double(currentVac.validTillDate)!/1000)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate: calendar.startOfDayForDate(currentDate), toDate: calendar.startOfDayForDate(validTillDate), options: [])

        if components.day == 2 {
            cell.vacancyDate?.text = "Осталось 2 дня!"
            cell.vacancyDate?.textColor = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1)
        }
        else if components.day <= 1 {
            cell.vacancyDate?.text = "Последний день!"
            cell.vacancyDate?.textColor = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1)
        }
        else {
            cell.vacancyDate?.text = "Набор до: " + currentVac.validTillDate.formatedDate
            cell.vacancyDate?.textColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
        }
        
        cell.vacancyTitle?.text = currentVac.topic;
        if currentVac.icons.isEmpty
        {
            cell.vacancyCellAnnounceImage.image = UIImage(named: "noimage")!
            cell.vacancyCellAnnounceImage.layer.cornerRadius = 3.0
            cell.vacancyCellAnnounceImage.layer.masksToBounds = true
        }
        else
        {
            cell.vacancyCellAnnounceImage.sd_setImageWithURL(NSURL(string: currentVac.icons[0]))
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
        
    }
}
