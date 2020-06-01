//
//  FilterVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreLocation

// set up protocol
@objc protocol filterValuesDelegate{
    func passFilterData(fillDict: NSDictionary)
}

class FilterVc: UIViewController, selectTypeDelegate {
        
    //MARK:- IbOutlets
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryTxtfld: UITextFieldCustomClass!
    
    @IBOutlet weak var stateview: UIView!
    @IBOutlet weak var stateTxtFld: UITextFieldCustomClass!
    
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityTxtFld: UITextFieldCustomClass!
    
    @IBOutlet weak var typeTxtFld: UILabel!
    @IBOutlet weak var showHideTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var amentiesView: UIView!
    @IBOutlet weak var amentiesTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var amentiesLbl: UILabel!
    @IBOutlet weak var countryStateCityTblView: UITableView!
    @IBOutlet weak var countryStateCityTop: NSLayoutConstraint!
    @IBOutlet weak var countryStateCityHeight: NSLayoutConstraint!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var distanceValueSlider: UISlider!
    @IBOutlet weak var sliderValueLbl: UILabel!
    @IBOutlet weak var backBtnImgView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var topNavigationHeight: NSLayoutConstraint!
    
    //MARK:- Variable Declarations
    var countryId: String = ""
    var stateId: String = ""
    var cityId: String = ""
    
    var campTypeIdsArr: NSArray = []
    var campAmentiesArr: NSArray = []
    
    var selectedType: String = ""
    
    var countiesArr: NSArray = []
    var stateArr: NSArray = []
    var cityArr: NSArray = []
    
    //searching
    var search:String = ""
    var searchData: NSMutableArray = []
    var searchActive: Bool = false
    
    var distanceParam: Int = 1
    
    var selectedLatti: Double = myCurrentLatitude
    var selectedLongi: Double = myCurrentLongitude
    
    var comeFrom: String = ""
    
