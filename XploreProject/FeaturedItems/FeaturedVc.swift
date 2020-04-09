//
//  FeaturedVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import SimpleImageViewer

class FeaturedVc: UIViewController, filterValuesDelegate {
    
    //MARK:- Iboutlets
    @IBOutlet weak var dataContainingView: UIView!
    @IBOutlet weak var overlayview: UIView!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var markAsFavBtn: UIButton!
    
    @IBOutlet weak var campsiteTypeLbl: UILabel!
    @IBOutlet weak var sortBtn: UIButton!
    
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var noDataLbl: UILabel!
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var topNavigationHeight: NSLayoutConstraint!
    
    //MARK:- Variable Declaration
    var campId: Int = -1
    var campIndex: Int = -1
    var featuredReviewArr: NSMutableArray = []
    var comeFrom: String = ""
    var ascDscToggle: String = "0"
    var userId: String = ""
    
    var filterDataDict: NSDictionary = [:]
    var searchType: String = ""
    
    //For Pagination
    var isDataLoading:Bool=false
    var pageNo:Int = 0
    var limit:Int = 5
    var upToLimit = 0
    
    var autherInfo: [String: Any] = [:]
    
    ///
    var featuredReviewRefreshControl = UIRefreshControl()
    
   // let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    //MARK:- Inbuild FUnction
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !DataManager.isUserLoggedIn! {
            self.topNavigationView.isHidden = true
            self.topNavigationHeight.constant = 0
            
        }
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        if comeFrom == featuredBased {
            self.campsiteTypeLbl.text! = "Featured Campsites"
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
            
        } else if comeFrom == myProfile {
            self.campsiteTypeLbl.text! = "Campsites"
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
            
        } else if comeFrom == reviewBased {
            self.campsiteTypeLbl.text! = "Review Based"
            self.sortBtn.isHidden = false
            self.ascDscToggle = "1"
            self.filterBtn.isHidden = true
            
        } else {
            self.campsiteTypeLbl.text! = allCamps
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
        }
        
        self.dataContainingView.isHidden = true
        self.recallAPIView.isHidden = true
        
        self.overlayview.isHidden = true
        favMarkbottomConstraint.constant = 150
        //call api
        self.callAPI()
        
        //refresh controll
        self.refreshData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.isUserLoggedIn! == true {
            self.topNavigationView.isHidden = false
            self.topNavigationHeight.constant = 44
            
        }
        
