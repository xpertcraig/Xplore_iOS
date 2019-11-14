//
//  ChatListVC.swift
//  NewAppDemo
//
//  Created by OSX on 11/01/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage

class ChatListCell:UITableViewCell
{
    
}

class ChatListVC: UIViewController,UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var chatListTblVw: UITableView!
    
    //MARK:- Variables
    var userList = ["2","3","4","5","6","7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.observeChannels()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    //MARK:- Fetch data from the firebase
    func observeChannels() {
       
        let ref = Database.database().reference()
        
        ref.child("Users").observe(.childAdded, with: { (shot) in
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                
            //    print(postDict)
                
            }
        })
    }
    
    //MARK:- Tableview Datasources
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        cell.textLabel?.text = userList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    //MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.receiverId = userList[indexPath.row]
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

}
