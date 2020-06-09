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
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var noChatFound: UILabel!
    
    var userList = ["2","3","4","5","6","7"]
    var usersListDict:[[String:Any]] = []
    
    //MARK:- Variable Declaration
    var hasLoaded = Bool()
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noChatFound.isHidden = true
        self.chatListingTblView.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.usersListDict = []
        if Singleton.sharedInstance.chatListArr.count > 0 {
            self.noChatFound.isHidden = true
            self.reloadTbl()
            
        }
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        self.observeChannels()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotiCount(_:)), name: NSNotification.Name(rawValue: "notificationRec"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil);
    }
    
    //MARK:- Function Definitions
    @objc func updateNotiCount(_ notification: NSNotification) {
        if let notiCount = notification.userInfo?["count"] as? Int {
            // An example of animating your label
            self.notificationCountLbl.animShow()
            if notiCount > 9 {
                self.notificationCountLbl.text! = "\(9)+"
            } else {
                self.notificationCountLbl.text! = "\(notiCount)"
            }
        }
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
        let leftAnimation = TableViewAnimation.Cell.left(duration: 1.0)
        self.chatListingTblView.animate(animation: leftAnimation, indexPaths: nil, completion: nil)
        
    }
    
    //MARK:- Fetch data from the firebase
    func observeChannels() {
        if (Singleton.sharedInstance.chatListArr.count == 0 && userDefault.value(forKey: chatListStr) == nil){
            applicationDelegate.startProgressView(view: self.view)
            
        }
        self.chatListingTblView.delegate = self
        self.chatListingTblView.dataSource = self
        
        var tempArr: [[String: AnyObject]] = []
        
        let ref = Database.database().reference()
        ref.child("Users").observe(.value) { (snapShot) in
            if snapShot.value as? Dictionary<String, AnyObject> == nil {
                self.chatListingTblView.isHidden = true
                self.noChatFound.isHidden = false
                applicationDelegate.dismissProgressView(view: self.view)
            }
        }
        ref.child("Users").observe(.childAdded, with: { (shot) in
            applicationDelegate.dismissProgressView(view: self.view)
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                
            //    print(postDict)
                
                if (postDict["userId"]) != nil {
                   // self.usersListDict = []
                    
                    if String(describing: (postDict["userId"])!) == String(describing: (DataManager.userId)) || String(describing: (postDict["othersUserId"])!) == String(describing: (DataManager.userId)) {
                        
                        tempArr.append(postDict)
                        
                        if let _ = tempArr.last?["last_msgTime"] as? Int {
                            let a = NSArray.init(array: tempArr)
                            let filArray = a.discendingArrayWithKeyValue(key: "last_msgTime")
                            
                            self.usersListDict = filArray as! [[String : Any]]
                            
                        } else {
                            self.usersListDict = tempArr
                            
                        }
                        
                        Singleton.sharedInstance.chatListArr = self.usersListDict
                        self.chatListingTblView.delegate = self
                        self.chatListingTblView.dataSource = self
                        self.chatListingTblView.reloadWithAnimation()
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
//                            self.animateTbl()
//                        }
                    }
                } else {
                    self.noChatFound.isHidden = false
                }
            } else {
                self.noChatFound.isHidden = false
            }
            
        })
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
            //self.noChatFound.isHidden = false
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
        let cell = self.chatListingTblView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        
        cell.cellConfig(indexV: (self.usersListDict[indexPath.row] as NSDictionary))
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


extension NSArray{
    //sorting- ascending
    func ascendingArrayWithKeyValue(key:String) -> NSArray{
        let ns = NSSortDescriptor.init(key: key, ascending: true)
        let aa = NSArray(object: ns)
        let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }
    
    //sorting - descending
    func discendingArrayWithKeyValue(key:String) -> NSArray{
        print(key)
        
        let ns = NSSortDescriptor.init(key: key, ascending: false)
        let aa = NSArray(object: ns)
        let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
        return arrResult as NSArray
    }
}
