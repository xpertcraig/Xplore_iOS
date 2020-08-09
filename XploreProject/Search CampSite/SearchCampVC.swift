//
//  SearchCampVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 22/10/18.
//  Copyright © 2018 Apple. All rights reserved.
// AIzaSyDdfUiEN3grZALqX9tRHBD6WcqTaZ57XRc

//  com.campsites.app.explore

import UIKit
import GooglePlaces

import SimpleImageViewer

class SearchCampVC: UIViewController, filterValuesDelegate {
    
    //MARK:- Iboutlets
    @IBOutlet weak var dataContainingView: UIView!
    @IBOutlet weak var overlayview: UIView!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var markAsFavBtn: UIButton!
    
    @IBOutlet weak var campsiteTypeLbl: UILabel!
    @IBOutlet weak var searchTxtFLd: UITextField!
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterBtnStackView: UIStackView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Variable Declaration
    var searchType: String = ""
    
    var campId: Int = -1
    var campIndex: Int = -1
    var searchDataArr: NSMutableArray = []
    var filterDataDict: NSDictionary = [:]
    
    var comeFrom: String = googleSearch
    
    //For Pagination
    var isDataLoading:Bool=false
    var pageNo:Int = 0
    var limit:Int = 5
    var upToLimit = 0
    
    var selectedLatti: Double = myCurrentLatitude
    var selectedLongi: Double = myCurrentLongitude
    
    ///
    var searchReviewRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if comeFrom == filterPush {
            self.searchViewHeight.constant = 0
             self.filterBtnStackView.isHidden = false
            
        } else {
            self.dataContainingView.isHidden = true
            self.tapSearchView()
            self.searchViewHeight.constant = 0
        }
        
        self.recallAPIView.isHidden = true
        
        self.overlayview.isHidden = true
        self.favMarkbottomConstraint.constant = 150
      
