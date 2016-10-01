
//
//  RCGTabBarController.swift
//  RCG Personnel
//
//  Created by iFoxxy on 08.07.16.
//  Copyright © 2016 LightBlueFox. All rights reserved.
//

import UIKit

class RCGTabBarController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabBarStyle()
    }
    
    func setTabBarStyle() {
        //Иконки задаются в storyboard, у самих картинок выставлен мод .AlwaysOriginal, чтобы они всегда были одинакового цвета - и selected и unselected
        
        let tabBarItem = UITabBarItem.appearance()
        
        //Делаем всегда белым подпись
        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        
        //Делаем цвет иконок белым
        self.tabBar.tintColor = UIColor.whiteColor()
        
        //Делаем всегда выделение текущего таба
        self.tabBar.selectionIndicatorImage = .image(
            withColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            size: CGSize(width: tabBar.frame.width / 3, height: tabBar.frame.height)
        )
        
        //Задаем цвет бэкграунда
        self.tabBar.barTintColor = UIColor(red: 232/255, green: 76/255, blue: 61/255, alpha: 1.0)
        
    }
}
