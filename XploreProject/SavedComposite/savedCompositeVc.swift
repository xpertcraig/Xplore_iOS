//
//  savedCompositeVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import SimpleImageViewer

class savedCompositeVc: UIViewController {

    //MARK:- Iboutlets
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var mainAllContentView: UIView!
    @IBOutlet weak var favouritesBtn: UIButtonCustomClass!
    @IBOutlet weak var favUnderLbl: UILabel!
    @IBOutlet weak var savedBtn: UIButtonCustomClass!
    @IBOutlet weak var savedUnderLbl: UILabel!
    
    @IBOutlet weak var favouriteSavedCollView: UICollectionView!
    @IBOutlet weak var backBtnImgView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    @IBOutlet weak var markAsFavBtn: UIButton!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK:- Variable Declarations
    private let commonDataViewModel = CommonUseViewModel()
    var comeFrom = ""
    var collArr: NSArray = []
    var favouriteCampArr: NSMutableArray = []
    var campId: Int = -1
    var campIndex: Int = -1
    var campType: String = ""
    var firstTime: Bool = false
    var checkVar: Bool = false
    
    ///
    var favouriteSavedRefreshControl = UIRefreshControl()
    
    //For Pagination
    var isDataLoading:Bool=false
    var pageNo:Int = 0
    var limit:Int = 5
    var upToLimit = 0
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backBtnPressedForPublished = false
        
        //refresh controll
        self.refreshData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.stopAnimateAcitivity()
        
        self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.favUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.favouritesBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
        
