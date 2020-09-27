//
//  FollowFollowingVC.swift
//  XploreProject
//
//  Created by Dharmendra on 06/09/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class FollowFollowingVC: UIViewController {

    //MARK:- Iboutlets
    @IBOutlet weak var followFollowingTblview: UITableView!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var followerUnderLbl: UILabel!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followingUnderLbl: UILabel!
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var noDataAvailableLbl: UILabel!
    
    
    //MARK:- Variable Declarations
    var commonDataViewModel = CommonUseViewModel()
    private let followingFollowerDataViewModel = FollowerFollowingViewModel()
    var followingFollowerRefreshControl = UIRefreshControl()
    var switchType: String = switchTypeStr.showFollower.rawValue
    
    //MARK:- Inbuilt Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initailSetUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        self.followingFollowerDataViewModel.searchActive = false
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func initailSetUp() {
        self.checkSwitchType()
        self.noDataAvailableLbl.isHidden = true
        //api
         self.callAPI()
         //refresh controll
         self.refreshData()
        
    }
    
    func checkSwitchType() {
        self.followerBtn.setTitle("Followers \(Singleton.sharedInstance.followerListArr.count)", for: .normal)
        self.followingBtn.setTitle("Following \(Singleton.sharedInstance.followingListArr.count)", for: .normal)
        if self.switchType == switchTypeStr.showFollower.rawValue {
            self.followerView()
        } else {
            self.followingView()
        }
    }
    
    func followerView() {
        self.switchType = switchTypeStr.showFollower.rawValue
        self.followerBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
        self.followerUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        
        self.followingBtn.setTitleColor(UIColor.lightGray, for: .normal)
        self.followingUnderLbl.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        
        self.followingFollowerDataViewModel.tblListArr = Singleton.sharedInstance.followerListArr
        self.reloadTbl()
        
        
    }
    
    func reloadTbl() {
        self.searchBarField.text! = ""
        self.followingFollowerDataViewModel.searchedArr = []
        self.followingFollowerDataViewModel.searchActive = false
        
        if self.followingFollowerDataViewModel.tblListArr.count == 0 {
            self.noDataAvailableLbl.isHidden = false
        } else {
            self.noDataAvailableLbl.isHidden = true
        }
        
        self.followFollowingTblview.delegate = self
        self.followFollowingTblview.dataSource = self
        self.followFollowingTblview.reloadData()
    }
    
    func followingView() {
        self.switchType = switchTypeStr.showFollowings.rawValue
        self.followingBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
        self.followingUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        
        self.followerBtn.setTitleColor(UIColor.lightGray, for: .normal)
        self.followerUnderLbl.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        
        self.followingFollowerDataViewModel.tblListArr = Singleton.sharedInstance.followingListArr
        self.reloadTbl()
        
    }
    
    func refreshData() {
        self.followingFollowerRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.followingFollowerRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.followFollowingTblview.addSubview(self.followingFollowerRefreshControl)
        
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.callAPI()
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.followFollowingListAPIHit()
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
        }
    }
    
    //MARK:- Api's Hit
    func followFollowingListAPIHit(){
        let downloadGroup = DispatchGroup()
        if connectivity.isConnectedToInternet() {
            downloadGroup.enter()
            self.commonDataViewModel.getFollowerListFromAPI(actionUrl: apiUrl.followerListApiStr.rawValue) { (rMsg) in
                //self.checkSwitchType()
            }
            downloadGroup.leave()
        
            downloadGroup.enter()
            self.commonDataViewModel.getFollowerListFromAPI(actionUrl: apiUrl.followingListApiStr.rawValue) { (rMsg) in
                //self.checkSwitchType()
            }
            downloadGroup.leave()
            
            downloadGroup.notify(queue: DispatchQueue.main) {
                self.followingFollowerRefreshControl.endRefreshing()
                self.checkSwitchType()
            }
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
        }
    }
    
    //MARK:- Button Actions
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapAddCampsiteBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapFollowerBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.followerView()
    }
    
    @IBAction func tapFollowingsBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.followingView()
    }
    
}

