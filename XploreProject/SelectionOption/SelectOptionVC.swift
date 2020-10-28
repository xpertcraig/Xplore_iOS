//
//  SelectOptionVC.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

// set up protocol
@objc protocol selectTypeDelegate{
    func selectType(campName: String, campIds: NSArray, key: String)
    
}

class SelectOptionVC: UIViewController {
    
    //MARK:- Inbuild Functions
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var optionTableView: UITableView!
    @IBOutlet weak var selectionHeader: UILabel!
    @IBOutlet weak var selectOptionTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarTxtFld: UISearchBar!
    @IBOutlet weak var seacrhBarHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var noDataFound: UILabel!
    
 //   var tableViewArray = NSDictionary()
    var selectedArray: NSMutableArray = []
    var key: String = ""
    var tableArr: NSArray = []
    var typeNameArr: NSMutableArray = []
    var typeIdArr: NSMutableArray = []
    
    var setCampNameIfAvailable: String = ""
    var arrFromAlreadyStr: NSArray = []
    
    var campTypeIdsArr: NSArray = []
    var campAmentiesArr: NSArray = []
    var campHookupsArr: NSArray = []
    private let followingFollowerDataViewModel = FollowerFollowingViewModel()
    
    // this is where wevarclare our protocol
    var delegate:selectTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        if setCampNameIfAvailable != "" {
            self.setCampNameIfAvailable = self.setCampNameIfAvailable.replacingOccurrences(of: ", ", with: ",")
            
            self.arrFromAlreadyStr = self.setCampNameIfAvailable.split{$0 == ","}.map(String.init) as NSArray
        }
        
        self.optionTableView.tableFooterView = UIView()
        self.selectionHeader.text = key
       
        self.noDataFound.isHidden = true
        self.doneBtn.isHidden = true
        self.seacrhBarHeight.constant = 0
        self.searchBarTxtFld.isHidden = true
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.darkGray
//        let textFieldInsideSearchBar = self.searchBarTxtFld.value(forKey: "searchField") as? UITextField
//        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
        //call Api's
        self.callApiOnDifferentCond()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.followingFollowerDataViewModel.searchActive = false
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotiCount(_:)), name: NSNotification.Name(rawValue: "notificationRec"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        if self.optionTableView.contentSize.height > self.view.frame.height - 300 {
            self.selectOptionTblHeight?.constant = self.view.frame.height - 320
        } else {
            self.selectOptionTblHeight?.constant = self.optionTableView.contentSize.height + 5
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        self.tabBarController?.tabBar.isHidden = false
        self.followingFollowerDataViewModel.searchActive = false
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
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func callApiOnDifferentCond() {
        if connectivity.isConnectedToInternet() {
            if key == "Select Type" {
                self.tableArr = typeArr
                if self.tableArr.count == 0 {
                    self.campTypeApi()
                    
                } else {
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                   
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if String(describing: ((self.tableArr.object(at: i) as! NSDictionary).value(forKey: "typeName"))!) == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campTypeIdsArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "typeName") as! String)
                                
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    self.optionTableView.reloadData()
                    self.optionTableView.layoutIfNeeded()
                    
                }
            } else if key == "Select Amenities" {
                self.seacrhBarHeight.constant = 55
                self.searchBarTxtFld.isHidden = false
                
                self.tableArr = amentiesArr
                if self.tableArr.count == 0 {
                    self.amentiesApi()
                    
                } else {
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                    
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "amenitiesName") as! String == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campAmentiesArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "amenitiesName") as! String)
                                
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    
                    self.optionTableView.reloadData()
                    self.optionTableView.layoutIfNeeded()
                    
                }
            } else if key == "Select Hookups" {
                self.tableArr = hookupArr
                if self.tableArr.count == 0 {
                    self.selectHookupsApi()
                    
                } else {
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                    
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "hookupName") as! String == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campHookupsArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "hookupName") as! String)
                                
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    self.optionTableView.reloadData()
                    self.optionTableView.layoutIfNeeded()
                    
                }
            } else if key == "Select Months" {
                self.tableArr = ["January","February","March","April","May","June","July","August","September","October","November","December"]
                
                for _ in 0..<self.tableArr.count {
                    self.selectedArray.add(0)
                    self.typeIdArr.add("0")
                    self.typeNameArr.add(0)
                    
                }
                
                for i in 0..<self.tableArr.count {
                    for j in 0..<self.arrFromAlreadyStr.count {
                        if (self.tableArr.object(at: i) as! String) == self.arrFromAlreadyStr.object(at: j) as! String {
                            self.selectedArray.replaceObject(at: i, with: 1)
                            self.typeIdArr.replaceObject(at: i, with: (self.tableArr.object(at: j) as! String))
                            self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! String))
                            
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.doneBtn.isHidden = false
                }
                self.optionTableView.reloadData()
                self.optionTableView.layoutIfNeeded()
                
            }
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            
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
    
    @IBAction func tapDoneBtn(_ sender: UIButton) {
        let sum = self.selectedArray.reduce(0)  { Int($0) + Int(String(describing: ($1)))! }
        
     //   print(sum)
        
        if sum == 0 {
            CommonFunctions.showAlert(self, message: selectOneAlert, title: appName)
            
        }
        
        var nameStr: String = ""
        let idStr: NSMutableArray = []
                
        for i in 0..<self.selectedArray.count {
            if self.selectedArray.object(at: i) as? Int == 0 {
                
            } else {
                nameStr.append(self.typeNameArr.object(at: i) as! String)
                nameStr.append(", ")
                idStr.add(String(describing: (self.typeIdArr.object(at: i))))
                
            }
        }
        
        if nameStr != "" {
            nameStr.removeLast()
            
        }
        
        delegate?.selectType(campName: nameStr, campIds: idStr, key: key)
        self.navigationController?.popViewController(animated: true)
        
    }
}

