//
//  HelpVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 17/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class HelpVC: UIViewController {
    
    //MARK:- Iboutlets
    @IBOutlet weak var helpTxtView: UITextView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Inbuild FUnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        //api
        self.callAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.helpAPIHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    //MARK:- Api's Hit
    func helpAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "help.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    self.helpTxtView.text! = (dict["result"]! as! String)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapAddCampsiteBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
}