extension FollowFollowingVC :UITableViewDataSource ,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.followingFollowerDataViewModel.searchActive == true {
            return self.followingFollowerDataViewModel.searchedArr.count
        }
        
        return  self.followingFollowerDataViewModel.tblListArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.followFollowingTblview.dequeueReusableCell(withIdentifier: "FollowFollowingTableViewCell", for: indexPath) as! FollowFollowingTableViewCell
        
        cell.followUnfollowRemoveBtn.tag = indexPath.row
        cell.followUnfollowRemoveBtn.addTarget(self, action: #selector(tapFollowFollowingRemoveBtn(sender:)), for: .touchUpInside)
        
        cell.followYourFollowingBtn.tag = indexPath.row
        cell.followYourFollowingBtn.addTarget(self, action: #selector(tapFollowMyFollwerBtn(sender:)), for: .touchUpInside)
        
        cell.profileImgBtn.tag = indexPath.row
        cell.profileImgBtn.addTarget(self, action: #selector(tapProfilePicImgBtn(sender:)), for: .touchUpInside)
       
        var indexVal: [String: Any] = [:]
        if self.followingFollowerDataViewModel.searchActive == true {
            indexVal = self.followingFollowerDataViewModel.searchedArr[indexPath.row]
        } else {
            indexVal = self.followingFollowerDataViewModel.tblListArr[indexPath.row]
        }
        cell.cellConfig(indexDict: indexVal, switchType: self.switchType)
        
        return cell
    }
    
    @objc func tapFollowMyFollwerBtn(sender: UIButton) {
        applicationDelegate.startProgressView(view: self.view)
        var indexVal: [String: Any] = [:]
        if self.followingFollowerDataViewModel.searchActive == true {
            indexVal = self.followingFollowerDataViewModel.searchedArr[sender.tag]
        } else {
            indexVal = self.followingFollowerDataViewModel.tblListArr[sender.tag]
        }
        let userId = "\(indexVal["userId"] as? Int ?? 0)"
        self.unFollowRemoveFollow(idStr: userId, addRemoveUnfollow: 1)
    }
    
    @objc func tapProfilePicImgBtn(sender: UIButton) {
        if connectivity.isConnectedToInternet() {
            
            var indexVal: [String: Any] = [:]
            if self.followingFollowerDataViewModel.searchActive == true {
                indexVal = self.followingFollowerDataViewModel.searchedArr[sender.tag]
            } else {
                indexVal = self.followingFollowerDataViewModel.tblListArr[sender.tag]
            }
            
            let userId = "\(indexVal["userId"] as? Int ?? 0)"
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.userInfoDict = indexVal as NSDictionary
            self.navigationController?.pushViewController(vc, animated: true)
              
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
        }
    }
    
    @objc func tapFollowFollowingRemoveBtn(sender: UIButton) {
        applicationDelegate.startProgressView(view: self.view)
       // let indexVal = (self.followingFollowerDataViewModel.tblListArr[sender.tag])
        
        var indexVal: [String: Any] = [:]
        if self.followingFollowerDataViewModel.searchActive == true {
            indexVal = self.followingFollowerDataViewModel.searchedArr[sender.tag]
        } else {
            indexVal = self.followingFollowerDataViewModel.tblListArr[sender.tag]
        }
        
        let userId = "\(indexVal["userId"] as? Int ?? 0)"
        if self.switchType == switchTypeStr.showFollower.rawValue {
            self.unFollowRemoveFollow(idStr: userId, addRemoveUnfollow: 2)
        } else {
            self.unFollowRemoveFollow(idStr: userId, addRemoveUnfollow: 3)
        }
    }
    
    func unFollowRemoveFollow(idStr: String, addRemoveUnfollow: Int) { //1-add, 2-remove, 3-unfollow
        if connectivity.isConnectedToInternet() {
            
            var param: [String: Any] = [:]
            var apiToBeCalled: String = ""
            
            if addRemoveUnfollow == 1 {
                apiToBeCalled = apiUrl.followApi.rawValue
                param = ["userId": "\(DataManager.userId)", "follow": idStr]
            } else if addRemoveUnfollow == 2 {
                apiToBeCalled = apiUrl.unFollowApi.rawValue
                param = ["userId": idStr, "follow": "\(DataManager.userId)"]
            } else {
                apiToBeCalled = apiUrl.unFollowApi.rawValue
                param = ["userId": "\(DataManager.userId)", "follow": idStr]
            }
            
            print(param)
            self.commonDataViewModel.followUnfollowUwser(actionUrl: apiToBeCalled, param: param) { (rMsg) in
                print(rMsg)
                applicationDelegate.dismissProgressView(view: self.view)
                self.checkSwitchType()
            }
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
        }
    }
}

//MARK: Searching
extension FollowFollowingVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.followingFollowerDataViewModel.searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.followingFollowerDataViewModel.searchActive = false
        self.followFollowingTblview.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.followingFollowerDataViewModel.searchActive = false
        self.view.endEditing(true)
        self.followFollowingTblview.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if self.searchBarField.text! == "" {
            self.followingFollowerDataViewModel.searchActive = false
            self.followFollowingTblview.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.followingFollowerDataViewModel.searchedArr = self.followingFollowerDataViewModel.tblListArr.filter {
            return ($0["name"] as! String).range(of: searchText, options: .caseInsensitive) != nil }
            
        print(self.followingFollowerDataViewModel.searchedArr)
        self.followingFollowerDataViewModel.searchActive = true
        if self.searchBarField.text! == "" {
            self.followingFollowerDataViewModel.searchActive = false
            self.followFollowingTblview.reloadData()
        }
        
        self.followFollowingTblview.reloadData()
    }
}
