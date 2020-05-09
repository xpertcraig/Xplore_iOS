//
//  GalleryVc.swift
//  XploreProject
//
//  Created by shikha kochar on 19/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

import AVKit
import AVFoundation

class GalleryVc: UIViewController, UIScrollViewDelegate, AVPlayerViewControllerDelegate {

    //MARK:- Iboutlets
    @IBOutlet weak var gallaryCollView: UICollectionView!
    @IBOutlet weak var previewGalleryCollView: UICollectionView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var noImgLbl: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK:- Variable Declarations
    var campId: String = ""
    var gallaryArr: NSArray = []
    var videoUrl: String = ""
    var videoindex: String = ""
    
    var firstLaunch: Bool = false
    var viewedIndex = IndexPath()
    
    var playerController = AVPlayerViewController()
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        //
        self.callAPI()
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
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.gallaryApiHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func toLeftDirection(draging: Bool) {
        if draging == false {
        
            let visibleItems: NSArray = self.gallaryCollView.indexPathsForVisibleItems as NSArray
            var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        
            for itr in visibleItems {
                if minItem.row > (itr as AnyObject).row {
                    minItem = itr as! NSIndexPath
                }
            }
        
        if minItem.row > 0 {
            let nextItem = NSIndexPath(row: minItem.row - 1, section: 0)
            
                self.gallaryCollView.scrollToItem(at: nextItem as IndexPath, at: .centeredHorizontally, animated: true)
                
                //
                self.previewGalleryCollView.scrollToItem(at: nextItem as IndexPath, at: .centeredHorizontally, animated: true)
                
                let nextItemNext = NSIndexPath(row: minItem.row, section: 0)
                
                let cell = self.previewGalleryCollView.cellForItem(at: nextItem as IndexPath)
                cell?.layer.borderWidth = 2.0
                cell?.layer.borderColor = UIColor.gray.cgColor
                
                let cell1 = self.previewGalleryCollView.cellForItem(at: nextItemNext as IndexPath)
                cell1?.layer.borderWidth = 0.0
                cell1?.layer.borderColor = UIColor.clear.cgColor
            
            self.viewedIndex = nextItemNext as IndexPath
            
            }
        } else {
            let visibleItems: NSArray = self.gallaryCollView.indexPathsForVisibleItems as NSArray
            var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
            
            for itr in visibleItems {
                if minItem.row > (itr as AnyObject).row {
                    minItem = itr as! NSIndexPath
                }
            }
            
            if minItem.row >= 0 {
                let nextItem = NSIndexPath(row: minItem.row, section: 0)
                self.previewGalleryCollView.scrollToItem(at: nextItem as IndexPath, at: .centeredHorizontally, animated: true)
                
                let nextItemNext = NSIndexPath(row: minItem.row + 1, section: 0)
                
                let cell = self.previewGalleryCollView.cellForItem(at: nextItem as IndexPath)
                cell?.layer.borderWidth = 2.0
                cell?.layer.borderColor = UIColor.gray.cgColor
                
                let cell1 = self.previewGalleryCollView.cellForItem(at: nextItemNext as IndexPath)
                cell1?.layer.borderWidth = 0.0
                cell1?.layer.borderColor = UIColor.clear.cgColor
                
                self.viewedIndex = nextItemNext as IndexPath
            }
        }
    }
    
    func toRightDirection(draging: Bool) {
        let visibleItems: NSArray = self.gallaryCollView.indexPathsForVisibleItems as NSArray
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        
        for itr in visibleItems {
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        
        if minItem.row < self.gallaryArr.count - 1 {
            let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
            
            if draging == false {
                self.gallaryCollView.scrollToItem(at: nextItem as IndexPath, at: .centeredHorizontally, animated: true)
                
            }
           
            self.previewGalleryCollView.scrollToItem(at: nextItem as IndexPath, at: .centeredHorizontally, animated: true)
            
            let nextItemPre = NSIndexPath(row: minItem.row, section: 0)
            
            let cell = self.previewGalleryCollView.cellForItem(at: nextItem as IndexPath)
            cell?.layer.borderWidth = 2.0
            cell?.layer.borderColor = UIColor.gray.cgColor
            
            let cell1 = self.previewGalleryCollView.cellForItem(at: nextItemPre as IndexPath)
            cell1?.layer.borderWidth = 0.0
            cell1?.layer.borderColor = UIColor.clear.cgColor
            
            self.viewedIndex = nextItemPre as IndexPath
        }
    }
    
    func gallaryApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "reviewGallery.php?userId=" + (DataManager.userId as! String) + "&campId=" + String(describing: (self.campId)), onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    
                    let retDict = (dict["result"] as! NSDictionary).value(forKey: "images") as! NSArray
                    self.gallaryArr = retDict
                    
                    self.videoUrl = String(describing: ((dict["result"] as! NSDictionary).value(forKey: "campsiteVideo"))!)
                    self.videoindex = String(describing: ((dict["result"] as! NSDictionary).value(forKey: "videoindex"))!)
                    
                    if self.gallaryArr.count != 0 {
                        self.leftBtn.isHidden = true
                        self.rightBtn.isHidden = true
                        
                        self.noImgLbl.isHidden = true
                        
                    } else {
                        self.noImgLbl.isHidden = false
                        
                    }                    
                    self.pageControl.numberOfPages = self.gallaryArr.count
                    self.gallaryCollView.reloadData()
                    self.previewGalleryCollView.reloadData()
                    
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
    
    //MARK:- Scrollview delegate
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.gallaryCollView {
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            if (actualPosition.x >= 0){
                // Dragging left
                self.toLeftDirection(draging: true)
                
            }else{
                // Dragging next
                self.toRightDirection(draging: true)
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func tapPreviousBtn(_ sender: UIButton) {
        self.toLeftDirection(draging: false)
        
    }
    
    @IBAction func tapNextBtn(_ sender: UIButton) {
        self.toRightDirection(draging: false)
        
    }
    
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
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}

//MARK:-
extension GalleryVc : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.gallaryArr.count
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) -> () {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        self.pageControl.currentPage = Int(pageNumber)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        
        cell.mygallaryImgView.sd_setShowActivityIndicatorView(true)
        cell.mygallaryImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        cell.mygallaryImgView.sd_setImage(with: URL(string: (String(describing: (self.gallaryArr.object(at: indexPath.row))))), placeholderImage: UIImage(named: ""))
       
        if (self.videoindex) != "-1" && (self.videoindex) != "0" && (self.videoindex) != "" && (self.videoindex) != "" {
            if indexPath.row == Int(self.videoindex)! - 1 {
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
        
        if collectionView.tag == 1 {
            if (firstLaunch != false && indexPath.row != self.viewedIndex.row) {
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
                
            } else {
                self.gallaryCollView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                self.previewGalleryCollView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIColor.gray.cgColor
                
                if indexPath.row == 0 {
                    firstLaunch = true
                    self.viewedIndex = indexPath
                    
                }
            }
        }
        
        return cell
    }
    
    @objc func tapPlayBtn(sender: UIButton) {
        if (self.videoUrl) != "" {
            let player = AVPlayer(url: URL(string: (self.videoUrl))!)
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            self.previewGalleryCollView.reloadData()
            
//            let cell1 = self.previewGalleryCollView.cellForItem(at: self.viewedIndex)
//            cell1?.layer.borderWidth = 0.0
//            cell1?.layer.borderColor = UIColor.clear.cgColor
            
            self.viewedIndex = indexPath
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.tag == 0) {
           return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
            
        }
          return CGSize(width: CGFloat(80), height: CGFloat(70))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
       
    }
}