        self.stopAnimateAcitivity()
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        if self.filterDataDict.value(forKey: "lattitude") == nil && self.searchType == filter {
            self.searchType = ""
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func startAnimateAcitivity() {
        self.activityView.isHidden = false
        self.activityViewHeight.constant = 80
        self.activityIndicator.startAnimating()
        
    }
    
    func stopAnimateAcitivity() {
        self.activityView.isHidden = true
        self.activityViewHeight.constant = 0
        self.activityIndicator.stopAnimating()
        
    }
    
    func resetPaginationVar() {
        isDataLoading = false
        pageNo = 0
        limit = 5
        
    }
    
    func passFilterData(fillDict: NSDictionary) {
      //  print(fillDict)
        
        self.filterDataDict = fillDict
        self.callAPI()
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            
            self.resetPaginationVar()
            if self.searchType == filter {
                self.filterApiHit(pageNum: pageNo)
                
            } else {
                if comeFrom == reviewBased {
                    self.revieweBasedAPIHit(pageNum: pageNo)
                    
                } else {
                    self.featuredAPIHit(pageNum: pageNo)
                    
                }
            }
        } else {
            if self.featuredReviewArr.count == 0  {
                self.recallAPIView.isHidden = false
                
            }
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func refreshData() {
        self.featuredReviewRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.featuredReviewRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.categoryCollectionView.addSubview(self.featuredReviewRefreshControl)
        
    }
    
    //MARK:- ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
        
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((self.categoryCollectionView.contentOffset.y + self.categoryCollectionView.frame.size.height) >= self.categoryCollectionView.contentSize.height) {
            if !isDataLoading{
                isDataLoading = true
                self.pageNo = self.pageNo + 1
              //  print(self.limit)
                //print(upToLimit)
                if self.limit >= upToLimit {
                    //
                    
                } else {
                    self.limit = self.limit + 5
                    
                    self.startAnimateAcitivity()
                    if self.searchType == filter {
                        self.filterApiHit(pageNum: self.pageNo)

                    } else {
                        if self.comeFrom == reviewBased {
                            self.revieweBasedAPIHit(pageNum: self.pageNo)

                        } else {
                            self.featuredAPIHit(pageNum: self.pageNo)
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.callAPI()
        
    }
    
    //MARK:- Api's Hit
    func filterApiHit(pageNum: Int) {
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "filter.php/?userId=\(DataManager.userId as! String)"+"&latitude=\(String(describing: (self.filterDataDict.value(forKey: "lattitude"))!))"+"&longitude=\(String(describing: (self.filterDataDict.value(forKey: "longitude"))!))"+"&distance=\(String(describing: (self.filterDataDict.value(forKey: "selectedDistance"))!))"+"&type=\(String(describing: (self.filterDataDict.value(forKey: "type"))!))"+"&offset=\(pageNum)", onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            self.featuredReviewRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = dict["result"] as! NSArray
                    
                  //  print(retValues)
                    
                    self.dataContainingView.isHidden = false
                    
                    if (retValues.count) % 5 == 0 {
                        self.upToLimit = (pageNum+1)*5 + 1
                        
                    } else {
                        self.upToLimit = self.upToLimit + (retValues.count)
                        
                    }
                    
                    if pageNum == 0 {
                        self.featuredReviewArr = []
                        
                    }
                    for i in 0..<retValues.count {
                        self.featuredReviewArr.add(retValues.object(at: i) as! NSDictionary)
                        
                    }
                    
                    // self.searchDataArr = retValues
                    
                    self.categoryCollectionView.delegate = self
                    self.categoryCollectionView.dataSource = self
                    self.categoryCollectionView.reloadData()
                    
                    
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
    
    func featuredAPIHit(pageNum: Int) {
        if self.featuredReviewArr.count == 0 {
            applicationDelegate.startProgressView(view: self.view)
            
        }
       
        var api1: String = ""
        var api2: String = ""
        if let userId1 = DataManager.userId as? String {
            userId = userId1
            
        }
        
     //   http://clientstagingdev.com/explorecampsite/api/userPublished.php?userId=43&offset=0&userCamps=33
        //&country\(countryOnMyCurrentLatLong)
        if comeFrom == myProfile {
            api1 = "userPublished.php?userId=" + userId //+ userId
            
            api2 = "&offset=\(pageNum)&userCamps=\(userId)"
        } else if comeFrom == featuredBased {
            api1 = "featuredCampsites.php?userId=" + userId
            
            api2 = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&offset=\(pageNum)&country\(countryOnMyCurrentLatLong)"
        } else {
            api1 = "nearbynew.php?userId=" + userId
            
            api2 = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&offset=\(pageNum)&country\(countryOnMyCurrentLatLong)"
            
        }
        
        let api:String = api1 + api2
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            self.featuredReviewRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    
                    print(retValues)
                    self.reloadTbl(arrR: retValues, pageR: pageNum)
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.apiError()
            
        }
    }
    
    func revieweBasedAPIHit(pageNum: Int) {
        if self.featuredReviewArr.count == 0 {
            applicationDelegate.startProgressView(view: self.view)
         
        }
        let apo1: String = "reviewCampsites.php?userId=" + userId
        let api2:String = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&toggle="+self.ascDscToggle+"&offset=\(pageNum)&country\(countryOnMyCurrentLatLong)"
        
        let api:String = apo1 + api2
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            self.featuredReviewRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                  //  print(retValues)
                    
                    self.reloadTbl(arrR: retValues, pageR: pageNum)
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.apiError()
        }
    }
    
    func reloadTbl(arrR: NSArray, pageR: Int) {
        self.dataContainingView.isHidden = false
        self.recallAPIView.isHidden = true
        
        if (arrR.count) % 5 == 0 {
            self.upToLimit = (pageR+1)*5 + 1
            
        } else {
            self.upToLimit = self.upToLimit + (arrR.count)
            
        }
        
        if pageR == 0 {
            self.featuredReviewArr = []
            
        }
        if self.campIndex != -1 {
            for _ in 0..<arrR.count {
                self.featuredReviewArr.removeLastObject()
                
            }
        }
        
        for i in 0..<arrR.count {
            self.featuredReviewArr.add(arrR.object(at: i) as! NSDictionary)
            
        }
        
        if self.campIndex == -1 {
            self.categoryCollectionView.delegate = self
            self.categoryCollectionView.dataSource = self
            self.categoryCollectionView.reloadData()
        } else {
            let indexPath = IndexPath(item: self.campIndex, section: 0)
            
            var indexPaths = [IndexPath]()
            indexPaths.append(indexPath) //"indexPath" ideally get when tap didSelectItemAt or through long press gesture recogniser.
            
            let indexS = IndexSet(arrayLiteral: 0)
            self.categoryCollectionView.reloadSections(indexS)
            self.categoryCollectionView.reloadItems(at: indexPaths)
            
            self.campIndex = -1
            self.campId = -1
        }
        
    }
    
    func apiError() {
        self.recallAPIView.isHidden = false
        
        applicationDelegate.dismissProgressView(view: self.view)
        if connectivity.isConnectedToInternet() {
            CommonFunctions.showAlert(self, message: serverError, title: appName)
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func FavUnfavAPIHit(indexR: NSIndexPath){
        applicationDelegate.startProgressView(view: self.view)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)
        
        var api1: String = ""
        api1 = "markFavourite.php?userId=" + (DataManager.userId as! String)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api1 + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
           
            let cell = self.categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
            
            ///////
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                   // print(dict)
                   // self.resetPaginationVar()
                    let pagN = self.campIndex/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    if self.comeFrom == reviewBased {
                        self.revieweBasedAPIHit(pageNum: self.pageNo)
                        
                    } else {
                        self.featuredAPIHit(pageNum: self.pageNo)
                        
                    }
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            let cell = self.categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            cell.favouriteButton.isUserInteractionEnabled = true
            
            ////
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
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.loginAlertFunc(vc: "profile")
        }
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "nearByUser")
            
       }
    }
    
    @IBAction func tapAddCampsiteBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "addCamps")
            
        }
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "fromNoti")
            
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func filterAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterVc") as! FilterVc
        self.searchType = filter
        vc.comeFrom = notFromTabbar
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func closeFavouritesView(_ sender: Any) {
        favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayview.isHidden = true
            self.view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func tapfavUnfavBtn(_ sender: Any) {
        self.overlayview.isHidden = true
        
        if connectivity.isConnectedToInternet() {
            let indexPath = NSIndexPath(item: self.campIndex, section: 0)
            
            let cell = self.categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            
            if cell.favouriteButton.currentImage == #imageLiteral(resourceName: "Favoutites") {
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            } else {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                            
            }
            self.FavUnfavAPIHit(indexR: indexPath)
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapSaveCampSiteBtn(_ sender: UIButton) {
        self.overlayview.isHidden = true
        var tempArr: NSMutableArray = []
        
        if userDefault.value(forKey: mySavesCamps) != nil {
           
            tempArr = (NSKeyedUnarchiver.unarchiveObject(with: (userDefault.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            
            var matched: Bool = false
            for i in 0..<tempArr.count {
                if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: ((self.featuredReviewArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "campId"))!) {
                    matched = true
                    break
                }
            }
            
            if matched == false {
                tempArr.add((self.featuredReviewArr.object(at: self.campIndex) as! NSDictionary))
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            } else {
                matched = false
                DispatchQueue.main.async {
                    CommonFunctions.showAlert(self, message: alreadySavedCampAlert, title: appName)
                    
                }
            }
        } else {
            tempArr.add((self.featuredReviewArr.object(at: self.campIndex) as! NSDictionary))
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
            
            CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            
        }
    }
    
    @IBAction func tapRetryBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.recallAPIView.isHidden = true
        if connectivity.isConnectedToInternet() {
            self.resetPaginationVar()
            if self.comeFrom == reviewBased {
                self.revieweBasedAPIHit(pageNum: pageNo)
                
            } else {
                self.featuredAPIHit(pageNum: pageNo)
                
            }
        } else {
            if self.featuredReviewArr.count == 0  {
                self.recallAPIView.isHidden = false
                
            }
            
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapSortBtn(_ sender: UIButton) {
        if self.ascDscToggle == "0" {
            self.ascDscToggle = "1"
            
        } else {
            self.ascDscToggle = "0"
            
        }
        
        //call api
        self.callAPI()
        
    }
}
extension FeaturedVc {
    @objc func endEditing () {
        
        favMarkbottomConstraint.constant = -150
        UIView.animate(withDuration: 1) {
            self.overlayview.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func favoutiteAction(sender: UIButton) {
        if DataManager.isUserLoggedIn! == false {
            self.loginAlertFunc(vc: "featured")
            
        } else {
            self.campIndex = sender.tag
            if String(describing: ((self.featuredReviewArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
                self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
                
            } else {
                self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
                
            }
            
            self.campId = Int(String(describing: ((self.featuredReviewArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!))!
            
            self.favMarkbottomConstraint.constant = 150
            
            self.overlayview.tag = sender.tag
            self.overlayview.isHidden = false
            self.view.layoutIfNeeded()
            
        }
    }
}

extension FeaturedVc :UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if self.featuredReviewArr.count == 0 {
            if recallAPIView.isHidden == true {
                self.noDataLbl.isHidden = false
                
            }           
        } else {
            self.noDataLbl.isHidden = true
            
        }
        
        return self.featuredReviewArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action:#selector(favoutiteAction(sender:)), for:.touchUpInside)
        
        if ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
            
            cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
            cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.featuredReviewImgView.sd_setImage(with: URL(string: (String(describing: (((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0))))), placeholderImage: UIImage(named: ""))
            
            cell.noImgLbl.isHidden = true
        } else {
            cell.featuredReviewImgView.image = UIImage(named: "")
            cell.noImgLbl.isHidden = false
        }
        
        cell.imagLocNameLbl.text = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as?
            String)
        
        cell.ttlRatingLbl.text! = String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!) //String(describing: (reducedNumberSum))
        cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
        cell.ttlReviewLbl.text! = (String(describing: (((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
        
        if ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
            cell.locationAddressLbl.text! = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            
        }
        
        if let img = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
            
            cell.autherImgView.sd_setShowActivityIndicatorView(true)
            cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
            
        }
        cell.autherNameLbl.text = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
        
        if String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
            
        } else {
            cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
            
        }
        
        if comeFrom == myProfile {
            cell.userProfileAndNameView.isHidden = false
            cell.userProfileAndNameView.isUserInteractionEnabled = false
            
            if self.autherInfo.count != 0 {
                if let img = (self.autherInfo["autherImg"] as? String) {                    
                    cell.autherImgView.sd_setShowActivityIndicatorView(true)
                    cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                    cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
                    
                }
                cell.autherNameLbl.text = (self.autherInfo["autherName"] as? String)
                
            }
        } else {
            cell.userProfileAndNameView.isHidden = false
            cell.userProfileAndNameView.isUserInteractionEnabled = true
            
            cell.tapProfilePicBtn.tag = indexPath.row
            cell.tapProfilePicBtn.addTarget(self, action: #selector(tapReviewProfilePicBtn(sender:)), for: .touchUpInside)

        }
        
        if String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
           // cell.playBtn.isHidden = true
            cell.playImg.isHidden = false
            
            cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
            cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            
        } else {
           // cell.playBtn.isHidden = true
            cell.playImg.isHidden = true
            
        }
        
        return cell
    }
    
    @objc func tapReviewProfilePicBtn(sender: UIButton) {
        if DataManager.isUserLoggedIn! == false {
            self.loginAlertFunc(vc: "campUserProfile")
            
        } else {
            let indexVal: NSDictionary = (self.featuredReviewArr.object(at: sender.tag) as! NSDictionary)
            
            if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                vc.userInfoDict = indexVal
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    @objc func tapTripsShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
        vc.campId = String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 1) {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        } else {
            
            if comeFrom == myProfile {
                return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(330))
                
            } else {
                return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(330))
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
        
    }    
}

//MARK:- login alert
extension FeaturedVc {
    func loginAlertFunc(vc: String) {
        let alert = UIAlertController(title: appName, message: loginRequired, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
            if vc == "profile" {
                Singleton.sharedInstance.loginComeFrom = fromProfile
                
            } else if vc == "nearByUser" {
                Singleton.sharedInstance.loginComeFrom = fromNearByuser
               
            } else if vc == "addCamps" {
                Singleton.sharedInstance.loginComeFrom = fromAddCamps
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromNoti
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromFavCamps
                
            } else if vc == "viewProfile" {
                Singleton.sharedInstance.loginComeFrom = fromViewProfile
                
            } else if vc == "featured" || vc == "campUserProfile" {
                Singleton.sharedInstance.loginComeFrom = featuredCamp
               
            }
            self.navigationController?.pushViewController(controller, animated: false)
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
}
