//
//  ReviewViewcontroller.swift
//  SellSwap
//
//  Created by shikha kochar on 13/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ReviewViewcontroller: UIViewController {
    
    //MARK:- Iboutlets
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variable declarations
    var reviewArr: NSMutableArray = []
    var campId: String = ""
    
    ///
    var reviewRefreshControl = UIRefreshControl()
    
    //For Pagination
    var isDataLoading:Bool=false
    var pageNo:Int = 0
    var limit:Int = 10
    var upToLimit = 0
    
    var hasLoaded = Bool()
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        // print(self.reviewArr)
        
        self.initialSetUp()
        
        self.reviewTableView.tableFooterView = UIView()
        self.reviewTableView.estimatedRowHeight = 130;
        self.reviewTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        self.animateTbl()
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func animateTbl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.hasLoaded = true
            self.reviewTableView.reloadData()
            self.animateTableView()
            
        }
    }
    
    func animateTableView() {
        let leftAnimation = TableViewAnimation.Cell.left(duration: 0.5)
        self.reviewTableView.animate(animation: leftAnimation, indexPaths: nil, completion: nil)
        
    }
    
    func initialSetUp() {
        if connectivity.isConnectedToInternet() {
            self.resetPaginationVar()
            self.reviewAPICall(pageNum: pageNo)
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
        
        reviewRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        reviewRefreshControl.addTarget(self, action: #selector(handleRefreshNotification(_:)), for: UIControlEvents.valueChanged)
        
        self.reviewTableView.addSubview(self.reviewRefreshControl)
        
    }
    
    @objc func handleRefreshNotification(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.resetPaginationVar()
        self.reviewAPICall(pageNum: pageNo)
        
    }
    
    @objc func tapProfilePicBtn(sender: UIButton) {
        if String(describing: (DataManager.userId)) == String(describing: ((self.reviewArr.object(at: sender.tag) as! NSDictionary).value(forKey: "userId"))!) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.userInfoDict = (self.reviewArr.object(at: sender.tag) as! NSDictionary)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func resetPaginationVar() {
        isDataLoading = false
        pageNo = 0
        limit = 10
        
    }
    
    //MARK:- ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
        
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((reviewTableView.contentOffset.y + reviewTableView.frame.size.height) >= reviewTableView.contentSize.height) {
            if !isDataLoading{
                isDataLoading = true
                self.pageNo = self.pageNo + 1
               // print(self.limit)
                //print(upToLimit)
                if self.limit >= upToLimit {
                    
                    //
                    
                } else {
                    self.limit = self.limit + 10
                 //   print(pageNo)
                    self.reviewAPICall(pageNum: pageNo)
                    
                }
            }
        }
    }
    
    //MARK:- API's
    func reviewAPICall(pageNum: Int) {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "campReviews.php?userId="+(DataManager.userId as! String)+"&campId="+self.campId+"&offset=\(pageNum)", onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            self.reviewRefreshControl.endRefreshing()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    self.upToLimit = (dict["result"] as! NSDictionary).value(forKey: "totalReviews") as! Int
                    let retValues = (dict["result"] as! NSDictionary).value(forKey: "reviews") as! NSArray
                    
                 //   print(retValues)
                    
                    if pageNum == 0 {
                        self.reviewArr = []
                        
                    }
                    for i in 0..<retValues.count {
                        self.reviewArr.add(retValues.object(at: i) as! NSDictionary)
                        
                    }
                    
                    self.reviewTableView.reloadData()
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
            
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
    
    @IBAction func backAction(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func addReviewAction(_ sender: Any){
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "addReviewVc") as! addReviewVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
}

extension  ReviewViewcontroller : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewArr.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as! ReviewTableViewCell
        
        if let name = (self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as? String {
            cell.reviewGivenNameLbl.text = name
            
        } else {
            cell.reviewGivenNameLbl.text = ""
            
        }
        
        cell.reviewGivenUserImgView.sd_setShowActivityIndicatorView(true)
        cell.reviewGivenUserImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        cell.reviewGivenUserImgView.sd_setImage(with: URL(string: ((self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String)!), placeholderImage: UIImage(named: ""))
        cell.reviewGivenDateLbl.text! = convertDateFormater(((self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewDate") as! String))
        cell.ratingView.rating = Double(String(describing: ((self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewAverage"))!))!
        cell.reviewDescriptionLbl.text = (self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "description") as? String
        
        //add target
        cell.tapProfilePicBtn.tag = indexPath.row
        cell.tapProfilePicBtn.addTarget(self, action: #selector(tapProfilePicBtn(sender:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewDetailsVC") as! ReviewDetailsVC
        vc.campId = self.campId
        vc.reviewDeatils = (self.reviewArr.object(at: indexPath.row) as! NSDictionary)
        
        vc.reviewId = (String(describing: ((self.reviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "reviewId"))!))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
