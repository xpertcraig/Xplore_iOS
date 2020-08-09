//
//  MyCampsiteVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import SimpleImageViewer

class MyCampsiteVc: UIViewController {
    
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var draftButton: UIButton!
    @IBOutlet weak var publishedButton: UIButton!
    @IBOutlet weak var mainAllContentView: UIView!
    @IBOutlet weak var publishSavedCollView: UICollectionView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var favoriteMarkView: UIViewCustomClass!
    @IBOutlet weak var markAsFavBtn: UIButton!
    @IBOutlet weak var favMarkbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtnImgView: UIImageView!
    @IBOutlet weak var backBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var recallAPIView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK:- Variable Declarations
    var comeFrom = ""
    var collArr: NSArray = []
    var draftArr: NSArray = []
    
    var publishCampArr: NSMutableArray = []
    var campId: Int = -1
    var campIndex: Int = -1
    var campType: String = ""
    var firstTime: Bool = false
    
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
        
        if fromSaveDraft == true && Singleton.sharedInstance.fromMyProfile == false {
            self.onDraftBtn()
            
        } else {
            self.publishedButton.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
            self.publishedButton.setTitleColor(UIColor.white , for: .normal)
               
            self.draftButton.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
            self.draftButton.setTitleColor(UIColor.darkGray, for: .normal)
            
        }
        if Singleton.sharedInstance.myCampsArr.count > 0 {
            self.reloadData(arrR: Singleton.sharedInstance.myCampsArr, pageR: 0)
        }
        if Singleton.sharedInstance.myCampsArr.count > 0 && fromSaveDraft == false {
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
        
        if DataManager.isUserLoggedIn! {
            if backBtnPressedForPublished == false {
                self.callAPI()
            } else {
                backBtnPressedForPublished = false
            }
            self.containerView.isHidden = true
        } else {
            Singleton.sharedInstance.loginComeFrom = myCampsStr
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
       
    //MARK:- Function Definitions
    func reloadTbl() {
        self.collArr = Singleton.sharedInstance.myCampsArr
        self.publishCampArr = self.collArr.mutableCopy() as! NSMutableArray
        self.setDelegateAndDataSource()
    }
    
    func setDelegateAndDataSource() {
        if self.campIndex == -1 {
            
            self.publishSavedCollView.delegate = self
            self.publishSavedCollView.dataSource = self
            self.publishSavedCollView.reloadData()
        } else {
            let indexPath = IndexPath(item: self.campIndex, section: 0)
            
            var indexPaths = [IndexPath]()
            indexPaths.append(indexPath) //"indexPath" ideally get when tap didSelectItemAt or through long press gesture recogniser.
            
            let indexS = IndexSet(arrayLiteral: 0)
            self.publishSavedCollView.reloadSections(indexS)
            self.publishSavedCollView.reloadItems(at: indexPaths)
            
            self.campIndex = -1
            self.campId = -1
        }
        
        if fromSaveDraft == true && Singleton.sharedInstance.fromMyProfile == false {
            self.onDraftBtn()
        } else if self.firstTime == false {
            fromSaveDraft = false
            Singleton.sharedInstance.fromMyProfile = false
            self.setInitialDesign()
            self.firstTime = true
        }
        
        self.mainAllContentView.isHidden = false
        self.recallAPIView.isHidden = true
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
 
        self.mainAllContentView.isHidden = true
        self.recallAPIView.isHidden = true
        self.overlayView.isHidden = true
     
        if self.comeFrom == myProfile || Singleton.sharedInstance.fromMyProfileTabbarIndex != 3 {
            //self.comeFrom = ""
            self.backBtnWidth.constant = 50
            self.backBtn.isHidden = false
            self.backBtnImgView.isHidden = false
            
        } else {
            self.backBtnWidth.constant = 20
            self.backBtn.isHidden = true
            self.backBtnImgView.isHidden = true
        }
        self.campType = publishCamp
        self.collArr = []
        self.collArr = self.publishCampArr
        
        self.publishSavedCollView.reloadData()
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.resetPaginationVar()
            self.publishApiHit(pageNum: pageNo)
        } else {
            if self.publishCampArr.count == 0 {
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
        self.publishSavedCollView.addSubview(self.favouriteSavedRefreshControl)
    }
    
    //MARK:- ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if campType == publishCamp {
            isDataLoading = false
        }
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if campType == publishCamp {
            if ((self.publishSavedCollView.contentOffset.y + self.publishSavedCollView.frame.size.height) >= self.publishSavedCollView.contentSize.height) {
                if !isDataLoading{
                    isDataLoading = true
                    self.pageNo = self.pageNo + 1
                 //   print(self.limit)
                //    print(upToLimit)
                    if self.limit >= upToLimit {
                        //
                    } else {
                        self.limit = self.limit + 5
                      //  print(pageNo)
                        self.startAnimateAcitivity()
                        self.publishApiHit(pageNum: pageNo)
                        
                    }
                }
            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if campType == publishCamp {
            //call Api's
            self.callAPI()
        }
    }
    
    @objc func endEditing () {
        //favMarkbottomConstraint.constant = 150
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
        
        self.overlayView.tag = sender.tag
        self.overlayView.isHidden = false
        self.view.layoutIfNeeded()
    }
    
    //MARK:- Button Actions
    @IBAction func closeFavouritesView(_ sender: Any) {
        //favMarkbottomConstraint.constant = 150
        UIView.animate(withDuration: 1) {
            self.overlayView.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapfavUnfavBtn(_ sender: UIButton) {
        self.overlayView.isHidden = true
        
        if connectivity.isConnectedToInternet() {
            let indexPath = NSIndexPath(item: self.campIndex, section: 0)
            
            let cell = self.publishSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            
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
            self.resetPaginationVar()
            self.publishApiHit(pageNum: pageNo)
        } else {
            if self.publishCampArr.count == 0  {
                self.recallAPIView.isHidden = false
                self.noDataLbl.isHidden = true
            }
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
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
    
    @IBAction func addCampsite(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapNotifivationBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func draftAction(_ sender: Any) {
        fromSaveDraft = true
        self.onDraftBtn()
    }
    
    func onDraftBtn() {
        
        self.campType = draftCamp
        self.collArr = []
        
        if self.draftArr.count == 0 {
            if (userDefault.value(forKey: myDraft)) != nil {
                self.collArr = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            }
        } else {
            self.collArr = self.draftArr
        }
        draftButton.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        draftButton.setTitleColor(UIColor.white , for: .normal)
        
        publishedButton.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        publishedButton.setTitleColor(UIColor.darkGray, for: .normal)
        
        self.publishSavedCollView.reloadData()
    }
    
    @IBAction func publishedAction(_ sender: Any) {
        self.onPubishBtn()
    }
    
    func onPubishBtn() {
        fromSaveDraft = false
        self.campType = publishCamp
        self.collArr = []
        
        self.collArr = self.publishCampArr
        
        self.publishedButton.backgroundColor = UIColor(red: 0/255, green: 109/255, blue: 104/255, alpha: 1.0)
        self.publishedButton.setTitleColor(UIColor.white , for: .normal)
        
        self.draftButton.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        self.draftButton.setTitleColor(UIColor.darkGray, for: .normal)
        
        self.publishSavedCollView.reloadData()
    }
    
    @objc func editDraftBtnActions(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        
        fromSaveDraft = true
        vc.comeFrom = draftCamp
        vc.recDraftIndex = sender.tag
        vc.recDraft = (self.collArr.object(at: sender.tag) as! NSDictionary)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func discardDraftBtnActions(sender: UIButton) {
        let alert = UIAlertController(title: appName, message: sureALert, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
           
            let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
            tempArr.removeObject(at: sender.tag)
          
            self.collArr = tempArr
            self.publishSavedCollView.reloadData()
            
            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: myDraft)
            
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = Singleton.sharedInstance.fromMyProfileTabbarIndex
       // self.navigationController?.popViewController(animated: true)
    }
}

extension MyCampsiteVc :UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    @objc func tapDraftShowImgView(sender: UIButton) {
        let indexPath = NSIndexPath(row: sender.tag, section: 0)
        
        let cell = publishSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.featuredReviewImgView
            
        }
        present(ImageViewerController(configuration: configuration), animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        if campType == draftCamp {
            cell.favouriteButton.isHidden = true
            
            cell.editPencilImgView.isHidden = false
            cell.editDraftBtn.isHidden = false
            cell.editDraftBtn.tag = indexPath.row
            cell.editDraftBtn.addTarget(self, action: #selector(editDraftBtnActions(sender:)), for: .touchUpInside)
            
            cell.removeDraftBtn.isHidden = false
            cell.removeDraftBtn.tag = indexPath.row
            cell.removeDraftBtn.addTarget(self, action: #selector(discardDraftBtnActions(sender:)), for: .touchUpInside)
            
            let image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
            cell.removeDraftBtn.setImage(image, for: .normal)
            cell.removeDraftBtn.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            
            if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "MyImgArr") as? NSArray)?.count != 0 {
                cell.featuredReviewImgView.image = nil
                cell.featuredReviewImgView.image = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "MyImgArr") as? NSArray)?.object(at: 0) as? UIImage
                
                cell.noImgLbl.isHidden = true
            } else {
                cell.featuredReviewImgView.image = UIImage(named: "")
                cell.noImgLbl.isHidden = false
            }
            
            cell.imagLocNameLbl.text = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campName") as? String)
            cell.ttlRatingLbl.isHidden = true
            cell.reviewFeaturedStarView.isHidden = true
            cell.ttlReviewLbl.isHidden = true
            
            cell.addressTopConstraint.constant = 0

            if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String) != "" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String) != "" {
                cell.locationAddressLbl.text! = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "city") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "state") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "country") as! String)
            } else if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String) == "" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String) == "" {
                cell.locationAddressLbl.text! = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "city") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "state") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "country") as! String)
            } else if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String) != "" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String) == "" {
                
                cell.locationAddressLbl.text! = "\((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String), \((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "city") as! String), \((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "state") as! String), \((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "country") as! String)"
            } else if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress1") as! String) == "" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String) != "" {
                cell.locationAddressLbl.text! = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campAddress2") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "city") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "state") as! String)+", "+((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "country") as! String)
            }
            cell.playImg.isHidden = true
        } else {
            cell.ttlRatingLbl.isHidden = false
            cell.reviewFeaturedStarView.isHidden = false
            cell.ttlReviewLbl.isHidden = false
            
            cell.favouriteButton.isHidden = false
            
            cell.removeDraftBtn.isHidden = true
            cell.editPencilImgView.isHidden = true
            cell.editDraftBtn.isHidden = true
            
            cell.favouriteButton.tag = indexPath.row
            cell.favouriteButton.addTarget(self, action:#selector(favoutiteAction(sender:)), for:.touchUpInside)
            
            if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count != 0 {
                
                cell.featuredReviewImgView.sd_setShowActivityIndicatorView(true)
                cell.featuredReviewImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                if let img =  ((((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0)) as? String) {
                    cell.featuredReviewImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit)
                }
                
             //   cell.featuredReviewImgView.sd_setImage(with: URL(string: (String(describing: (((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).object(at: 0))))), placeholderImage: UIImage(named: ""))
                
                cell.noImgLbl.isHidden = true
            } else {
                cell.featuredReviewImgView.image = UIImage(named: "")
                cell.noImgLbl.isHidden = false
            }
            
            cell.imagLocNameLbl.text = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTitle") as? String)
            cell.ttlRatingLbl.text! = String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!)
            cell.reviewFeaturedStarView.rating = Double(String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campRating"))!))!
            cell.ttlReviewLbl.text! = (String(describing: (((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campTotalReviews")))!)) + " review"
            
            cell.addressTopConstraint.constant = 8
            if ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as? NSDictionary) != nil {
                
                let addr = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
                var trimmedAddr: String = ""
                trimmedAddr = addr.replacingOccurrences(of: ", , , ", with: ", ")
                if trimmedAddr == "" {
                    trimmedAddr = addr.replacingOccurrences(of: ", , ", with: ", ")
                }
                cell.locationAddressLbl.text! = trimmedAddr
                
              //  cell.locationAddressLbl.text! = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
            }
            cell.autherNameLbl.text = ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "authorName") as? String)
            
            
            if String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "isFav"))!) == "0" {
                cell.favouriteButton.setImage(UIImage(named: "Favoutites"), for: .normal)
            } else {
                cell.favouriteButton.setImage(UIImage(named: "markAsFavourite"), for: .normal)
            }
            
            if String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "videoindex"))!) == "1" && ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campImages") as! NSArray).count == 1 {
               // cell.playBtn.isHidden = true
                cell.playImg.isHidden = false
                
                cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
                cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            } else {
               // cell.playBtn.isHidden = true
                cell.playImg.isHidden = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(320))
           
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         backBtnPressedForPublished = true
        if campType == publishCamp {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
            vc.campId = String(describing: ((self.collArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "campId"))!)
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyCampDescriptionVc") as! MyCampDescriptionVc
            fromSaveDraft = true
            vc.comeFrom = draftCamp
            vc.recDraftIndex = indexPath.row
            vc.recDraft = (self.collArr.object(at: indexPath.row) as! NSDictionary)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension MyCampsiteVc {
    func publishApiHit(pageNum: Int) {
        if (Singleton.sharedInstance.myCampsArr.count == 0 && userDefault.value(forKey: myCampsStr) == nil){
            if fromSaveDraft == false {
                applicationDelegate.startProgressView(view: self.view)
                
            }
        }
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "publishedCampsite.php?userId="+(DataManager.userId as! String)+"&offset=\(pageNum)", onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            self.favouriteSavedRefreshControl.endRefreshing()
            self.stopAnimateAcitivity()
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let retValues = (dict["result"]! as! NSArray)
                    self.reloadData(arrR: retValues, pageR: pageNum)
                    
                } else {
                    self.setInitialDesign()
                    
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            if self.publishCampArr == [] {
                self.recallAPIView.isHidden = false
                self.noDataLbl.isHidden = true
            }
            
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
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
            self.publishCampArr = []
        }
        if self.campIndex != -1 {
            for _ in 0..<(arrR.count) {
                self.publishCampArr.removeLastObject()
            }
        }
        
        let count: Int = self.publishCampArr.count
        for i in 0..<arrR.count {
            self.publishCampArr.add(arrR.object(at: i) as! NSDictionary)
        }
        self.collArr = self.publishCampArr
        Singleton.sharedInstance.myCampsArr = self.collArr
        
        if pageR == 0 {
            self.setDelegateAndDataSource()
        } else {
            if count < self.publishCampArr.count {
                self.publishSavedCollView.reloadData()
                
                let indexpathG = IndexPath(item: count, section: 0)
                self.publishSavedCollView.scrollToItem(at: indexpathG, at: .top, animated: true)
                self.publishSavedCollView.setNeedsLayout()
                
            }
        }
    }
    
    //MARK:- Api's Hit
    func FavUnfavAPIHit(){
         applicationDelegate.startProgressView(view: self.view)
        let indexPath = NSIndexPath(item: self.campIndex, section: 0)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "markFavourite.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
            
            let cell = self.publishSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
            cell.favouriteButton.isUserInteractionEnabled = true
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let pagN = self.campIndex/5
                    self.pageNo = pagN
                    self.limit = (pagN+1)*5
                    self.publishApiHit(pageNum: self.pageNo)
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                }
            }
        }) { (error) in
            let cell = self.publishSavedCollView.cellForItem(at: indexPath as IndexPath) as! CustomCell
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
}
