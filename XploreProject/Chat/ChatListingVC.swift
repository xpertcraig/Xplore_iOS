//
//  ChatListingVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 26/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage

class ChatListingVC: UIViewController {

    //MARK:- IbOutlets
    @IBOutlet weak var chatListingTblView: UITableView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var noChatFound: UILabel!
    
    var userList = ["2","3","4","5","6","7"]
    var usersListDict:[[String:Any]] = []
    
    //MARK:- Variable Declaration
    var hasLoaded = Bool()
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.usersListDict = []
        if Singleton.sharedInstance.chatListArr.count > 0 {
            self.reloadTbl()
            
        }
        self.animateTbl()
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.observeChannels()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    //MARK:- Function Definition
    func reloadTbl() {
        self.usersListDict = Singleton.sharedInstance.chatListArr
        
        self.chatListingTblView.delegate = self
        self.chatListingTblView.dataSource = self
        self.chatListingTblView.reloadData()
    }
    
    func animateTbl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.hasLoaded = true
            self.chatListingTblView.reloadData()
            self.animateTableView()
            
        }
    }
    
    func animateTableView() {
        let leftAnimation = TableViewAnimation.Cell.left(duration: 0.5)
        self.chatListingTblView.animate(animation: leftAnimation, indexPaths: nil, completion: nil)
        
    }
    
    //MARK:- Fetch data from the firebase
    func observeChannels() {
        if (Singleton.sharedInstance.chatListArr.count == 0 && userDefault.value(forKey: chatListStr) == nil){
            applicationDelegate.startProgressView(view: self.view)
            
        }
        
        let ref = Database.database().reference()
        ref.child("Users").observe(.childAdded, with: { (shot) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                
              //  print(postDict)
                
                if (postDict["userId"]) != nil {
                   // self.usersListDict = []
                    
                    if String(describing: (postDict["userId"])!) == String(describing: (DataManager.userId)) || String(describing: (postDict["othersUserId"])!) == String(describing: (DataManager.userId)) {
                        self.usersListDict.append(postDict)
                        
                    }
                    Singleton.sharedInstance.chatListArr = self.usersListDict
                    
                    self.chatListingTblView.delegate = self
                    self.chatListingTblView.dataSource = self
                    self.chatListingTblView.reloadData()
                }
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            applicationDelegate.dismissProgressView(view: self.view)
            
        }
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
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
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension ChatListingVC :UITableViewDataSource ,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.usersListDict.count == 0 {
            self.noChatFound.isHidden = false
            self.chatListingTblView.isHidden = true
            
        } else {
            self.noChatFound.isHidden = true
            self.chatListingTblView.isHidden = false
            
        }
        
      //  print(self.usersListDict.count)
        return self.usersListDict.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
//        cell.textLabel?.text = userList[indexPath.row]
//        return cell
        
        let cell = self.chatListingTblView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        
     //   print(self.usersListDict[indexPath.row] as NSDictionary)
        
        if String(describing: (DataManager.userId)) == String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "userId"))!) {
            cell.userNameLbl.text! = String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "otherUsername"))!)
            
            cell.userImgView.sd_setShowActivityIndicatorView(true)
            cell.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.userImgView.sd_setImage(with: URL(string: String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "otherUserProfileImage"))!)), placeholderImage: UIImage(named: ""))
            
        } else {
            cell.userNameLbl.text! = String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "username"))!)
            
            cell.userImgView.sd_setShowActivityIndicatorView(true)
            cell.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.userImgView.sd_setImage(with: URL(string: String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "userProfileImage"))!)), placeholderImage: UIImage(named: ""))
            
        }
        
        cell.notificationTxtLbl.text! = String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "last_msg"))!)
        
        if (String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "last_msgTime"))!)) != "" {
            cell.notificationTimeLbl.text! = CommonFunctions.changeUNXTimeStampToTIme(recUnxTimeStamp: (Double(String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "last_msgTime"))!))!))
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if String(describing: (DataManager.userId)) == String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "userId"))!) {
            chatVC.receiverId = String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "othersUserId"))!)
            
        } else {
            chatVC.receiverId = String(describing: ((self.usersListDict[indexPath.row] as NSDictionary).value(forKey: "userId"))!)
            
        }
        chatVC.comeFrom = "ChatListing"
        chatVC.userInfoDict = (self.usersListDict[indexPath.row] as NSDictionary)
        
        self.navigationController?.pushViewController(chatVC, animated: true)
      
    }
}
