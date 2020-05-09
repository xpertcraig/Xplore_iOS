//
//  MytabbarControllerVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MytabbarControllerVc: UITabBarController, UITabBarControllerDelegate {

    var selectedItem: String = ""
    var selectedItemImg: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if DataManager.isUserLoggedIn! == false {
//            if let arrayOfTabBarItems = self.tabBar.items as AnyObject as? NSArray,let
//               tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
//               tabBarItem.isEnabled = false
//            }
//        }
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.navigationController?.tabBarController?.selectedIndex = tabBarController.selectedIndex
        
        if (self.navigationController?.topViewController == self) {
            //the view is currently displayed
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //print(tabBar.selectedItem)
        
        self.selectedItem = tabBar.selectedItem!.title!
        self.selectedItemImg = tabBar.selectedItem!.selectedImage!
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if DataManager.isUserLoggedIn! == false {
            if self.selectedItemImg!.isEqualToImage(image: UIImage(named: "SavedCampsite")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "mycampsite-1")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "settingSelect")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "SavedSelect")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "MyCampsite")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "setting")!) {
                
                let alert = UIAlertController(title: appName, message: loginRequired, preferredStyle: .alert)
                let yesBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                    
                    if self.selectedItemImg!.isEqualToImage(image: UIImage(named: "SavedCampsite")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "SavedSelect")!) {
                        tabBarController.selectedIndex = 2
                        
                    } else if self.selectedItemImg!.isEqualToImage(image: UIImage(named: "MyCampsite")!) || self.selectedItemImg!.isEqualToImage(image: UIImage(named: "mycampsite-1")!) {
                        tabBarController.selectedIndex = 3
                        
                    } else {
                        tabBarController.selectedIndex = 4
                        
                    }
                })
                
                let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(yesBtn)
                alert.addAction(noBtn)
                present(alert, animated: true, completion: nil)
                
                return false
            }
        }
        return true
    }
}