        self.searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSearchView)))
        
        //call api
        self.callAPI()
        
        //refresh controll
        self.refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.stopAnimateAcitivity()
        
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
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
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
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
    
    func passFilterData(fillDict: NSDictionary) {
        self.filterDataDict = fillDict
        self.callAPI()
        
    }
    
    @objc func tapSearchView() {
        self.searchTxtFLd.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        
        // Sets the background of results - top line
        acController.primaryTextColor = UIColor.black
        UINavigationBar.appearance().barTintColor = appThemeColor
        // Sets the background of results - second line
        acController.secondaryTextColor = UIColor.black
        
        // Sets the text color of the text in search field
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        acController.delegate = self
        self.searchType = googleSearch
        present(acController, animated: true, completion: nil)
        
    }
    
    func resetPaginationVar() {
        isDataLoading = false
        pageNo = 0
        limit = 5
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.resetPaginationVar()
            if comeFrom == filterPush {
                self.filterApiHit(pageNum: pageNo)
                
            } else {
                if self.searchType == googleSearch {
                    self.searchAPIHit(pageNum: pageNo)
                    
                } else if searchType == "Home"{
                    
                    
                } else {
                    self.filterApiHit(pageNum: pageNo)
                    
                }
            }
        } else {
            if self.searchDataArr.count == 0  {
                self.recallAPIView.isHidden = false
                self.noDataFoundLbl.isHidden = true
                
            }
            
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
           // CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func textFieldTapped(_ sender: Any) {
//        self.searchTxtFLd.resignFirstResponder()
//        let acController = GMSAutocompleteViewController()
//        acController.delegate = self
//        present(acController, animated: true, completion: nil)
        
    }
    
    func refreshData() {
        self.searchReviewRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.searchReviewRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.categoryCollectionView.addSubview(self.searchReviewRefreshControl)
        
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
                //print(self.limit)
               // print(upToLimit)
                if self.limit >= upToLimit {
                    //
                    
                } else {
                    self.limit = self.limit + 5
                   // print(pageNo)
                    
                    self.startAnimateAcitivity()
                    if self.searchType == googleSearch {
                        self.searchAPIHit(pageNum: pageNo)
                        
                    } else if searchType == "Home"{
                        
                        
                    } else {
                        self.filterApiHit(pageNum: pageNo)
                        
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
    func searchAPIHit(pageNum: Int) {
      
        if searchType == "Home" {
            self.categoryCollectionView.isHidden = true
            
        }
        var userLId: String = ""
        if let userid = DataManager.userId as? String {
            userLId = userid
            
        }
        
        let apo1: String = "new-search.php?userId=\(userLId)"
        
        var api2: String = ""
        if String(describing: (selectedLatti)) == "" {
            api2 = "&latitude=" + String(describing: (myCurrentLatitude)) + "&longitude=" + String(describing: (myCurrentLongitude))+"&offset=\(pageNum)"
            
        } else {
            api2 = "&latitude=" + String(describing: (selectedLatti)) + "&longitude=" + String(describing: (selectedLongi))+"&offset=\(pageNum)"
            
        }
        
        let api:String = apo1 + api2
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.dataContainingView)
            self.searchReviewRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    
               //     print(retValues)
                    
                    self.reloadTbl(arrR: retValues, pageR: pageNum)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.recallAPIView.isHidden = false
            self.noDataFoundLbl.isHidden = true
            
            applicationDelegate.dismissProgressView(view: self.dataContainingView)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
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
            self.searchDataArr = []
            
        }
        if self.campIndex != -1 {
            for _ in 0..<arrR.count {
                self.searchDataArr.removeLastObject()
                
            }
        }
        
        for i in 0..<arrR.count {
            self.searchDataArr.add(arrR.object(at: i) as! NSDictionary)
            
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
    
    func filterApiHit(pageNum: Int) {
        if self.searchDataArr.count == 0 {
            applicationDelegate.startProgressView(view: self.dataContainingView)
            
        }
        
        var api: String = ""
        if self.filterDataDict == [:] {
            api = "filter.php/?userId=\(DataManager.userId as! String)"+"&latitude=\(String(describing: myCurrentLatitude))"+"&longitude=\(String(describing: myCurrentLongitude))"+"&distance=\(String(describing: 1))"+"&type=\(String(describing: "Car Camping"))"+"&offset=\(pageNum)"
            
        } else {
            api = "filter.php/?userId=\(DataManager.userId as! String)"+"&latitude=\(String(describing: (self.filterDataDict.value(forKey: "lattitude"))!))"+"&longitude=\(String(describing: (self.filterDataDict.value(forKey: "longitude"))!))"+"&distance=\(String(describing: (self.filterDataDict.value(forKey: "selectedDistance"))!))"+"&type=\(String(describing: (self.filterDataDict.value(forKey: "type"))!))"+"&offset=\(pageNum)"
            
        }
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.dataContainingView)

            self.stopAnimateAcitivity()
            self.searchReviewRefreshControl.endRefreshing()
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = dict["result"] as! NSArray

                 //   print(retValues)

                    self.reloadTbl(arrR: retValues, pageR: pageNum)
                    
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)

                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.dataContainingView)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)

            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)

            }
        }
    }

    
    func FavUnfavAPIHit(){
         applicationDelegate.startProgressView(view: self.dataContainingView)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "markFavourite.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
            
            let cell = self.categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            cell.favouriteButton.isUserInteractionEnabled = true
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
              //      print(dict)
              //      self.resetPaginationVar()
                    
                    let pagN = self.campIndex/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    
                    if self.comeFrom == filterPush {
                        self.filterApiHit(pageNum: self.pageNo)
                        
                    } else {
                        if self.searchType == googleSearch {
                            self.searchAPIHit(pageNum: self.pageNo)
                            
                        } else if self.searchType == "Home"{
                            
                            
                        } else {
                            self.filterApiHit(pageNum: self.pageNo)
                            
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
            applicationDelegate.dismissProgressView(view: self.dataContainingView)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
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
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.loginAlertFunc(vc: "addCamps", viewController: self)
        }
    }
    
    @IBAction func tapNotificationBtn(_ sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
            self.navigationController?.pushViewController(vc, animated: true)
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
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
                
            } else {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
                
            }
            
            self.FavUnfavAPIHit()
            
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
                if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: ((self.searchDataArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "campId"))!) {
                    matched = true
                    break
                }
            }
            
            if matched == false {
                tempArr.add((self.searchDataArr.object(at: self.campIndex) as! NSDictionary))
                
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                
                CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            } else {
                matched = false
                DispatchQueue.main.async {
                    CommonFunctions.showAlert(self, message: alreadySavedCampAlert, title: appName)
                    
                }
            }
        } else {
            tempArr.add((self.searchDataArr.object(at: self.campIndex) as! NSDictionary))
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
            
            CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            
        }
    }
}