//MARK: Tableview delegate
extension SelectOptionVC: UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.followingFollowerDataViewModel.searchActive == true {
            return self.followingFollowerDataViewModel.searchedArr.count
        }
//        if self.tableArr.count > 0 {
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//                self.doneBtn.isHidden = false
//            }
//        }
        return self.tableArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.optionTableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! MenuTableViewCell
        
        //print (self.tableArr)
       // let array = tableViewArray.value(forKey: key) as! NSArray
        if key == "Select Type" {
            cell.settingTitleLabel.text = (self.tableArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "typeName") as? String
            
        } else if key == "Select Amenities" {
            if self.followingFollowerDataViewModel.searchActive == true {
                if self.followingFollowerDataViewModel.searchedArr.count > 0 {
                    cell.settingTitleLabel.text = self.followingFollowerDataViewModel.searchedArr[indexPath.row]["amenitiesName"] as? String
                }
            } else {
                cell.settingTitleLabel.text = (self.tableArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "amenitiesName") as? String
            }
        } else if key == "Select Hookups" {
            cell.settingTitleLabel.text = (self.tableArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "hookupName") as? String
            
        }  else if key == "Select Months" {
            cell.settingTitleLabel.text = (self.tableArr.object(at: indexPath.row) as! String)
            
        }
        
        cell.selectButton.tag = indexPath.row
        cell.selectButton.addTarget(self, action:#selector(buttonPressed(_:)), for:.touchUpInside)
        
        if self.followingFollowerDataViewModel.searchActive == true {
            if self.followingFollowerDataViewModel.searchedCheckUncheckedArr.count > 0 {
                if self.followingFollowerDataViewModel.searchedCheckUncheckedArr[indexPath.row] == 0 {
                    cell.selectButton.isSelected = false
                } else {
                    cell.selectButton.isSelected = true
                }
            } else {
                cell.selectButton.isSelected = false
            }
        } else {
            if self.selectedArray.object(at: indexPath.row) as? Int == 0 {
                cell.selectButton.isSelected = false
                
            } else {
                cell.selectButton.isSelected = true
                
            }
        }
        return cell
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        if self.followingFollowerDataViewModel.searchActive == true {
            if self.followingFollowerDataViewModel.searchedCheckUncheckedArr[sender.tag] == 0 {
                self.followingFollowerDataViewModel.searchedCheckUncheckedArr[sender.tag] = 1
                for i in 0..<self.tableArr.count {
                    if String(describing: (self.followingFollowerDataViewModel.searchedArr[sender.tag]["amenitiesId"])!) == String(describing: ((self.tableArr[i] as! [String: Any])["amenitiesId"])!) {
                        self.selectedArray.replaceObject(at: i, with: 1)
                        
                        self.typeNameArr.replaceObject(at: i, with: (self.followingFollowerDataViewModel.searchedArr[sender.tag]["amenitiesName"] as! String))
                        self.typeIdArr.replaceObject(at: i, with: String(describing: (self.followingFollowerDataViewModel.searchedArr[sender.tag]["amenitiesId"])!))
                    }
                }
            } else {
                self.followingFollowerDataViewModel.searchedCheckUncheckedArr[sender.tag] = 0
                self.selectedArray.replaceObject(at: sender.tag, with: 0)
                self.typeNameArr.replaceObject(at: sender.tag, with: 0)
                self.typeIdArr.replaceObject(at: sender.tag, with: "0")
            }
        } else {
            if self.selectedArray.object(at: sender.tag) as? Int == 0 {
                self.selectedArray.replaceObject(at: sender.tag, with: 1)
                if key == "Select Type" {
                    self.typeNameArr.replaceObject(at: sender.tag, with: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "typeName") as! String))
                    self.typeIdArr.replaceObject(at: sender.tag, with: String(describing: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "typeId"))!))
                    
                } else if key == "Select Amenities" {
                    self.typeNameArr.replaceObject(at: sender.tag, with: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "amenitiesName") as! String))
                    self.typeIdArr.replaceObject(at: sender.tag, with: String(describing: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "amenitiesId"))!))
                } else if key == "Select Hookups" {
                  //  print((self.tableArr.object(at: sender.tag) as! NSDictionary))
                    
                    self.typeNameArr.replaceObject(at: sender.tag, with: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "hookupName") as! String))
                    self.typeIdArr.replaceObject(at: sender.tag, with: String(describing: ((self.tableArr.object(at: sender.tag) as! NSDictionary).value(forKey: "hookupId"))!))
                    
                } else if key == "Select Months" {
                    self.typeNameArr.replaceObject(at: sender.tag, with: (self.tableArr.object(at: sender.tag) as! String))
                    self.typeIdArr.replaceObject(at: sender.tag, with: (self.tableArr.object(at: sender.tag) as! String))
                    
                }
            } else {
                self.selectedArray.replaceObject(at: sender.tag, with: 0)
                self.typeNameArr.replaceObject(at: sender.tag, with: 0)
                self.typeIdArr.replaceObject(at: sender.tag, with: "0")
                
            }
        }
        self.optionTableView.reloadData()
        self.optionTableView.layoutIfNeeded()
    }
}

