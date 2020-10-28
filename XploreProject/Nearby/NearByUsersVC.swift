//
//  NearByUsersVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 28/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GoogleMaps

class NearByUsersVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, MapMarkerUserDelegate {
    func didTapViewProfileButton(data: NSDictionary) {
      //  print(data)
    }
    

    //MARK:- Iboutlets
    @IBOutlet weak var distanceValueSlider: UISlider!
    @IBOutlet weak var sliderValueLbl: UILabel!
    @IBOutlet weak var showMapVIew: GMSMapView!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var sliderContaingView: UIView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var notFoundLbl: UILabel!
    //MARK:- Variable Declarations
    var nearByUserArr: NSArray = []
    
    var sliderLbl : UILabel?
    
    private var infoWindow = MarkerUserInfo()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    var distanceParam: Int = 1
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.distanceValueSlider.addTarget(self, action: #selector(NearByUsersVC.updateKmsLabel(sender:)), for: .touchUpInside)
        
        self.infoWindow = loadNiB()
        self.showMapVIew.delegate = self
        
        if Singleton.sharedInstance.nearByUsersArr.count > 0 {
            self.nearByUserArr = Singleton.sharedInstance.nearByUsersArr
            self.notFoundLbl.isHidden = true
            self.showMapVIew.isHidden = false
            self.sliderContaingView.isHidden = false
            self.setMap()
            self.showMapVIew.delegate = self
        }
        
        //
        self.callAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    //MARK:- Function definitions
    func loadNiB() -> MarkerUserInfo {
        let infoWindow = MarkerUserInfo.instanceFromNib() as! MarkerUserInfo
        return infoWindow
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.nearByUsersApiHit()
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func setMap1() {
        self.showMapVIew.isMyLocationEnabled = true
        self.showMapVIew.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.showMapVIew.settings.myLocationButton = true
        let camera = GMSCameraPosition.camera(withLatitude: myCurrentLatitude, longitude: myCurrentLongitude, zoom: 10)
        self.showMapVIew.animate(to: camera)
        
    }
    
    func setMap() {
        self.showMapVIew.isMyLocationEnabled = true
        self.showMapVIew.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.showMapVIew.settings.myLocationButton = true
        let camera = GMSCameraPosition.camera(withLatitude: myCurrentLatitude, longitude: myCurrentLongitude, zoom: 10)
        
        showMapVIew.camera = camera
        self.showMapVIew.animate(to: camera)
        
        for i in 0..<self.nearByUserArr.count {
            let marker = GMSMarker()
            let markerImage:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            // markerImage.backgroundColor = UIColor.white
            
            markerImage.layer.cornerRadius = markerImage.frame.size.height/2
            markerImage.layer.masksToBounds = true
            markerImage.image = #imageLiteral(resourceName: "Asset")
            markerImage.contentMode = .scaleAspectFit
            
            marker.position = CLLocationCoordinate2D(latitude: Double(String(describing: ((self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "latitude"))!))!, longitude: Double(String(describing: ((self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "longitude"))!))!)
            
            let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
            markerView.addSubview(markerImage)
            marker.iconView = markerView
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
            
            //marker.accessibilityLabel = "name"
           // marker.title = (self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "name") as? String
            
            marker.zIndex = Int32(i)
            marker.map = self.showMapVIew
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture){
            print("dragged")
            
            self.infoWindow.removeFromSuperview()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let index = marker.zIndex
        
        locationMarker = marker
        
        locationMarker?.appearAnimation = .pop
        
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            
            print("locationMarker is nil")
            return false
        }
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.spotData = (self.nearByUserArr.object(at: Int(index)) as! NSDictionary)
        infoWindow.delegate = self
        // Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.layer.cornerRadius = 12
        infoWindow.clipsToBounds = true
        infoWindow.layer.borderWidth = 1
        infoWindow.layer.borderColor = UIColor.lightGray.cgColor
        
        self.infoWindow.userImgView.sd_setShowActivityIndicatorView(true)
        self.infoWindow.userImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        
        if let img =  ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "profileImage") as? String) {
            self.infoWindow.userImgView.loadImageFromUrl(urlString: img, placeHolderImg: "", contenMode: .scaleAspectFit){ (rSuccess) in
                //
            }
        }
        
      //  self.infoWindow.userImgView.sd_setImage(with: URL(string: String(describing: (self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "profileImage")!)), placeholderImage: UIImage(named: ""))
        
        if let name = (self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "name") as? String {
            self.infoWindow.userNameLbl.text! = name
            
        } else {
            self.infoWindow.userNameLbl.text! = ""
            
        }
        
        self.infoWindow.viewProfileBtn.tag = Int(index)
        self.infoWindow.viewProfileBtn.addTarget(self, action: #selector(tapViewProfileBtn(sender:)), for: .touchUpInside)
        
        // Offset the info window to be directly above the tapped marker
//        infoWindow.center = mapView.projection.point(for: location)
//        infoWindow.center.y = infoWindow.center.y + 80
        
        infoWindow.center = self.view.center
        infoWindow.center.y = self.view.center.y - 30
        self.view.addSubview(infoWindow)
        
        //
        let currentZoom: Float = (self.showMapVIew.camera.zoom)
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(String(describing: ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "latitude"))!))!, longitude: Double(String(describing: ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "longitude"))!))!, zoom: currentZoom)
        self.showMapVIew.camera = camera
        
        let update = GMSCameraUpdate.zoom(by: 4)
        self.showMapVIew.animate(with: update)
        
        return false
        
    }
    
    @objc func tapViewProfileBtn(sender: UIButton) {
        //print(self.nearByUserArr.object(at: sender.tag))
        
        
        
        if String(describing: ((self.nearByUserArr.object(at: sender.tag) as! NSDictionary).value(forKey: "userId"))!) == String(describing: (DataManager.userId)) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
            vc.userInfoDict = self.nearByUserArr.object(at: sender.tag) as! NSDictionary
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @objc func updateKmsLabel(sender: UISlider!) {
        let value = Int(sender.value)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.distanceValueSlider.layoutIfNeeded()
                
                self.sliderValueLbl.text = "\(value)" + " KM"
             //   print("Slider value = \(value)")
            })
        }
        
        self.distanceParam = value
        if value == 0 {
            self.distanceParam = 1
            
        }
        
        self.nearByUsersApiHit()
        
    }
    
    //MARK:- API hit
    func nearByUsersApiHit() {
        if Singleton.sharedInstance.nearByUsersArr.count == 0 {
            applicationDelegate.startProgressView(view: self.view)
        }
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "nearbyUser.php/?userId=\(DataManager.userId as! String)"+"&latitude=\(myCurrentLatitude)"+"&longitude=\(myCurrentLongitude)"+"&distance=\(self.distanceParam)", onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValue = dict["result"] as! NSArray
                    
                    self.nearByUserArr = retValue
                    if self.nearByUserArr.count == 0 {
                        self.notFoundLbl.isHidden = false
                        
                    } else {
                        self.notFoundLbl.isHidden = true
                        self.showMapVIew.isHidden = false
                        self.sliderContaingView.isHidden = false
                        self.setMap()
                        self.showMapVIew.delegate = self
                        
                    }
                } else {
                    self.setMap1()
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
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
    
}
