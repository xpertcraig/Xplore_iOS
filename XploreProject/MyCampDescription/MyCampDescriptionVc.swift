//
//  MyCampDescriptionVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Cosmos

import AVKit
import AVFoundation

import SimpleImageViewer

class MyCampDescriptionVc: UIViewController, AVPlayerViewControllerDelegate {

    //MARK:- Iboutlets
    @IBOutlet weak var campsiteNameLbl: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var myDraftCollVIew: UICollectionView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var ttlReviews: UILabel!
    
    @IBOutlet weak var campgroundTypeLbl: UILabel!
    @IBOutlet weak var climateLbl: UILabel!
    @IBOutlet weak var elevationLbl: UILabel!
    @IBOutlet weak var bstMnthLbl: UILabel!
    @IBOutlet weak var numberOfSitesLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var hookupsLbl: UILabel!
    @IBOutlet weak var amentiesLbl: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var publishEditBtnStackView: UIStackView!
    
    @IBOutlet weak var noImage: UILabel!
    
    
    
    //MARK:- Variable Declarations
    var comeFrom: String = ""
    var recDraft: NSDictionary = [:]
    var recDraftIndex: Int = -1
    var timer:Timer? = nil
    var myCampImgArr: NSArray = []
    
    var videoIndex: Int = -1
    var videoString : String = ""
    
    var playerController = AVPlayerViewController()
    
    //MARK:- Inbu8uild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if comeFrom == mySavesCamps {
            self.publishEditBtnStackView.isHidden = true
            