//MARK:- API's
extension SelectOptionVC {
    func campTypeApi() {
        applicationDelegate.startProgressView(view: self.view)
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "campsiteType.php/?userId="+String(describing: (DataManager.userId)), onSuccess: { (responseData) in
              applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    //print(retValues)
                    self.tableArr = retValues
                    typeArr = self.tableArr
                    
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                    
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "typeName") as! String == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campTypeIdsArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "typeName") as! String)
                                
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    self.optionTableView.reloadData()
                   // self.selectOptionTblHeight.constant = self.optionTableView.contentSize.height + CGFloat(self.tableArr.count)
                    self.optionTableView.layoutIfNeeded()
                    
                } else {
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                //  CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                
            }
        }
    }
    
    func amentiesApi() {
        applicationDelegate.startProgressView(view: self.view)
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "campsiteAmenities.php/?userId="+String(describing: (DataManager.userId)), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                   // print(retValues)
                    self.tableArr = retValues
                    amentiesArr = self.tableArr
                    
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                    
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "amenitiesName") as! String == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campAmentiesArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "amenitiesName") as! String)
                                
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    self.optionTableView.reloadData()
                    self.optionTableView.layoutIfNeeded()
                    
                } else {
                   
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                //  CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func selectHookupsApi() {
        applicationDelegate.startProgressView(view: self.view)
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "campsiteHookups.php/?userId="+String(describing: (DataManager.userId)), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
               //     print(retValues)
                    self.tableArr = retValues
                    hookupArr = self.tableArr
                    
                    for _ in 0..<self.tableArr.count {
                        self.selectedArray.add(0)
                        self.typeIdArr.add("0")
                        self.typeNameArr.add(0)
                        
                    }
                    
                    for i in 0..<self.tableArr.count {
                        for j in 0..<self.arrFromAlreadyStr.count {
                            if (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "hookupName") as! String == self.arrFromAlreadyStr.object(at: j) as! String {
                                self.selectedArray.replaceObject(at: i, with: 1)
                                self.typeIdArr.replaceObject(at: i, with: self.campHookupsArr.object(at: j) as! String)
                                self.typeNameArr.replaceObject(at: i, with: (self.tableArr.object(at: i) as! NSDictionary).value(forKey: "hookupName") as! String)
                                
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.doneBtn.isHidden = false
                    }
                    self.optionTableView.reloadData()
                    self.optionTableView.layoutIfNeeded()
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                //  CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            }
        }
    }
}