    // this is where wevarclare our protocol
    var delegate:filterValuesDelegate?
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpOnLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.isUserLoggedIn! == true {
            self.topNavigationView.isHidden = false
            self.topNavigationHeight.constant = 44
            
        }
        if let uName = DataManager.name as? String {
            let fName = uName.components(separatedBy: " ")
            self.userNameBtn.setTitle(fName[0], for: .normal)
        }
        
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
        }
        
        self.countryStateCityTblView.isHidden = true
        self.noDataFoundLbl.isHidden = true
        
        //self.distanceParam = 1
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
        
        self.countryStateCityTblView.isHidden = true
        self.noDataFoundLbl.isHidden = true
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definitions
    func setUpOnLoad() {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.countryStateCityTblView.layer.borderColor = UIColor.lightGray.cgColor
        self.countryStateCityTblView.layer.borderWidth = 0.5
        self.countryStateCityTblView.layer.masksToBounds = true
        
        self.countryStateCityTblView.tableFooterView = UIView()
        
        self.showHideTxtFld.isHidden = false
        self.typeTxtFld.isHidden = true
        
        self.filterScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeCountryStateCityTbl)))
        
        self.amentiesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGastureView)))
        self.typeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTypeView)))
        
        self.countryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCountryView)))
        self.stateview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapStateView)))
        self.cityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCityView)))
        
        
    //    if DataManager.isUserLoggedIn! {
            callAPI()
            Singleton.sharedInstance.loginComeFrom = ""
            self.containerView.isHidden = true
            
        self.noDataFoundLbl.isHidden = true
        self.countryTxtfld.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
        self.stateTxtFld.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
        self.cityTxtFld.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
        
        self.distanceValueSlider.addTarget(self, action: #selector(NearByUsersVC.updateKmsLabel(sender:)), for: .touchUpInside)
        
        if self.comeFrom == notFromTabbar {
            self.backBtn.isHidden = false
            self.backBtnWidth.constant = 50
            self.backBtnImgView.isHidden = false
            
        } else {
            self.backBtn.isHidden = true
            self.backBtnWidth.constant = 25
            self.backBtnImgView.isHidden = true
            
        }
        
    }
    
    func resetData() {
        /////
        self.countryTxtfld.text! = ""
        self.stateTxtFld.text! = ""
        self.cityTxtFld.text! = ""
        //
        self.amentiesTxtFld.isHidden = false
        self.amentiesLbl.isHidden = true
        self.amentiesTxtFld.text = ""
        
        //
        self.showHideTxtFld.isHidden = false
        self.typeTxtFld.isHidden = true
        self.showHideTxtFld.text = ""
        
        self.distanceValueSlider.value = 1.0
        
        self.countryId = ""
        self.stateId = ""
        self.cityId = ""
        
        self.campTypeIdsArr = []
        self.campAmentiesArr = []
        
        self.selectedType = ""
        
        //  self.countiesArr = []
        self.stateArr = []
        self.cityArr = []
        
        //searching
        self.search = ""
        self.searchData = []
        self.searchActive = false
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.countiesApiCall()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @objc func updateKmsLabel(sender: UISlider!) {
        let value = Int(sender.value)
        DispatchQueue.main.async {
            self.sliderValueLbl.text = "\(value)" + " KM"
            //print("Slider value = \(value)")
        }
        
        print("slider value========\(value)")
        
        self.distanceParam = value
        if value == 0 {
            //self.distanceParam = 1
            
        }
    }
    
    //delegate method
    func selectType(campName: String, campIds: NSArray, key: String) {
        if key == "Select Type" {
            if campName == "" {
                self.showHideTxtFld.isHidden = false
                self.typeTxtFld.isHidden = true
                
                self.showHideTxtFld.text = ""
                
            } else {
                //self.showHideTxtFld.isHidden = true
                self.typeTxtFld.isHidden = false
                
                self.typeTxtFld.textColor = UIColor.darkGray
                self.typeTxtFld.text! = campName
                
                self.campTypeIdsArr = campIds
                
                self.showHideTxtFld.text = "0"
            }
        } else if key == "Select Amenities" {
            if campName == "" {
                self.amentiesTxtFld.isHidden = false
                self.amentiesLbl.isHidden = true
                
                self.amentiesTxtFld.text = ""
                
            } else {
               // self.amentiesTxtFld.isHidden = true
                self.amentiesLbl.isHidden = false
                
                self.amentiesLbl.textColor = UIColor.darkGray
                self.amentiesLbl.text! = campName
                
                self.campAmentiesArr = campIds
                
                self.amentiesTxtFld.text = "0"
            }
        }
    }
    
    @objc func closeCountryStateCityTbl() {
        self.searchActive = false
        
        self.countryStateCityTblView.isHidden = true
        self.noDataFoundLbl.isHidden = true
    }
    
    @objc func tapGastureView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Amenities"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.amentiesLbl.text!
        vc.campAmentiesArr = self.campAmentiesArr
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func tapTypeView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Type"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.typeTxtFld.text!
        vc.campTypeIdsArr = self.campTypeIdsArr
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func tapCountryView() {
        if self.countiesArr.count > 0 {
            self.countryStateCityTop.constant = 20
            self.selectedType = country
            self.countryStateCityTblView.isHidden = false
            self.countryStateCityTblView.reloadData()
            
        } else {
            CommonFunctions.showAlert(self, message: "No country found, please try again", title: appName)
            self.callAPI()
        }
    }
    
    @objc func tapStateView() {
        if countryId != "" {
            if connectivity.isConnectedToInternet() {
                self.countryStateCityTop.constant = 20
                self.selectedType = state
                self.countryStateCityTblView.isHidden = false
                self.countryStateCityTblView.reloadData()
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        } else {
            CommonFunctions.showAlert(self, message: countryEmptyAlertF, title: appName)
            
        }
    }
    
    @objc func tapCityView() {
        if stateId != "" {
            if connectivity.isConnectedToInternet() {
                self.countryStateCityTop.constant = 50
                self.selectedType = city
                self.countryStateCityTblView.isHidden = false
                self.countryStateCityTblView.reloadData()
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        } else {
            CommonFunctions.showAlert(self, message: stateEmptyAlertF, title: appName)
            
        }
    }
    
    func getLongiLatti(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
                    
                    return
            }
            
            
            self.selectedLatti =  (location.coordinate.latitude).roundToDecimal(4)
            self.selectedLongi =  (location.coordinate.longitude).roundToDecimal(4)
            
        }
    }
    
    //MARK:- Target action
    @objc func searchFieldValueChanged() {
        var arr: NSArray = []
       
        if selectedType == country {
            self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
            
            let predicate = NSPredicate(format: "countryName CONTAINS[c] %@", (self.countryTxtfld.text!))
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        } else if selectedType == state {
            self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
            
            let predicate = NSPredicate(format: "stateName CONTAINS[c] %@", (self.stateTxtFld.text!))
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        } else {
            self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
            
            let predicate = NSPredicate(format: "cityName CONTAINS[c] %@", (self.cityTxtFld.text!))
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        }
        
        self.searchData = []
        if arr.count > 0 {
            self.noDataFoundLbl.isHidden = true
            self.searchData = (arr as NSArray).mutableCopy() as! NSMutableArray
            
            self.countryStateCityTblView.reloadData()
            
        } else {
            if selectedType == country {
                if self.countryTxtfld.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            } else if selectedType == state {
                if self.stateTxtFld.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            } else {
                if self.cityTxtFld.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            }
            self.countryStateCityTblView.reloadData()
            
        }
    }
   
    func countiesApiCall() {
        //applicationDelegate.startProgressView(view: self.view)
        
        var userLId: String = ""
        if let userId = (DataManager.userId as? String) {
            userLId = userId
            
        }
        let api: String = "countries.php?userId=\(userLId)"
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValue = dict["result"] as! NSArray
                  //  print(dict)
                    self.countiesArr = retValue
                    
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
    
    func stateApiCall() {
        applicationDelegate.startProgressView(view: self.view)
        
        var userLId: String = ""
        if let userId = (DataManager.userId as? String) {
            userLId = userId
            
        }
        let api: String = "states.php?userId=\(userLId)&countryId=\(countryId)"
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let retValue = dict["result"] as! NSArray
                  //  print(dict)
                    self.stateArr = retValue
                    
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
    
    func cityApiCall() {
        applicationDelegate.startProgressView(view: self.view)
        
        var userLId: String = ""
        if let userId = (DataManager.userId as? String) {
            userLId = userId
            
        }
        let api: String = "cities.php?userId=\(userLId)&stateId=\(stateId)"
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: api, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let retValue = dict["result"] as! NSArray
                  //  print(dict)
                    self.cityArr = retValue
                    
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
    
    @IBAction func backAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapProfileAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        if DataManager.isUserLoggedIn! {
            if connectivity.isConnectedToInternet() {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
            }
        } else {
            self.loginAlertFunc(vc: "profile", viewController: self)
        }
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        self.searchActive = false
        self.view.endEditing(true)
        if DataManager.isUserLoggedIn! {
             if connectivity.isConnectedToInternet() {
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
                 self.navigationController?.pushViewController(vc, animated: true)
             } else {
                 CommonFunctions.showAlert(self, message: noInternet, title: appName)
             }
         } else {
             self.loginAlertFunc(vc: "nearByUser", viewController: self)
             
        }
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        if DataManager.isUserLoggedIn! {
            let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
            self.navigationController?.pushViewController(swRevealObj, animated: true)
            
        } else {
            self.loginAlertFunc(vc: "addCamps", viewController: self)
            
        }
        
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        if DataManager.isUserLoggedIn! {
            if connectivity.isConnectedToInternet() {
                let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
                self.navigationController?.pushViewController(swRevealObj, animated: true)
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
            }
        } else {
            self.loginAlertFunc(vc: "fromNoti", viewController: self)
            
        }
        
    }
    
    @IBAction func applyAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        
        if (((self.countryTxtfld.text!.trimmingCharacters(in: .whitespaces).isEmpty))) {
            self.countryTxtfld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: countryEmpty, title: appName)
            
        } else if (((self.stateTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))) {
            self.stateTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: stateEmpty, title: appName)
            
        }
//        else if (((self.cityTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))) {
//            self.cityTxtFld.becomeFirstResponder()
//            CommonFunctions.showAlert(self, message: cityEmpty, title: appName)
//            
//        }
        else {
            
            let tempstr = self.campTypeIdsArr.componentsJoined(by: ",")
            
            let dict: NSDictionary = ["lattitude": self.selectedLatti, "longitude": self.selectedLongi, "selectedDistance": self.distanceParam, "type": tempstr]
            
            delegate?.passFilterData(fillDict: dict)
            if self.comeFrom == notFromTabbar {
                self.navigationController?.popViewController(animated: true)
                
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchCampVC") as! SearchCampVC
                self.resetData()
                
                print(dict)
                
                vc.comeFrom = filterPush
                vc.filterDataDict = dict
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
}
extension FilterVc :UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.countryTxtfld || textField == stateTxtFld || textField == cityTxtFld {
            if self.countiesArr.count > 0 {
                self.searchActive = true
                if textField == countryTxtfld {
                    self.stateId = ""
                    self.cityId = ""
                    
                    self.stateTxtFld.text = ""
                    self.cityTxtFld.text = ""
                    
                    self.selectedType = country
                    self.countryStateCityTop.constant = 4
                    self.countryStateCityTblView.isHidden = false
                    
                    self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
                    self.countryStateCityTblView.reloadData()
                    
                } else if textField == stateTxtFld {
                    self.cityId = ""
                    self.cityTxtFld.text = ""
                    
                    if countryId == "" {
                        CommonFunctions.showAlert(self, message: countryEmptyAlertF, title: appName)
                        
                    } else {
                        self.selectedType = state
                        self.countryStateCityTop.constant = 4
                        self.countryStateCityTblView.isHidden = false
                        
                        self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
                        self.countryStateCityTblView.reloadData()
                        
                    }
                } else if textField == cityTxtFld {
                    if stateId == "" {
                        CommonFunctions.showAlert(self, message: stateEmptyAlertF, title: appName)
                        
                    } else {
                        self.selectedType = city
                        self.countryStateCityTop.constant = 75
                        self.countryStateCityTblView.isHidden = false
                        
                        self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
                        self.countryStateCityTblView.reloadData()
                        
                    }
                }
            } else {
                CommonFunctions.showAlert(self, message: "Please wait while we are  getting countries", title: appName)
                
                self.view.endEditing(true)
                
                self.callAPI()
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchActive = false
        self.countryStateCityTblView.isHidden = true
        self.noDataFoundLbl.isHidden = true
        
        if self.countryTxtfld.text == "" {
            self.countryId = ""
            self.stateId = ""
            self.cityId = ""
            
        }
        if self.stateTxtFld.text == "" {
            self.stateId = ""
            self.cityId = ""
            
        }
        if self.cityId == "" {
            self.cityId = ""
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive == true {
            if self.searchData.count == 0 {
                self.noDataFoundLbl.isHidden = false
                
            } else {
                self.noDataFoundLbl.isHidden = true
                
            }
            return self.searchData.count
            
        } else {
            if self.selectedType == country {
                return self.countiesArr.count
                
            } else if self.selectedType == state {
                if self.stateArr.count <= 5 && self.stateArr.count > 2 {
                    self.countryStateCityHeight.constant = CGFloat(self.stateArr.count * 44)
                    
                } else if self.stateArr.count == 1 {
                    self.countryStateCityHeight.constant = 100
                    
                } else {
                    self.countryStateCityHeight.constant = 250
                    
                }
                return self.stateArr.count
                
            } else if self.selectedType == city {
                if self.cityArr.count <= 5 && self.cityArr.count > 2 {
                    self.countryStateCityHeight.constant = CGFloat(self.cityArr.count * 44)
                    
                } else if self.cityArr.count == 1 {
                    self.countryStateCityHeight.constant = 100
                    
                } else {
                    self.countryStateCityHeight.constant = 250
                    
                }
                return self.cityArr.count
                
            }
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.countryStateCityTblView.dequeueReusableCell(withIdentifier: "CountryStateCityTableViewCell", for: indexPath) as! CountryStateCityTableViewCell
        
        if self.searchActive == true {
            
//            cell.tasksImgView.sd_setImage(with: URL(string: String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "taskImage"))!)), placeholderImage: UIImage(named: "No-Image-Available"))
//            cell.taskNameLbl.text! = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "taskTitle"))!)
//            cell.taskDesLbl.text! = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "taskDescription"))!)
//            cell.taskTimeLbl.text! = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "taskDate"))!)
//            cell.taskStatusLbl.text! = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "taskStatus"))!)
            
            
            if self.selectedType == country {
                cell.countryStateCityLbl.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
            } else if self.selectedType == state {
                cell.countryStateCityLbl.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
            } else if self.selectedType == city {
                cell.countryStateCityLbl.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
            }
            
        } else {
            if self.selectedType == country {
                cell.countryStateCityLbl.text! = (self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
            } else if self.selectedType == state {
                cell.countryStateCityLbl.text! = (self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
            } else if self.selectedType == city {
                cell.countryStateCityLbl.text! = (self.cityArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchActive == true {
            self.searchActive = false
            if self.selectedType == country {
                self.view.endEditing(true)
                self.countryTxtfld.text! = ""
                self.stateTxtFld.text! = ""
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.countryId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryId"))!)
                self.stateApiCall()
                self.countryTxtfld.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text!)
              //  self.stateTxtFld.becomeFirstResponder()
                
            } else if self.selectedType == state {
                self.view.endEditing(true)
                self.stateTxtFld.text! = ""
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.stateId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateId"))!)
                self.cityApiCall()
                self.stateTxtFld.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text! + "," + self.stateTxtFld.text!)
               // self.cityTxtFld.becomeFirstResponder()
                
            } else if self.selectedType == city {
                self.view.endEditing(true)
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.cityId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityId"))!)
                self.cityTxtFld.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text! + "," + self.stateTxtFld.text! + "," + self.cityTxtFld.text!)
                
            }
        } else {
            if self.selectedType == country {
                self.view.endEditing(true)
                self.countryTxtfld.text! = ""
                self.stateTxtFld.text! = ""
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.countryId = String(describing: ((self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryId"))!)
                self.stateApiCall()
                self.countryTxtfld.text! = (self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text!)
               // self.stateTxtFld.becomeFirstResponder()
                
            } else if self.selectedType == state {
                self.view.endEditing(true)
                self.stateTxtFld.text! = ""
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.stateId = String(describing: ((self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateId"))!)
                self.cityApiCall()
                self.stateTxtFld.text! = (self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text! + "," + self.stateTxtFld.text!)
              //  self.cityTxtFld.becomeFirstResponder()
                
            } else if self.selectedType == city {
                self.view.endEditing(true)
                self.cityTxtFld.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.cityId = String(describing: ((self.cityArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityId"))!)
                self.cityTxtFld.text! = (self.cityArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
                self.getLongiLatti(address: self.countryTxtfld.text! + "," + self.stateTxtFld.text! + "," + self.cityTxtFld.text!)
                
            }
        }
    }
}