        self.tabBarController?.selectedIndex = 2
        if Singleton.sharedInstance.favouritesCampArr.count > 0 {
            self.reloadData(arrR: Singleton.sharedInstance.favouritesCampArr, pageR: 0)
            
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
        
        if DataManager.isUserLoggedIn! {
            if backBtnPressedForPublished == false {
                self.callAPI()
                
            } else {
                backBtnPressedForPublished = false
                
            }
            self.containerView.isHidden = true
        } else {
            Singleton.sharedInstance.loginComeFrom = savedCamp
            self.containerView.isHidden = false
            
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
        
        self.firstTime = false
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }

    //MARK:- Function Definitions
    func reloadTbl() {
        self.collArr = Singleton.sharedInstance.favouritesCampArr
        self.favouriteCampArr = self.collArr.mutableCopy() as! NSMutableArray
        self.setDelegateAndDataSource()
    }
    
    func setDelegateAndDataSource() {
        if self.campIndex == -1 {
            self.favouriteSavedCollView.delegate = self
            self.favouriteSavedCollView.dataSource = self
            self.favouriteSavedCollView.reloadData()
        } else {
            if self.favouriteCampArr.count-1 >= self.campIndex {
                let indexPath = IndexPath(item: self.campIndex, section: 0)
                
                var indexPaths = [IndexPath]()
                indexPaths.append(indexPath) //"indexPath" ideally get when tap didSelectItemAt or through long press gesture recogniser.
                
                let indexS = IndexSet(arrayLiteral: 0)
                self.favouriteSavedCollView.reloadSections(indexS)
                self.favouriteSavedCollView.reloadItems(at: indexPaths)
                
            } else {
                self.favouriteSavedCollView.reloadData()
                
            }
            
          //
            self.campIndex = -1
            self.campId = -1
        }
        
        if fromFavourites == true {
            self.favBtnAction()
            
        } else if self.firstTime == false {
            self.setInitialDesign()
            self.firstTime = true
            
        }
        self.mainAllContentView.isHidden = false
        
    }
    
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
    
    func setInitialDesign() {
        self.noDataLbl.isHidden = true
        
        self.collArr = []
        self.mainAllContentView.isHidden = true
        self.recallAPIView.isHidden = true
        self.overlayView.isHidden = true
    
        if Singleton.sharedInstance.fromMyProfile == true || Singleton.sharedInstance.fromMyProfileTabbarIndex != 2 {
            Singleton.sharedInstance.fromMyProfile = false
        
            if Singleton.sharedInstance.fromMyProfileTabbarIndex != 2 {
                self.backBtn.isHidden = false
                self.backBtnImgView.isHidden = false
            }
            self.campType = savedCamp
            self.collArr = []
            
            if (userDefault.value(forKey: mySavesCamps)) != nil {
                //self.collArr = userDefault.value(forKey: mySavesCamps) as! NSArray
                
                self.collArr = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            }
            
            self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
            self.savedUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
            self.savedBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
            
            self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
            self.favUnderLbl.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
            self.favouritesBtn.setTitleColor(UIColor.darkGray, for: .normal)
            
        } else {
            self.campType = favouritesCamp
            self.collArr = favouriteCampArr
            
            self.backBtn.isHidden = true
            self.backBtnImgView.isHidden = true
            
            self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
            self.favUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
            self.favouritesBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
            self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
            self.savedUnderLbl.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
            self.savedBtn.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.resetPaginationVar()
            self.favouritesApiHit(pageNum: self.pageNo)
            
        } else {
            self.collArr = []
            var savedTempArr: NSArray = []
            if (userDefault.value(forKey: mySavesCamps)) != nil {
                //self.collArr = userDefault.value(forKey: mySavesCamps) as! NSArray
                savedTempArr = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
                
                self.mainAllContentView.isHidden = false
            }
            if self.favouriteCampArr.count > 0 {
                self.campType = favouritesCamp
                
                self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
                self.savedUnderLbl.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
                self.savedBtn.setTitleColor(UIColor.darkGray, for: .normal)
                
                self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
                self.favUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
                self.favouritesBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
                
                self.collArr = self.favouriteCampArr
                
                self.favouriteSavedCollView.delegate = self
                self.favouriteSavedCollView.dataSource = self
                self.favouriteSavedCollView.reloadData()
            } else if savedTempArr.count > 0 {
                self.campType = savedCamp
                
                self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
                self.savedUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
                self.savedBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
                
                self.favouritesBtn.backgroundColor = UIColor.clear  //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
                self.favUnderLbl.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
                self.favouritesBtn.setTitleColor(UIColor.darkGray, for: .normal)
                
                self.collArr = savedTempArr
                
                self.favouriteSavedCollView.delegate = self
                self.favouriteSavedCollView.dataSource = self
                self.favouriteSavedCollView.reloadData()
            } else {
                self.recallAPIView.isHidden = false
                self.noDataLbl.isHidden = true
            }
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
        }
    }
    
    func refreshData() {
        self.favouriteSavedRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.favouriteSavedRefreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.favouriteSavedCollView.addSubview(self.favouriteSavedRefreshControl)
        
    }
    
    //MARK:- ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
        
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((self.favouriteSavedCollView.contentOffset.y + self.favouriteSavedCollView.frame.size.height) >= self.favouriteSavedCollView.contentSize.height) {
            if !isDataLoading{
                isDataLoading = true
                self.pageNo = self.pageNo + 1
              //  print(self.limit)
             //   print(upToLimit)
                if self.limit >= upToLimit {
                    //
                    
                } else {
                    self.limit = self.limit + 5
                  //  print(pageNo)
                    self.startAnimateAcitivity()
                    self.favouritesApiHit(pageNum: pageNo)
                    
                }
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //call Api's
        self.callAPI()
        
    }
    
    @objc func endEditing () {
       // favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayView.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func favoutiteAction(sender: UIButton) {
        self.campIndex = sender.tag
        if String(describing: ((self.collArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            self.markAsFavBtn.setTitle("Mark as favourite", for: .normal)
            
        } else {
            self.markAsFavBtn.setTitle("Delete from favourite", for: .normal)
            
        }
       
        self.campId = Int(String(describing: ((self.collArr.object(at: sender.tag) as! NSDictionary).value(forKey: "campId"))!))!
        
        // favMarkbottomConstraint.constant = 0
        //   UIView.animate(withDuration: 1) {
       // self.favMarkbottomConstraint.constant = 150
        
        self.overlayView.tag = sender.tag
        self.overlayView.isHidden = false
        self.view.layoutIfNeeded()
        //  }
    }
    
    //MARK:- Button Actions
    @IBAction func tapFavouriteBtn(_ sender: UIButton) {
        fromFavourites = true
        self.favBtnAction()
    }
    
    func favBtnAction() {
        self.campType = favouritesCamp
        self.collArr = []
        self.collArr = self.favouriteCampArr
        
        self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.favUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.favouritesBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
        
        self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        self.savedUnderLbl.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        self.savedBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        self.favouriteSavedCollView.reloadData()
        
    }
    
    @IBAction func tapSavedBtn(_ sender: UIButton) {
        fromFavourites = false
        
        self.campType = savedCamp
        self.collArr = []
        
        if (userDefault.value(forKey: mySavesCamps)) != nil {
            //self.collArr = userDefault.value(forKey: mySavesCamps) as! NSArray
            
            self.collArr = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
        }
        
        self.savedBtn.backgroundColor = UIColor.clear //UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.savedUnderLbl.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.savedBtn.setTitleColor(UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0) , for: .normal)
        
        self.favouritesBtn.backgroundColor = UIColor.clear //UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        self.favUnderLbl.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        self.favouritesBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        self.favouriteSavedCollView.reloadData()
    }
    
    @IBAction func closeFavouritesView(_ sender: Any) {
     //   favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayView.isHidden = true
            self.view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func tapfavUnfavBtn(_ sender: UIButton) {
        self.overlayView.isHidden = true
        
        if connectivity.isConnectedToInternet() {
            let indexPath = NSIndexPath(item: self.campIndex, section: 0)
            
            let cell = self.favouriteSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            
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
        self.overlayView.isHidden = true
        var tempArr: NSMutableArray = []
        
        if userDefault.value(forKey: mySavesCamps) != nil {
            tempArr = (NSKeyedUnarchiver.unarchiveObject(with: (userDefault.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            
            var matched: Bool = false
            for i in 0..<tempArr.count {
                if String(describing: ((tempArr.object(at: i) as! NSDictionary).value(forKey: "campId"))!) == String(describing: ((self.collArr.object(at: self.campIndex) as! NSDictionary).value(forKey: "campId"))!) {
                    matched = true
                    break
                }
            }
            
            if matched == false {
                tempArr.add((self.collArr.object(at: self.campIndex) as! NSDictionary))
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
                
                CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            } else {
                matched = false
                DispatchQueue.main.async {
                    CommonFunctions.showAlert(self, message: alreadySavedCampAlert, title: appName)
                    
                }
            }
        } else {
            tempArr.add((self.collArr.object(at: self.campIndex) as! NSDictionary))
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
            
            CommonFunctions.showAlert(self, message: campSavedAlert, title: appName)
            
        }
    }
    
    @IBAction func tapRetryBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.recallAPIView.isHidden = true
        if connectivity.isConnectedToInternet() {
            self.favouritesApiHit(pageNum: 0)
            
        } else {
            if self.favouriteCampArr.count == 0  {
                self.recallAPIView.isHidden = false
                self.noDataLbl.isHidden = true
                
            }
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func campDetail(_ sender: Any) {
        
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = Singleton.sharedInstance.fromMyProfileTabbarIndex
        //self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func profileAction(_ sender: Any) {
        self.checkVar = true
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        self.checkVar = true
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func AddCampAction(_ sender: Any) {
        self.checkVar = true
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func NotificationAction(_ sender: Any) {
        self.checkVar = true
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //selector actions
    @objc func discardSavedCampBtn(sender: UIButton) {
        let alert = UIAlertController(title: appName, message: sureALert, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            
            let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: mySavesCamps)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            tempArr.removeObject(at: sender.tag)
            
            self.collArr = tempArr
            self.favouriteSavedCollView.reloadData()
            
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: mySavesCamps)
            
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }

    
}
extension savedCompositeVc :UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @objc func tapTripsShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = favouriteSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.collArr.count == 0 {
            if recallAPIView.isHidden == true {
                self.noDataLbl.isHidden = false
                
            }             
        } else {
            self.noDataLbl.isHidden = true
            
        }
        return self.collArr.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        cell.favouriteButton.tag = indexPath.row
        cell.favouriteButton.addTarget(self, action:#selector(favoutiteAction(sender:)), for:.touchUpInside)
        
        //share button
        cell.shareCampBtn.tag = indexPath.row
        cell.shareCampBtn.addTarget(self, action: #selector(tapShareBtn(sender:)), for: .touchUpInside)
        
        //follow/unfollow button
        cell.followUnfollowBtn.tag = indexPath.row
        cell.followUnfollowBtn.addTarget(self, action: #selector(tapFollowUnfollowBtn(sender:)), for: .touchUpInside)
        
        let indexVal = (self.collArr.object(at: indexPath.row) as! NSDictionary)
        if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
            cell.followUnfollowBtn.isHidden = true
        } else {
            let followStatus = "\(indexVal.value(forKey: "follow") as? Int ?? 0)"
            if followStatus == "0" {
                cell.followUnfollowBtn.backgroundColor = UIColor.appThemeGreenColor()
                cell.followUnfollowBtn.setTitle("Follow", for: .normal)
                cell.followUnfollowBtn.setTitleColor(UIColor.white, for: .normal)
              //  cell.followUnfollowBtn.layer.borderColor = UIColor.appThemeKesariColor().cgColor
            } else {
                cell.followUnfollowBtn.backgroundColor = UIColor.white
                cell.followUnfollowBtn.setTitle("Following", for: .normal)
                cell.followUnfollowBtn.setTitleColor(UIColor.appThemeGreenColor(), for: .normal)
               // cell.followUnfollowBtn.layer.borderColor = UIColor.clear.cgColor
            }
            cell.followUnfollowBtn.isHidden = false
        }
        
        if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
            cell.featuredReviewImgView.image = nil
            
            cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
            cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            
            if let img =  ((((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0)) as? String) {
                
                cell.gradientView.isHidden = true
                cell.featuredReviewImgView.contentMode = .center
//                cell.featuredReviewImgView.sd_setImage(with: URL(string: img)) { (image, error, cache, url) in
//                    // Your code inside completion block
//                    cell.gradientView.isHidden = false
//                    cell.featuredReviewImgView.contentMode = .scaleAspectFill
//
//                }
                
                cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill){ (rSuccess) in
                    //
                }
                cell.gradientView.isHidden = false
                
              //  cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "PlaceHolder", contenMode: .scaleAspectFill)
            }
        
          //  cell.gradientView.isHidden = false
            cell.noImgLbl.isHidden = true
        } else {
            cell.gradientView.isHidden = true
            cell.featuredReviewImgView.contentMode = .center
            cell.featuredReviewImgView.image = UIImage(named: "PlaceHolder")
           // cell.noImgLbl.isHidden = false
            
        }
        
        cell.imagLocNameLbl.text = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as? String)
        cell.ttlRatingLbl.text! = String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!)
        cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
        cell.ttlReviewLbl.text! = (String(describing: (((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
        
        if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
            
            let addr = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            var trimmedAddr: String = ""
            trimmedAddr = addr.replacingOccurrences(of: ", , , ", with: ", ")
            if trimmedAddr == "" {
                trimmedAddr = addr.replacingOccurrences(of: ", , ", with: ", ")
            }
            cell.locationAddressLbl.text! = trimmedAddr
            
            
       //     cell.locationAddressLbl.text! = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            
            
        }
        
        if let img = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "profileImage") as? String) {
            
            cell.autherImgView.sd_setShowActivityIndicatorView(true)
            cell.autherImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            cell.autherImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                //
            }
       //     cell.autherImgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: ""))
            
        }
        cell.autherNameLbl.text = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
        
        if String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
            cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
            
        } else {
            cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
            
        }
        
        if campType == favouritesCamp {
            cell.favouriteButton.isHidden = false
            
            cell.removeDraftBtn.isHidden = true
            cell.followUnfollowBtn.isHidden = false
        } else {
            cell.favouriteButton.isHidden = true
            cell.followUnfollowBtn.isHidden = true
            cell.removeDraftBtn.isHidden = false
            cell.removeDraftBtn.tag = indexPath.row
            cell.removeDraftBtn.addTarget(self, action: #selector(discardSavedCampBtn(sender:)), for: .touchUpInside)
            
            let image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
            cell.removeDraftBtn.setImage(image, for: .normal)
            cell.removeDraftBtn.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
        }
        
        cell.tapProfilePicBtn.tag = indexPath.row
        cell.tapProfilePicBtn.addTarget(self, action: #selector(tapFevoritesProfilePicBtn(sender:)), for: .touchUpInside)
        
        if String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(320))
           
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
        
    }
    
    //share app campsite
    @objc func tapShareBtn(sender: UIButton) {
        let indexP = IndexPath(item: sender.tag, section: 0)
        let cell = self.favouriteSavedCollView.cellForItem(at: indexP) as? CustomCell
        
        let indexVal = (self.favouriteCampArr.object(at: sender.tag) as! NSDictionary)
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
                applicationDelegate.startProgressView(view: self.view)
                let indexVal: NSDictionary = (self.collArr.object(at: sender.tag) as! NSDictionary)
                let param: [String: Any] = ["userId": "\(DataManager.userId)", "follow": String(describing: (indexVal.value(forKey: "campAuthor"))!)]
                 
                var apiToBeCalled: String = ""
                let followStatus = "\(indexVal.value(forKey: "follow") as? Int ?? 0)"
                if followStatus == "0" {
                    apiToBeCalled = apiUrl.followApi.rawValue
                } else {
                    apiToBeCalled = apiUrl.unFollowApi.rawValue
                }
                print(param)
                self.commonDataViewModel.followUnfollowUwser(actionUrl: apiToBeCalled, param: param) { (rMsg) in
                    print(rMsg)
                    applicationDelegate.dismissProgressView(view: self.view)
                    let pagN = self.campIndex/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    
                    Singleton.sharedInstance.favouritesCampArr = []
                    self.favouritesApiHit(pageNum: self.pageNo)
                }
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            }
        }
    }
    
    @objc func tapFevoritesProfilePicBtn(sender: UIButton) {
        let indexVal: NSDictionary = (self.collArr.object(at: sender.tag) as! NSDictionary)
        
        if String(describing: (DataManager.userId)) == String(describing: (indexVal.value(forKey: "campAuthor"))!) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.userInfoDict = indexVal
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //MyCampDescriptionVc
        if self.campType == savedCamp {
            self.checkVar = true
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyCampDescriptionVc") as! MyCampDescriptionVc
            vc.comeFrom = mySavesCamps
            vc.recDraft = (self.collArr.object(at: indexPath.row) as! NSDictionary)
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
            vc.campId = String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension savedCompositeVc {
    func favouritesApiHit(pageNum: Int) {
        if (Singleton.sharedInstance.favouritesCampArr.count == 0 && userDefault.value(forKey: favouritesCampsStr) == nil) && self.favouriteCampArr.count == 0 {
            applicationDelegate.startProgressView(view: self.view)
            
        }
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "favouriteCampsite.php?userId="+(DataManager.userId as! String)+"&offset=\(pageNum)", onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            self.favouriteSavedRefreshControl.endRefreshing()
            self.recallAPIView.isHidden = true
            self.stopAnimateAcitivity()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = (dict["result"]! as! NSArray)
                    self.reloadData(arrR: retValues, pageR: pageNum)
                    
                } else {
                    self.setInitialDesign()
                    
                    self.favouriteSavedCollView.delegate = self
                    self.favouriteSavedCollView.dataSource = self
                    self.favouriteSavedCollView.reloadData()
                    
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.recallAPIView.isHidden = false
            self.noDataLbl.isHidden = true
            
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
    
    func reloadData(arrR: NSArray, pageR: Int) {
        if (arrR.count) % 5 == 0 {
            self.upToLimit = (pageR+1)*5 + 1
            
        } else {
            self.upToLimit = self.upToLimit + (arrR.count)
            
        }
        if pageR == 0 {
            self.favouriteCampArr = []
            
        }
        
        if self.campIndex != -1 {
            for _ in 0..<(arrR.count) {
                self.favouriteCampArr.removeLastObject()
                
            }
        }
        
        let count: Int = self.favouriteCampArr.count
        for i in 0..<arrR.count {
            self.favouriteCampArr.add(arrR.object(at: i) as! NSDictionary)
            
        }
        if self.campType == favouritesCamp && Singleton.sharedInstance.fromMyProfile == false{
            self.collArr = self.favouriteCampArr
            Singleton.sharedInstance.favouritesCampArr = self.collArr
            
            if self.collArr.count == 0 {
                self.setDelegateAndDataSource()
            }
        } else {
            fromFavourites = false
        }
        if self.firstTime == false {
            self.setDelegateAndDataSource()
            
        } else {
            if count < self.favouriteCampArr.count {
                self.favouriteSavedCollView.reloadData()
                
                let indexpathG = IndexPath(item: count, section: 0)
                self.favouriteSavedCollView.scrollToItem(at: indexpathG, at: .top, animated: true)
                self.favouriteSavedCollView.setNeedsLayout()
                
            }
        }
    }
    
    //MARK:- Api's Hit
    func FavUnfavAPIHit(){
         applicationDelegate.startProgressView(view: self.view)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)

        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "markFavourite.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in

                let cell = self.favouriteSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
                cell.favouriteButton.isUserInteractionEnabled = true

            ///////
           // applicationDelegate.dismissProgressView(view: self.view)

            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {

                  //  print(dict)

                    let pagN = self.campIndex/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    
                    Singleton.sharedInstance.favouritesCampArr = []
                    self.favouritesApiHit(pageNum: self.pageNo)

                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)

                }
            }
        }) { (error) in
            let cell = self.favouriteSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            cell.favouriteButton.isUserInteractionEnabled = true

            ////
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
              //  CommonFunctions.showAlert(self, message: serverError, title: appName)

            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)

            }
        }
    }
}