extension SearchCampVC {
    @objc func endEditing () {
        
        favMarkbottomConstraint.constant = -150
        UIView.animate(withDuration: 1) {
            self.overlayview.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func favoutiteAction(sender: UIButton) {
        if DataManager.isUserLoggedIn! {
            self.campIndex = sender.tag
            if String(describing: ((self.searchDataArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
                self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
                
            } else {
                self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
                
            }
            
            self.campId = Int(String(describing: ((self.searchDataArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!))!
            
            self.favMarkbottomConstraint.constant = 150
            
            self.overlayview.tag = sender.tag
            self.overlayview.isHidden = false
            self.view.layoutIfNeeded()
        } else {
            self.loginAlertFunc(vc: "markFav", viewController: self)
            Singleton.sharedInstance.favIndex = sender.tag
        }
    }
}

extension SearchCampVC :UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.searchDataArr.count == 0 {
            if recallAPIView.isHidden == true {
                self.noDataFoundLbl.isHidden = false
            }
        } else {
            self.noDataFoundLbl.isHidden = true
            
        }
        return self.searchDataArr.count
    }
    
    @objc func tapTripsShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = categoryCollectionView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action:#selector(favoutiteAction(sender:)), for:.touchUpInside)
        
        if ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
            cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
            cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            
            if let img =  (((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0) as? String) {
                cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
            }
          
            cell.noImgLbl.isHidden = true
        } else {
            cell.featuredReviewImgView.image = UIImage(named: "")
            cell.noImgLbl.isHidden = false
            
        }
        
        cell.imagLocNameLbl.text = ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as? String)
        cell.ttlRatingLbl.text! = String(describing: ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!) //String(describing: (reducedNumberSum))
        cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
        cell.ttlReviewLbl.text! = (String(describing: (((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
        
        if ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
            
            let addr = ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            var trimmedAddr: String = ""
            trimmedAddr = addr.replacingOccurrences(of: ", , , ", with: ", ")
            if trimmedAddr == "" {
                trimmedAddr = addr.replacingOccurrences(of: ", , ", with: ", ")
            }
            cell.locationAddressLbl.text! = trimmedAddr
           
        }
        if let img = ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
            cell.autherImgView.sd_setShowActivityIndicatorView(true)
            cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.autherImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
        }
        cell.autherNameLbl.text = ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
        
        if String(describing: ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
            
        } else {
            cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
            
        }
        cell.tapProfilePicBtn.tag = indexPath.row
        cell.tapProfilePicBtn.addTarget(self, action: #selector(tapSearchProfilePicBtn(sender:)), for: .touchUpInside)
        
        if String(describing: ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
           // cell.playBtn.isHidden = true
            cell.playImg.isHidden = false
            
            cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
            cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            
        } else {
            cell.playImg.isHidden = true
        }
        
        return cell
    }
    
    @objc func tapSearchProfilePicBtn(sender: UIButton) {
        if DataManager.isUserLoggedIn! == false {
            self.loginAlertFunc(vc: "viewProfile", viewController: self)
            
        } else {
            let indexVal: NSDictionary = (self.searchDataArr.object(at: sender.tag) as! NSDictionary)
            
            if let campAuth = indexVal.value(forKey: "campAuthor") as? String {
                if String(describing: (DataManager.userId)) == campAuth {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                    vc.userInfoDict = indexVal
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
        vc.campId = String(describing: ((self.searchDataArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 1) {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        } else {
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(320))
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
        
    }
}

extension SearchCampVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.dataContainingView.isHidden = false
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        self.searchTxtFLd.text = place.name
        
        self.selectedLatti = place.coordinate.latitude
        self.selectedLongi = place.coordinate.longitude
        
        //
        self.callAPI()
        
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        self.dataContainingView.isHidden = true
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
}
