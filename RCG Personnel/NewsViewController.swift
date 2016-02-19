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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Убираем прозрачность таббара и навбара
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
        
        
        self.newsTableViewController.backgroundColor = UIColor(colorLiteralRed: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        self.newsTableViewController.rowHeight = 210

    }
}