            self.setSavedCampDetail()
            
        } else {
            self.setDraftData()
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
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
    }
    
    //MARK:- Function Definition
    func setSavedCampDetail() {
        
        //print(self.recDraft)
        
        self.campsiteNameLbl.text! = self.recDraft.value(forKey: "campTitle") as! String
        
        let stringType = (self.recDraft.value(forKey: "campgroundType") as! NSArray).componentsJoined(by: ", ")
        
        if stringType == "" {
            self.campgroundTypeLbl.text! = "-"
           // self.campgroundTypeLbl.textColor = UIColor.white
            
        } else {
            self.campgroundTypeLbl.text! = stringType
            self.campgroundTypeLbl.textColor = UIColor.darkGray
            
        }
        
      //  self.campgroundTypeLbl.text! = stringType
        
        let stringBestMnth = (self.recDraft.value(forKey: "bestMonth") as! NSArray).componentsJoined(by: ", ")
        
        if stringBestMnth == "" {
            self.bstMnthLbl.text! = "-"
        //    self.bstMnthLbl.textColor = UIColor.white
            
        } else {
            self.bstMnthLbl.text! = stringBestMnth
            self.bstMnthLbl.textColor = UIColor.darkGray
            
        }
        
     //   self.bstMnthLbl.text! = stringBestMnth
        
        let stringHookup = (self.recDraft.value(forKey: "hookupsAvailable") as! NSArray).componentsJoined(by: ", ")
        
        if stringHookup == "" {
            self.hookupsLbl.text! = "-"
          //  self.hookupsLbl.textColor = UIColor.white
            
        } else {
            self.hookupsLbl.text! = stringHookup
            self.hookupsLbl.textColor = UIColor.darkGray
            
        }
        
        //self.hookupsLbl.text! = stringHookup
        
        let stringAmen = (self.recDraft.value(forKey: "campsiteamenities") as! NSArray).componentsJoined(by: ", ")
        
        if stringAmen == "" {
            self.amentiesLbl.text! = "-"
           // self.amentiesLbl.textColor = UIColor.white
            
        } else {
            self.amentiesLbl.text! = stringAmen
            self.amentiesLbl.textColor = UIColor.darkGray
            
        }
        
      //  self.amentiesLbl.text! = stringAmen
        
        self.descriptionText.text! = self.recDraft.value(forKey: "campDescription") as! String
        self.elevationLbl.text! = self.recDraft.value(forKey: "elevation") as! String
        self.numberOfSitesLbl.text! = self.recDraft.value(forKey: "numberofSites") as! String
        self.climateLbl.text! = self.recDraft.value(forKey: "climate") as! String
        
        self.priceLbl.text! = self.recDraft.value(forKey: "price") as! String
        
        self.addressLbl.text! = (self.recDraft.value(forKey: "campaddress") as! NSDictionary).value(forKey: "address") as! String
        self.stateLbl.text = self.recDraft.value(forKey: "campTitle") as? String
      
        //pageControl
        self.pageControl.isHidden = true
        self.pageControl.numberOfPages = (self.recDraft.value(forKey: "campImages") as! NSArray).count
        self.myCampImgArr = (self.recDraft.value(forKey: "campImages") as! NSArray)
        
        if (self.recDraft.value(forKey: "campImages") as! NSArray).count == 1 && String(describing: (self.recDraft.value(forKey: "videoindex"))!) == "1" {
            self.videoIndex = Int(String(describing: (self.recDraft.value(forKey: "videoindex"))!))!
            self.videoString = (self.recDraft.value(forKey: "campsiteVideo") as! String)
            
        } else {
            self.videoIndex = -1
            
        }
        self.myDraftCollVIew.reloadData()
        
    }
    
    func setDraftData() {
        
       // print(self.recDraft)
        
        self.campsiteNameLbl.text = self.recDraft.value(forKey: "campName") as? String
        
        if self.recDraft.value(forKey: "campType") as? String == "" {
            self.campgroundTypeLbl.text! = "-"
            //self.campgroundTypeLbl.textColor = UIColor.white
            
        } else {
            self.campgroundTypeLbl.textColor = UIColor.darkGray
            self.campgroundTypeLbl.text = self.recDraft.value(forKey: "campType") as? String
            
        }
        
        self.descriptionText.text! = self.recDraft.value(forKey: "description") as! String
        self.elevationLbl.text! = self.recDraft.value(forKey: "elevation") as! String
        self.numberOfSitesLbl.text! = self.recDraft.value(forKey: "numberofsites") as! String
        self.climateLbl.text! = self.recDraft.value(forKey: "climate") as! String
        
        if self.recDraft.value(forKey: "bestMonths") as! String == "" {
            self.bstMnthLbl.text! = "-"
           // self.bstMnthLbl.textColor = UIColor.white
            
        } else {
            self.bstMnthLbl.textColor = UIColor.darkGray
            self.bstMnthLbl.text! = self.recDraft.value(forKey: "bestMonths") as! String
            
        }
        
        if self.recDraft.value(forKey: "hookups") as! String == "" {
            self.hookupsLbl.text! = "-"
          //  self.hookupsLbl.textColor = UIColor.white
            
        } else {
            self.hookupsLbl.textColor = UIColor.darkGray
            self.hookupsLbl.text! = self.recDraft.value(forKey: "hookups") as! String
            
        }
        
        if self.recDraft.value(forKey: "amenities") as! String == "" {
            self.amentiesLbl.text! = "-"
          //  self.amentiesLbl.textColor = UIColor.white
            
        } else {
            self.amentiesLbl.textColor = UIColor.darkGray
            self.amentiesLbl.text! = self.recDraft.value(forKey: "amenities") as! String
            
        }
        self.priceLbl.text! = self.recDraft.value(forKey: "price") as! String
        
        self.addressLbl.text! = (self.recDraft.value(forKey: "campAddress1") as! String) + ", " + (self.recDraft.value(forKey: "campAddress2") as! String) + " " + (self.recDraft.value(forKey: "city") as! String) + ", " + (self.recDraft.value(forKey: "state") as! String) + ", " + (self.recDraft.value(forKey: "country") as! String)
        self.stateLbl.text! = self.recDraft.value(forKey: "campName") as! String
        
        //pageControl
        self.pageControl.isHidden = true
        self.pageControl.numberOfPages = (self.recDraft.value(forKey: "MyImgArr") as! NSArray).count
        self.myCampImgArr = (self.recDraft.value(forKey: "MyImgArr") as! NSArray)
        
        self.videoIndex = -1
        self.videoString = ""
        self.myDraftCollVIew.reloadData()
    }
   
    func checkValidations() ->Bool {
        if((((self.recDraft.value(forKey: "campName") as! String).trimmingCharacters(in: .whitespaces).isEmpty))){
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "campType") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "campAddress1") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "country") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "state") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "city") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "description") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "elevation") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "numberofsites") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "climate") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "bestMonths") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "hookups") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if ((self.recDraft.value(forKey: "amenities") as! String).trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        } else if self.myCampImgArr.count == 0 {
            CommonFunctions.showAlert(self, message: emptyPublishFieldAlert, title: appName)
            
            return true
        }
        return false
    }
    
    
    //MARK:- button actions
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        backBtnPressedForPublished = true        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        let Type = self.storyboard?.instantiateViewController(withIdentifier:"AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(Type, animated: true)
      
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let Type = self.storyboard?.instantiateViewController(withIdentifier:"NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(Type, animated: true)
        
    }
    
    @IBAction func moreAction(_ sender: Any){
        if let button = sender as? UIButton {
            if button.isSelected {
                // set deselected
                button.isSelected = false
                descriptionText.text = "I wouldn't include a property on your view controller(or even the cell necessarily)..."
                moreButton.setTitle("more", for: UIControlState.normal)
               descriptionText.numberOfLines = 2;
            } else {
                // set selected
                button.isSelected = true
                descriptionText.text = "I wouldn't include a property on your view controller (or even the cell necessarily), I'd simply have it on the model object itself (this way it's not bound to a specific view controller). When you create the cell from the model object, set the numberOfLines property based on the expanded state of the model item. When didSelectRowAtIndexPath fires (or whatever your selection method is) change the expanded state on the model item again, and either call reloadData (cell height will change, but without animation) or just tableView.beginUpdates(); tableView.endUpdates(); which is a bizarre but Apple-recommended way of just updating the heights of a cell with animation."
                moreButton.titleLabel?.text = "less"
                moreButton.setTitle("less", for: UIControlState.normal)
                descriptionText.numberOfLines = 0;
            }
        }
    }
    
    @IBAction func tapPublishBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.publishCampSiteApiHit()
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        
        vc.comeFrom = draftCamp
        vc.recDraftIndex = recDraftIndex
        vc.recDraft = recDraft
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    func publishCampSiteApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["userId": DataManager.userId, "campName": (self.recDraft.value(forKey: "campName") as! String), "campType": (self.recDraft.value(forKey: "campTypeIdsStr") as! String), "campAddress1": (self.recDraft.value(forKey: "campAddress1") as! String), "campAddress2": (self.recDraft.value(forKey: "campAddress2") as! String), "closestTown": (self.recDraft.value(forKey: "closestTown") as! String), "country": (self.recDraft.value(forKey: "country") as! String), "state": (self.recDraft.value(forKey: "state") as! String), "city": (self.recDraft.value(forKey: "city") as! String), "elevation": (self.recDraft.value(forKey: "elevation") as! String), "numberofsites": (self.recDraft.value(forKey: "numberofsites") as! String), "climate": (self.recDraft.value(forKey: "climate") as! String), "bestMonths": (self.recDraft.value(forKey: "bestMonths") as! String), "hookups": "antiquing", "amenities": (self.recDraft.value(forKey: "campAmentiesIdStr") as! String), "price": (self.recDraft.value(forKey: "price") as! String), "description": (self.recDraft.value(forKey: "description") as! String),"latitude": (self.recDraft.value(forKey: "latitude") as! String), "longitude": (self.recDraft.value(forKey: "longitude") as! String)]
        
        AlamoFireWrapper.sharedInstance.getPostMultipartForUploadMultipleImages(action: "addCampsite.php", param: param as! [String : Any], ImageArr: self.myCampImgArr, videoData: nil, videoIndex: -1, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVc") as! HomeVc
                    
                    if self.recDraftIndex != -1 {
                        if (userDefault.value(forKey: myDraft)) != nil {
                            let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
                            tempArr.removeObject(at: self.recDraftIndex)
                            
                            userDefault.set(NSKeyedArchiver.archivedData(withRootObject: tempArr), forKey: myDraft)
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
}
extension MyCampDescriptionVc : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.myCampImgArr.count == 0 {
            self.noImage.isHidden = false
            
        } else {
            self.noImage.isHidden = true
            
        }
        return self.myCampImgArr.count
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> () {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        pageControl.currentPage = Int(pageNumber)
    }
    
    //
    //After you've received data from server or you are ready with the datasource, call this method. Magic!
    func reloadCollectionView() {
        self.myDraftCollVIew.reloadData()
        
        // Invalidating timer for safety reasons
        self.timer?.invalidate()
        
        // Below, for each 3.5 seconds MyViewController's 'autoScrollImageSlider' would be fired
        self.timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(autoScrollImageSlider), userInfo: nil, repeats: true)
        
        //This will register the timer to the main run loop
        RunLoop.main.add(self.timer!, forMode: .commonModes)
        
    }
    
    @objc func autoScrollImageSlider() {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                let firstIndex = 0
                let lastIndex = 4
                
                let visibleIndices = self.myDraftCollVIew.indexPathsForVisibleItems
                let nextIndex = visibleIndices[0].row + 1
                
                let nextIndexPath: IndexPath = IndexPath.init(item: nextIndex, section: 0)
                let firstIndexPath: IndexPath = IndexPath.init(item: firstIndex, section: 0)
                
                if nextIndex > lastIndex {
                    self.myDraftCollVIew.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: true)
                    self.pageControl.currentPage = (firstIndexPath.row)
                    
                } else {
                    self.myDraftCollVIew.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
                    self.pageControl.currentPage = (nextIndexPath.row)
                    
                }
            }
        }
    }
    
    @objc func tapPlayBtn() {
        if self.videoString != "" {
            let player = AVPlayer(url: URL(string: self.videoString)!)
            playerController = AVPlayerViewController()
            NotificationCenter.default.addObserver(self, selector: #selector(didfinishplaying(note:)),name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            
            playerController.player = player
            playerController.allowsPictureInPicturePlayback = true
            playerController.delegate = self
            playerController.player?.play()
            self.present(playerController,animated:true,completion:nil)
            
        } else {
            CommonFunctions.showAlert(self, message: "Video corrupted", title: appName)
            
        }
        
//        var documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! //This piece of code will return path of document directory."
        
//        let video  = AVPlayer(url: URL(string: self.videoString)!)
//        playerController = AVPlayerViewController()
//
//
        
//
//        playerController.player = video
//
//        playerController.allowsPictureInPicturePlayback = true
//
//        playerController.delegate = self
//
//        playerController.player?.play()
//
//        self.present(playerController,animated:true,completion:nil)
        
//        let video  = AVPlayer(url: URL(string: self.videoString)!)
//
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = video
//        present(playerViewController, animated: true, completion:
//            {
//
//                playerViewController.player?.play()
//
//        })
    }
    
    @objc func didfinishplaying(note : NSNotification)
    {
        playerController.dismiss(animated: true,completion: nil)
        //        let alertview = UIAlertController(title:"Finished",message:"Video Finished",preferredStyle: .alert)
        //        alertview.addAction(UIAlertAction(title:"Ok",style: .default, handler: nil))
        //        self.present(alertview,animated:true,completion: nil)
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        let currentviewController =  navigationController?.visibleViewController
        
        if currentviewController != playerViewController
        {
            currentviewController?.present(playerViewController,animated: true,completion:nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampImagesCollectionViewCell", for: indexPath) as! CampImagesCollectionViewCell
        
        if self.videoIndex != -1 {
            if indexPath.row == self.videoIndex - 1 {
                cell.playBtn.isHidden = false
                cell.playImg.isHidden = false
                
                cell.playImg.image = cell.playImg.image?.withRenderingMode(.alwaysTemplate)
                cell.playImg.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
                
            } else {
                cell.playBtn.isHidden = true
                cell.playImg.isHidden = true
                
            }
        } else {
            cell.playBtn.isHidden = true
            cell.playImg.isHidden = true
            
        }
        
        cell.playBtn.tag = indexPath.row
        cell.playBtn.addTarget(self, action: #selector(tapPlayBtn), for: .touchUpInside)
        
        if self.myCampImgArr.object(at: indexPath.row) as? UIImage != nil {
            cell.campImgVIew.image = self.myCampImgArr.object(at: indexPath.row) as? UIImage
            
        } else {
            if (self.myCampImgArr).count != 0 {
                
                cell.campImgVIew.sd_setShowActivityIndicatorView(true)
                cell.campImgVIew.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.campImgVIew.sd_setImage(with: URL(string: (String(describing: ((self.myCampImgArr.object(at: indexPath.row) as! String))))), placeholderImage: UIImage(named: ""))
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexPath = NSIndexPath(row: indexPath.row, section: 0)
        
        let cell = myDraftCollVIew.cellForItem(at: indexPath as IndexPath) as! CampImagesCollectionViewCell
        let configuration = ImageViewerConfiguration { config in
            
            config.imageView = cell.campImgVIew
            
        }
        
        present(ImageViewerController(configuration: configuration), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.zero
        
    }
}
