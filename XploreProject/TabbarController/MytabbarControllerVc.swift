//
//  MytabbarControllerVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MytabbarControllerVc: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.tabBarController?.selectedIndex = tabBarController.selectedIndex
        
        if (self.navigationController?.topViewController == self) {
            //the view is currently displayed
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(tabBar.selectedItem)
        
        
    }
    
}
