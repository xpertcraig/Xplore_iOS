//
//  NotificationVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class NotificationVc: UIViewController {
    
    //MARK:- Iboutlets
    @IBOutlet weak var notificationTableview: UITableView!
    @IBOutlet weak var noNotificationLbl: UILabel!
    
    @IBOutlet weak var clearNotiBtn: UIButton!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variable DEclarations
    var hasLoaded = Bool()
    var myNotificationsArr: NSArray = []
    ///
    var notificationRefreshControl = UIRefreshControl()
    
    //MARK:- Inbuild functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        //api
        self.callAPI()
       
        //refresh controll
        self.refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Singleton.sharedInstance.notificationListingArr.count > 0 {
            self.reloadTbl()
            
        }
        self.animateTbl()
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func reloadTbl() {
        self.myNotificationsArr = Singleton.sharedInstance.notificationListingArr
        self.notificationCountLbl.text! = "0"
        notificationCount = 0
        
        self.notificationTableview.delegate = self
        self.notificationTableview.dataSource = self
        self.notificationTableview.reloadData()
    }
    
    func refreshData() {
        self.notificationRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.notificationRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.notificationTableview.addSubview(self.notificationRefreshControl)
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.callAPI()
        
    }
    
    func animateTbl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.hasLoaded = true
            self.notificationTableview.reloadData()
            self.animateTableView()
            
        }
    }
    
    func animateTableView() {
        let leftAnimation = TableViewAnimation.Cell.left(duration: 1.0)
        self.notificationTableview.animate(animation: leftAnimation, indexPaths: nil, completion: nil)
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.notificationsAPIHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    //MARK:- Api's Hit
    func notificationsAPIHit(){
        if (Singleton.sharedInstance.notificationListingArr.count == 0 && userDefault.value(forKey: notificationListingStr) == nil){
            applicationDelegate.startProgressView(view: self.view)
            
        }
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "notifications.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            self.notificationRefreshControl.endRefreshing()
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    
                    self.notificationCountLbl.text! = "0"
                    notificationCount = 0
                    
                    self.myNotificationsArr = dict["result"] as! NSArray
                    Singleton.sharedInstance.notificationListingArr = self.myNotificationsArr
                    
                    self.notificationTableview.reloadData()
                    
                } else {
                   // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
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
    
    func removePerticularNotificationsAPIHit(notiId: String){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "deleteNotifications.php?userId=" + (DataManager.userId as! String)+"&notificationId="+notiId, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                 //   print(dict)
                    
                    self.notificationsAPIHit()
                    
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

    func clearAllNotificationsAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "clearallnotifications.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                   
                    self.myNotificationsArr = []
                    self.notificationTableview.reloadData()
                   
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
    @IBAction func tapClearAllNotifications(_ sender: Any) {
        let alert = UIAlertController(title: appName, message: sureClearNoti, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            if connectivity.isConnectedToInternet() {
                self.clearAllNotificationsAPIHit()
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
    
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
    
    @objc func removePerticularNotification(sender: UIButton) {
        let alert = UIAlertController(title: appName, message: sureClearSingleNoti, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            if connectivity.isConnectedToInternet() {
                self.removePerticularNotificationsAPIHit(notiId: String(describing: ((self.myNotificationsArr.object(at: sender.tag) as! NSDictionary).value(forKey: "notificationId"))!))
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
}

extension NotificationVc :UITableViewDataSource ,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.myNotificationsArr.count == 0 {
            self.notificationTableview.isHidden = true
            self.noNotificationLbl.isHidden = false
            
            self.clearNotiBtn.layer.opacity = 0.2
            
            self.clearNotiBtn.isUserInteractionEnabled = false
        } else {
            self.notificationTableview.isHidden = false
            self.noNotificationLbl.isHidden = true
            
            self.clearNotiBtn.layer.opacity = 1.0
            self.clearNotiBtn.isUserInteractionEnabled = true
        }
       return  self.myNotificationsArr.count
        
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 75
//
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        
        cell.removeNotificationBtn.tag = indexPath.row
        cell.removeNotificationBtn.addTarget(self, action: #selector(removePerticularNotification(sender:)), for: .touchUpInside)
        
        let image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
        cell.removeNotificationBtn.setImage(image, for: .normal)
        cell.removeNotificationBtn.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
        
        cell.userImgView.sd_setShowActivityIndicatorView(true)
        cell.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        cell.userImgView.sd_setImage(with: URL(string: (String(describing: (((self.myNotificationsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "userImage") as! String))))), placeholderImage: UIImage(named: ""))
        
        if let name = ((self.myNotificationsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "userName") as? String) {
            cell.userNameLbl.text! = name
            
        } else {
            cell.userNameLbl.text! = ""
            
        }
        
        cell.notificationTxtLbl.text! = (String(describing: (((self.myNotificationsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "message") as! String))))
        cell.notificationTimeLbl.text! =  convertNotiDateFormater(String(describing: (((self.myNotificationsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "notificationDate") as! String))))
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
        vc.campId = (String(describing: (((self.myNotificationsArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId") as! String))))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