//MARK: Searching
extension SelectOptionVC : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.followingFollowerDataViewModel.searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.followingFollowerDataViewModel.searchActive = false
        self.optionTableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.followingFollowerDataViewModel.searchActive = false
        self.view.endEditing(true)
        self.optionTableView.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if self.searchBarTxtFld.text! == "" {
            self.followingFollowerDataViewModel.searchActive = false
            self.optionTableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.followingFollowerDataViewModel.searchedArr = self.tableArr.filter {
            return (($0 as! NSDictionary).value(forKey: "amenitiesName") as! String).range(of: searchText, options: .caseInsensitive) != nil } as! [[String : Any]]
            
       // print(self.followingFollowerDataViewModel.searchedArr)
        
        if self.followingFollowerDataViewModel.searchedArr.count == 0 {
            self.doneBtn.isHidden = true
            self.noDataFound.isHidden = false
        } else {
            self.doneBtn.isHidden = false
            self.noDataFound.isHidden = true
        }
        
        self.followingFollowerDataViewModel.searchActive = true
        if self.searchBarTxtFld.text! == "" {
            self.noDataFound.isHidden = true
            self.resetOnSearchFailed()
            self.followingFollowerDataViewModel.searchActive = false
            self.optionTableView.reloadData()
        } else {
            applicationDelegate.startProgressView(view: self.view)
            self.followingFollowerDataViewModel.searchedCheckUncheckedArr = []
            for i in 0..<self.followingFollowerDataViewModel.searchedArr.count {
                self.followingFollowerDataViewModel.searchedCheckUncheckedArr.append(0)
                
                for j in 0..<self.typeIdArr.count {
                    if String(describing: (self.followingFollowerDataViewModel.searchedArr[i]["amenitiesId"])!) == self.typeIdArr[j] as! String {
                        self.followingFollowerDataViewModel.searchedCheckUncheckedArr[i] = 1
                    }
                }
            }
            applicationDelegate.dismissProgressView(view: self.view)
            self.optionTableView.reloadData()
        }
    }
    
    func resetOnSearchFailed() {
        applicationDelegate.startProgressView(view: self.view)
        for i in 0..<self.tableArr.count {
            for j in 0..<self.typeIdArr.count {
                if String(describing: ((self.tableArr[i] as! [String: Any])["amenitiesId"])!) == self.typeIdArr[j] as! String {
                    self.selectedArray[i] = 1
                }
            }
        }
        applicationDelegate.dismissProgressView(view: self.view)
        self.optionTableView.reloadData()
    }
}
