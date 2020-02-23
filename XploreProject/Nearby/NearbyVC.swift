//
//  NearbyVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 28/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import GoogleMaps
import Cosmos

class NearbyVC: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate, MapMarkerDelegate {
    func didTapInfoButton(data: NSDictionary) {
       // print(data)

    }
    
    //MARK:- Iboutlets
    @IBOutlet weak var showMapVIew: GMSMapView!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nearByLbl: UILabel!
    @IBOutlet weak var seeMoreTxtLbl: UILabel!
    
    @IBOutlet weak var notFoundLbl: UILabel!
    //MARK:- Variable Declarations
    var nearByUserArr: NSArray = []
    
    var recLat: String = ""
    var recLong: String = ""
    
    var selectedIndex: Int = 0
    
    private var infoWindow = CustomInfoWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        //self.markerOpenView()
        
        self.infoWindow = loadNiB()
        self.showMapVIew.delegate = self
        self.callAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func loadNiB() -> CustomInfoWindow {
        let infoWindow = CustomInfoWindow.instanceFromNib() as! CustomInfoWindow
        return infoWindow
        
    }
    
//    func markerOpenView() {
//        self.markerInfoView = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first as? CustomInfoWindow
//        self.markerInfoView?.frame = self.view.frame
//        self.view.addSubview(markerInfoView!)
//        markerInfoView?.isHidden = true
//
//    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.nearByUsersApiHit()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func setMap1() {
        self.showMapVIew.isMyLocationEnabled = true
        self.showMapVIew.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.showMapVIew.settings.myLocationButton = true
        let camera = GMSCameraPosition.camera(withLatitude: myCurrentLatitude, longitude: myCurrentLongitude, zoom: 12)
        self.showMapVIew.animate(to: camera)
        
    }
    
    func setMap() {
        self.showMapVIew.isMyLocationEnabled = true
        self.showMapVIew.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        self.showMapVIew.settings.myLocationButton = true
        let camera = GMSCameraPosition.camera(withLatitude: Double(self.recLat)!, longitude: Double(self.recLong)!, zoom: 12)

        showMapVIew.camera = camera
        self.showMapVIew.animate(to: camera)
        
        for i in 0..<self.nearByUserArr.count {
            let marker = GMSMarker()
            let markerImage:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            // markerImage.backgroundColor = UIColor.white
            
            markerImage.layer.cornerRadius = markerImage.frame.size.height/2
            markerImage.layer.masksToBounds = true
            markerImage.image = #imageLiteral(resourceName: "map-marker-point")
            markerImage.contentMode = .scaleAspectFit
            
            marker.position = CLLocationCoordinate2D(latitude: Double(String(describing: (((self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "lat"))!))!, longitude: Double(String(describing: (((self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "lng"))!))!)
            
            let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
            markerView.addSubview(markerImage)
            marker.iconView = markerView
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
            
//            marker.accessibilityLabel = "name"
//            marker.title = (self.nearByUserArr.object(at: i) as! NSDictionary).value(forKey: "campTitle") as? String
            
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
        
        // tap event handled by delegate
        
        let index = marker.zIndex
        self.selectedIndex = Int(index)
     //   print(self.selectedIndex)
        
        locationMarker = marker
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
        
        self.infoWindow.titleLbl.text! = (self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campTitle") as! String
        self.infoWindow.ratingLbl.text! = String(describing: ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campRating"))!)
        self.infoWindow.ratingView.rating = Double(String(describing: ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campRating"))!))!
        self.infoWindow.ttlRevierw.text! = (String(describing: ((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campReviews"))!)) + " reviews"
        
        self.infoWindow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapInfoWindowView)))
        
        // Offset the info window to be directly above the tapped marker
        //infoWindow.center = mapView.projection.point(for: location)
        //infoWindow.center.y = infoWindow.center.y - 50
        
        infoWindow.center = self.view.center
        infoWindow.center.y = self.view.center.y - 80
        
        self.view.addSubview(infoWindow)
        
        //
        let currentZoom: Float = (self.showMapVIew.camera.zoom)
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(String(describing: (((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "lat"))!))!, longitude: Double(String(describing: (((self.nearByUserArr.object(at: Int(index)) as! NSDictionary).value(forKey: "campaddress") as! NSDictionary).value(forKey: "lng"))!))!, zoom: currentZoom)
        self.showMapVIew.camera = camera
        
        let update = GMSCameraUpdate.zoom(by: 4)
        self.showMapVIew.animate(with: update)
        
        
        // remove color from currently selected marker
        if let selectedMarker = mapView.selectedMarker {
            selectedMarker.icon = GMSMarker.markerImage(with: nil)
        }
        
        // select new marker and make green
        showMapVIew.selectedMarker = marker
        marker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        return false
        
    }
    
    @objc func tapInfoWindowView() {
        
       // print(self.selectedIndex)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CampDescriptionVc") as! CampDescriptionVc
        vc.campId = String(describing: ((self.nearByUserArr.object(at: self.selectedIndex) as! NSDictionary).value(forKey: "campId"))!)
        self.navigationController?.pushViewController(vc, animated: true)
    
    }
    
    //MARK:- API hit
    func nearByUsersApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "nearBy.php?userId=\(DataManager.userId as! String)"+"&latitude=\(self.recLat)"+"&longitude=\(self.recLong)", onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValue = dict["result"] as! NSArray
                    
                  //  print(retValue)
                    
                    self.nearByUserArr = retValue
                    
                    if self.nearByUserArr.count == 0 {
                        self.notFoundLbl.isHidden = true
                        self.notFoundLbl.isHidden = false
                        
                    } else {
                        self.showMapVIew.isHidden = false
                        self.setMap()
                        self.showMapVIew.delegate = self
                        
                    }
                    
                } else {
                    self.setMap1()
                    self.showMapVIew.delegate = self
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            self.notFoundLbl.isHidden = false
            
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func profileAction(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}
