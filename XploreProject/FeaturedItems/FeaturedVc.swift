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
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var markAsFavBtn: UIButton!
    
    @IBOutlet weak var sortFilterContainStackView: UIStackView!
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
    @IBOutlet weak var noDataFound: UILabel!
    
    //MARK:- Variable Declaration
    private let commonDataViewModel = CommonUseViewModel()
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
    var fromCampDes: Bool = false
    
    var autherInfo: [String: Any] = [:]
    let sing = Singleton.sharedInstance
    ///
    var featuredReviewRefreshControl = UIRefreshControl()
    
   // let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    //MARK:- Inbuild FUnction
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noDataFound.isHidden = true
        if !DataManager.isUserLoggedIn! {
            self.topNavigationView.isHidden = true
            self.topNavigationHeight.constant = 0
            
        }
        
        self.dataContainingView.isHidden = true
        if comeFrom == featuredBased {
            self.campsiteTypeLbl.text! = "Featured Campsites"
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
            
            if self.sing.featuredViewAllArr.count > 0 {
                self.dataContainingView.isHidden = false
                self.reloadTbl(arrR: self.sing.featuredViewAllArr, pageR: 0)
            }
        } else if comeFrom == myProfile {
            self.campsiteTypeLbl.text! = "Campsites"
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
        } else if comeFrom == reviewBased {
            self.campsiteTypeLbl.text! = "Review Based"
            self.sortBtn.isHidden = false
            self.ascDscToggle = "1"
            self.filterBtn.isHidden = true
            
            if self.sing.reviewViewAllArr.count > 0 {
                self.dataContainingView.isHidden = false
                self.reloadTbl(arrR: self.sing.reviewViewAllArr, pageR: 0)
            }
        } else {
            self.campsiteTypeLbl.text! = allCamps
            self.sortBtn.isHidden = true
            self.filterBtn.isHidden = true
            
            if self.sing.allCampsArr.count > 0 {
                self.dataContainingView.isHidden = false
                self.reloadTbl(arrR: self.sing.featuredViewAllArr, pageR: 0)
            }
        }
        
        self.recallAPIView.isHidden = true
        
        self.overlayview.isHidden = true
        favMarkbottomConstraint.constant = 150
        
        //refresh controll
        self.refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.campIndex == -1 || Singleton.sharedInstance.updateFavOrFollowStatusInDes == true {
            Singleton.sharedInstance.updateFavOrFollowStatusInDes = false
            //call api
            self.callAPI()
        }
        
        if DataManager.isUserLoggedIn! == true {
            self.topNavigationView.isHidden = false
            self.topNavigationHeight.constant = 44
            
        }
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        self.stopAnimateAcitivity()
        
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        if self.filterDataDict.value(forKey: "lattitude") == nil && self.searchType == filter {
            self.searchType = ""
        }
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
        self.filterDataDict = fillDict
        self.callAPI()
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            if self.fromCampDes == false {
                self.resetPaginationVar()
            } else {
                self.fromCampDes = false
            }
            
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
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
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
                    
                    if self.searchType == filter {
                       // self.filterApiHit(pageNum: self.pageNo)

                    } else {
                        self.limit = self.limit + 5
                        self.startAnimateAcitivity()
                        if self.comeFrom == reviewBased {
                            self.revieweBasedAPIHit(pageNum: self.pageNo)

                        } else {
                            self.featuredAPIHit(pageNum: self.pageNo)
                            
                        }
                    }
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
                    let count: Int = self.featuredReviewArr.count
                    for i in 0..<retValues.count {
                        self.featuredReviewArr.add(retValues.object(at: i) as! NSDictionary)
                    }
                    if pageNum == 0 {
                        self.categoryCollectionView.delegate = self
                        self.categoryCollectionView.dataSource = self
                        self.categoryCollectionView.reloadData()
                    } else {
                        if count < self.featuredReviewArr.count {
                            self.categoryCollectionView.reloadData()
                            let indexpathG = IndexPath(item: count, section: 0)
                            self.categoryCollectionView.scrollToItem(at: indexpathG, at: .top, animated: true)
                            self.categoryCollectionView.setNeedsLayout()
                        }
                    }
                } else {
                    self.noDataFound.isHidden = false
                    self.dataContainingView.isHidden = false
                    self.sortFilterContainStackView.isHidden = true
                    self.categoryCollectionView.isHidden = true
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
            //    CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func featuredAPIHit(pageNum: Int) {
        if self.featuredReviewArr.count == 0 {
            applicationDelegate.startProgressView(view: self.view)
            
        }
       
        var api1: String = ""
        var api2: String = ""
        
        if self.comeFrom != myProfile {
            if let userId1 = DataManager.userId as? String {
                userId = userId1
            }
        }
        
     //   http://clientstagingdev.com/explorecampsite/api/userPublished.php?userId=43&offset=0&userCamps=33
        //&country\(countryOnMyCurrentLatLong)
        if comeFrom == myProfile {
            api1 = "userPublished.php?userId=" + userId  //+ userId
            
            api2 = "&offset=\(pageNum)&userCamps=\(userId)&loginId=\(DataManager.userId as? String ?? "0")"
        } else if comeFrom == featuredBased {
            api1 = "featuredCampsites.php?userId=" + userId
            
            api2 = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&offset=\(pageNum)&country=\(countryOnMyCurrentLatLong)"
        } else {
            api1 = "nearbynew.php?userId=" + userId
            
            api2 = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&offset=\(pageNum)&country=\(countryOnMyCurrentLatLong)"
            
        }
        
        let api:String = api1 + api2
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            self.featuredReviewRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    
                 //   print(retValues)
                    
                    self.reloadTbl(arrR: retValues, pageR: pageNum)
                } else {
                    self.noDataFound.isHidden = false
                    self.dataContainingView.isHidden = false
                    self.sortFilterContainStackView.isHidden = true
                    self.categoryCollectionView.isHidden = true
                    if (String(describing: (dict["error"])!)) == apiNoRecordMsg {
                        let alert = UIAlertController(title: appName, message: msgToShowIfNoRecord, preferredStyle: .alert)
                        let yesBtn = UIAlertAction(title: okBtnTitle, style: .default, handler: { (UIAlertAction) in
                            alert.dismiss(animated: true, completion: nil)
                            self.tabBarController?.selectedIndex = 1
                            
                        })
                        alert.addAction(yesBtn)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    }
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
        if let userId1 = DataManager.userId as? String {
            userId = userId1
        }
        
        let apo1: String = "reviewCampsites.php?userId=" + userId
        let api2:String = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&toggle="+self.ascDscToggle+"&offset=\(pageNum)&country=\(countryOnMyCurrentLatLong)&loginId=\(DataManager.userId as? String ?? "0")"
        
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
                    self.noDataFound.isHidden = false
                    self.dataContainingView.isHidden = false
                    self.sortFilterContainStackView.isHidden = true
                    self.categoryCollectionView.isHidden = true
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
        let count: Int = self.featuredReviewArr.count
        for i in 0..<arrR.count {
            self.featuredReviewArr.add(arrR.object(at: i) as! NSDictionary)
            
        }
        
        if self.campIndex == -1 {
            if pageR == 0 {
                self.categoryCollectionView.delegate = self
                self.categoryCollectionView.dataSource = self
                self.categoryCollectionView.reloadData()
            } else {
                if count < self.featuredReviewArr.count {
                    self.categoryCollectionView.reloadData()
                    
                    let indexpathG = IndexPath(item: count, section: 0)
                    self.categoryCollectionView.scrollToItem(at: indexpathG, at: .top, animated: true)
                    self.categoryCollectionView.setNeedsLayout()
                    
                }
            }
        } else {
            let indexPath = IndexPath(item: self.campIndex, section: 0)
            self.categoryCollectionView.reloadData()
//            var indexPaths = [IndexPath]()
//            indexPaths.append(indexPath) //"indexPath" ideally get when tap didSelectItemAt or through long press gesture recogniser.
//
//            let indexS = IndexSet(arrayLiteral: 0)
//            self.categoryCollectionView.reloadSections(indexS)
//            self.categoryCollectionView.reloadItems(at: indexPaths)
            self.categoryCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            
            self.campIndex = -1
            self.campId = -1
        }
        
    }
    
    func apiError() {
        self.recallAPIView.isHidden = false
        
        applicationDelegate.dismissProgressView(view: self.view)
        if connectivity.isConnectedToInternet() {
            self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
           // CommonFunctions.showAlert(self, message: serverError, title: appName)
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func FavUnfavAPIHit(indexR: NSIndexPath){
        applicationDelegate.startProgressView(view: self.view)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)
        
        var api1: String = ""
        if self.comeFrom == myProfile {
            api1 = "markFavourite.php?userId=" + self.userId
        } else {
            api1 = "markFavourite.php?userId=" + (DataManager.userId as! String)
        }
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api1 + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
           
            let cell = self.categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true
            
            ///////
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                   // print(dict)
                   // self.resetPaginationVar()
                    let pagN: Float = Float(self.campIndex/5)
                    self.pageNo = Int(pagN)
                    self.limit = Int(pagN+1)*5
                    if self.searchType == filter {
                        self.filterApiHit(pageNum: self.pageNo)

                    } else {
                        if self.comeFrom == reviewBased {
                            self.revieweBasedAPIHit(pageNum: self.pageNo)

                        } else {
                            self.featuredAPIHit(pageNum: self.pageNo)
                        }
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
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func updateIndexVal() {
        
    }
    
    //MARK:- Button Action
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.loginAlertFunc(vc: "profile", viewController: self)
        }
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "nearByUser", viewController: self)
            
       }
    }
    
    @IBAction func tapAddCampsiteBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "addCamps", viewController: self)
            
        }
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "fromNoti", viewController: self)
            
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
                if self.comeFrom == reviewBased {
                    
                    
                } else {
                    
                    
                }
                
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            } else {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                            
            }
            self.FavUnfavAPIHit(indexR: indexPath)
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
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
            
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
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
            self.loginAlertFunc(vc: "featured", viewController: self)
            
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
        
        //share button
        cell.shareCampBtn.tag = indexPath.row
        cell.shareCampBtn.addTarget(self, action: #selector(tapShareBtn(sender:)), for: .touchUpInside)
        
        //follow/unfollow button
        cell.followUnfollowBtn.tag = indexPath.row
        cell.followUnfollowBtn.addTarget(self, action: #selector(tapFollowUnfollowBtn(sender:)), for: .touchUpInside)
        
        let indexVal = (self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary)
        if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
            cell.followUnfollowBtn.isHidden = true
        } else {
            var followedTrue: Bool = false
            let followStatus = "\(indexVal.value(forKey: "follow") as? Int ?? 0)"
            if self.commonDataViewModel.followedUnfolledUserDict.count > 0 {
                let followStatusFromDict = self.commonDataViewModel.followedUnfolledUserDict["followStatus"] as! String
                let followUnfollowId = self.commonDataViewModel.followedUnfolledUserDict["followUnfollowedId"]
                
                if String(describing: followUnfollowId!) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
                    if followStatusFromDict == "0" {
                        followedTrue = false
                    } else {
                        followedTrue = true
                    }
                } else {
                    if followStatus == "0" {
                        followedTrue = false
                    } else {
                        followedTrue = true
                    }
                }
            } else {
                if followStatus == "0" {
                    followedTrue = false
                } else {
                    followedTrue = true
                }
            }
            
            if followedTrue == true {
                cell.followUnfollowBtn.backgroundColor = UIColor.white
                cell.followUnfollowBtn.setTitle("Unfollow", for: .normal)
                cell.followUnfollowBtn.setTitleColor(UIColor.appThemeGreenColor(), for: .normal)
            } else {
                cell.followUnfollowBtn.backgroundColor = UIColor.appThemeGreenColor()
                cell.followUnfollowBtn.setTitle("Follow", for: .normal)
                cell.followUnfollowBtn.setTitleColor(UIColor.white, for: .normal)
            }
            
            cell.followUnfollowBtn.isHidden = false
        }
        
        if ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
            
            cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
            cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            
            if let img =  ((((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0)) as? String) {
                
                cell.gradientView.isHidden = true
                cell.featuredReviewImgView.contentMode = .center
                cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill){ (rSuccess) in
                    //
                }
                cell.gradientView.isHidden = false
                
//                cell.featuredReviewImgView.sd_setImage(with: URL(string: img)) { (image, error, cache, url) in
//                    // Your code inside completion block
//                    cell.gradientView.isHidden = false
//                    cell.featuredReviewImgView.contentMode = .scaleAspectFill
//
//                }
                //cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill)
            }
            
           // cell.gradientView.isHidden = false
            cell.noImgLbl.isHidden = true
        } else {
            cell.gradientView.isHidden = true
            cell.featuredReviewImgView.contentMode = .center
            cell.featuredReviewImgView.image = UIImage(named: "PlaceHolder")
          //  cell.noImgLbl.isHidden = false
        }
        
        cell.imagLocNameLbl.text = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as?
            String)
        
        cell.ttlRatingLbl.text! = String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!) //String(describing: (reducedNumberSum))
        cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
        cell.ttlReviewLbl.text! = (String(describing: (((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
        
        if ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
            
            let addr = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            var trimmedAddr: String = ""
            trimmedAddr = addr.replacingOccurrences(of: ", , , ", with: ", ")
            if trimmedAddr == "" {
                trimmedAddr = addr.replacingOccurrences(of: ", , ", with: ", ")
            }
            cell.locationAddressLbl.text! = trimmedAddr
            
        //    cell.locationAddressLbl.text! = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            
        }
        
        if let img = ((self.featuredReviewArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
            
            cell.autherImgView.sd_setShowActivityIndicatorView(true)
            cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            
            cell.autherImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                //
            }
            
           // cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
            
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
                    cell.autherImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                        //
                    }
                    
                  //  cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
                    
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
            self.loginAlertFunc(vc: "campUserProfile", viewController: self)
            
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
    
    //share app campsite
    @objc func tapShareBtn(sender: UIButton) {
        let indexP = IndexPath(item: sender.tag, section: 0)
        let cell = self.categoryCollectionView.cellForItem(at: indexP) as? CustomCell
        
        let indexVal = (self.featuredReviewArr.object(at: sender.tag) as! NSDictionary)
        let campTitle = indexVal.value(forKey: "campTitle") as! String
        let campImgArr = indexVal.value(forKey: "campImages") as! [String]
        let campImg = campImgArr[0]
        
        self.commonDataViewModel.shareAppLinkAndImage(campTitle: "\(campTitle)\n" , campImg: (cell?.featuredReviewImgView.image)!, campimg1: campImg, sender: sender, vc: self)
        
    }
    
    //follow/unfollow
    @objc func tapFollowUnfollowBtn(sender: UIButton) {
        if DataManager.isUserLoggedIn! == false {
            self.loginAlertFunc(vc: "viewProfile", viewController: self)
            
        } else {
            if connectivity.isConnectedToInternet() {
                self.campIndex = sender.tag
                applicationDelegate.startProgressView(view: self.view)
                let indexVal: NSDictionary = (self.featuredReviewArr.object(at: sender.tag) as! NSDictionary)
                let param: [String: Any] = ["userId": "\(DataManager.userId)", "follow": String(describing: (indexVal.value(forKey: "campAuthor"))!)]
                
                var apiToBeCalled: String = ""
                let followStatus = "\(indexVal.value(forKey: "follow") as? Int ?? 0)"
                if followStatus == "0" {
                    apiToBeCalled = apiUrl.followApi.rawValue
                } else {
                    apiToBeCalled = apiUrl.unFollowApi.rawValue
                }
            //    print(param)
                self.commonDataViewModel.followUnfollowUwser(actionUrl: apiToBeCalled, param: param) { (rMsg) in
                 //   print(rMsg)
                    applicationDelegate.dismissProgressView(view: self.view)
                    
                    self.commonDataViewModel.followedUnfolledUserDict.updateValue(String(describing: (indexVal.value(forKey: "campAuthor"))!), forKey: "followUnfollowedId")
                    if followStatus == "0" {
                        self.commonDataViewModel.followedUnfolledUserDict.updateValue("1", forKey: "followStatus")
                    } else {
                        self.commonDataViewModel.followedUnfolledUserDict.updateValue("0", forKey: "followStatus")
                    }
                    
                    let pagN = (sender.tag)/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    
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
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
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
        self.fromCampDes = true
        self.campIndex = indexPath.row
        self.campId = Int(vc.campId)!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 1) {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        } else {
            
            if comeFrom == myProfile {
                return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(320))
                
            } else {
                return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(320))
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
        
    }    
}
