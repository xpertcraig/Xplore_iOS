//
//  AddNewCampsiteVc.swift
//  XploreProject
//
//  Created by shikha kochar on 23/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import GooglePlaces

import OpalImagePicker
import Photos

import MobileCoreServices

class AddNewCampsiteVc: UIViewController, selectTypeDelegate {

    //MARK:- IbOUtlets
    @IBOutlet weak var addCampsiteTitleLbl: UILabel!
    
    @IBOutlet weak var scroolView: UIScrollView!
    @IBOutlet weak var campsiteName: UITextFieldCustomClass!
    @IBOutlet weak var campsiteAddress1: UITextFieldCustomClass!
    @IBOutlet weak var campType: UITextFieldCustomClass!
    @IBOutlet weak var campTypeLbl: UILabel!
    
    @IBOutlet weak var countrySelectView: UIView!
    @IBOutlet weak var stateview: UIView!
    @IBOutlet weak var cityView: UIView!
    
    @IBOutlet weak var Country: UITextFieldCustomClass!
    @IBOutlet weak var state: UITextFieldCustomClass!
    @IBOutlet weak var city: UITextFieldCustomClass!
    
    @IBOutlet weak var campsiteAddress2: UITextFieldCustomClass!
    @IBOutlet weak var closetTown: UITextFieldCustomClass!
    
    @IBOutlet weak var longitude: UITextFieldCustomClass!
    @IBOutlet weak var latitude: UITextFieldCustomClass!
    
    @IBOutlet weak var numberOfSites: UITextFieldCustomClass!
    @IBOutlet weak var descriptionTxtFld: UITextView!
    @IBOutlet weak var webSiteTxtView: UITextView!
    
    
   // @IBOutlet weak var descriptionTxtFld: SkyFloatingLabelTextField!
    @IBOutlet weak var elevation: UITextFieldCustomClass!
    @IBOutlet weak var bestMonthToVisit: UITextFieldCustomClass!
    @IBOutlet weak var bestMonthLbl: UILabel!
    
    @IBOutlet weak var climate: UITextFieldCustomClass!
    @IBOutlet weak var hookupsAvailable: UITextFieldCustomClass!
    @IBOutlet weak var hookupLbl: UILabel!
    
    @IBOutlet weak var amenities: UITextFieldCustomClass!
    @IBOutlet weak var amentiesLbl: UILabel!
    
    @IBOutlet weak var takePhoto: UITextFieldCustomClass!
    @IBOutlet weak var price: UITextFieldCustomClass!
    
    @IBOutlet weak var myLocationOnOffSwitch: UISwitch!
    @IBOutlet weak var myCampImgCollVIew: UICollectionView!
    @IBOutlet weak var myImgHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var myImgView: UIView!
    
    @IBOutlet weak var countryStateCityTblView: UITableView!
    @IBOutlet weak var countryStateCityTop: NSLayoutConstraint!
    @IBOutlet weak var countryStateCityHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var hookupsView: UIView!
    @IBOutlet weak var amentiesView: UIView!
    @IBOutlet weak var bestMonthView: UIView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    @IBOutlet weak var closestView: UIView!
    @IBOutlet weak var fetchBtn: UIButtonCustomClass!
    
    //
    @IBOutlet weak var blackOutView: UIView!
    @IBOutlet weak var typeOrAnyOtherLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    @IBOutlet weak var addBtn: UIButtonCustomClass!
    
    //MARK:- Variable Declarations
    var myCampImgArr: NSMutableArray = []
    //image picker
    let imgPicker = UIImagePickerController()
    var imageData: Data?
    var mySavedCampSites: NSMutableArray = []
    
    var comeFrom: String = ""
    var recDraft: NSDictionary = [:]
    var recDraftIndex: Int = -1
    
    //
    //MARK:- Variable Declarations
    var countryId: String = ""
    var stateId: String = ""
    var cityId: String = ""
    
    var selectedType: String = ""
    
    var countiesArr: NSArray = []
    var stateArr: NSArray = []
    var cityArr: NSArray = []
    
    //searching
    var search:String = ""
    var searchData: NSMutableArray = []
    var searchActive: Bool = false
    
    var campTypeIdsArr: NSArray = []
    var campAmentiesIdArr: NSArray = []
    var campHokupsIdArr: NSArray = []
    
    /////multiple images
    var ImageUrlPath:[String] = [String()]
    var ImageUrl = String()
    
    var videoString: String = ""
    var videoData: Data?
    var videoImg: UIImage?
    var videoImgIndex: Int = -1
    
    //MARK:- Inbuild FUnction
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.countryStateCityTblView.layer.borderColor = UIColor.lightGray.cgColor
        self.countryStateCityTblView.layer.borderWidth = 0.5
        self.countryStateCityTblView.layer.masksToBounds = true
        
        self.countryStateCityTblView.tableFooterView = UIView()
     //   self.scroolView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeCountryStateCityTbl)))
                
        self.closestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapClosestView)))
        self.countrySelectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCountryView)))
        self.stateview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapStateView)))
        self.cityView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCityView)))
        
        //
        self.callAPI()
        
        self.noDataFoundLbl.isHidden = true
        self.Country.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
        self.state.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
        self.city.addTarget(self, action: #selector(searchFieldValueChanged), for: .editingChanged)
       
        self.typeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTypeView)))
        self.hookupsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHookUpsView)))
        self.amentiesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAmentiesView)))
        self.bestMonthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBestMonthView)))
        
        self.myImgHeightConstant.constant = 0
        
        self.myLocationOnOffSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        self.addKeyBoardObservers()
        
        self.imgPicker.delegate = self
        
        if comeFrom == draftCamp {
            self.addCampsiteTitleLbl.text = "Edit Campsite"
            
            self.addBtn.setTitle("PUBLISH", for: .normal)
            
            self.setDraftData()
            
        } else {
            self.addCampsiteTitleLbl.text = "Add Campsite"
            self.myLocationOnOffSwitch.isOn = true
            self.locationOn()
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.countryStateCityTblView.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definition
    @objc func tapTypeView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Type"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.campTypeLbl.text!
        vc.campTypeIdsArr = self.campTypeIdsArr
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapHookUpsView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Hookups"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.hookupLbl.text!
        vc.campHookupsArr = self.campHokupsIdArr
        
       // print(self.campHokupsIdArr)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapAmentiesView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Amenities"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.amentiesLbl.text!
        vc.campAmentiesArr = self.campAmentiesIdArr
        
      //  print(self.campAmentiesIdArr)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapBestMonthView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
        vc.key = "Select Months"
        vc.delegate = self
        
        vc.setCampNameIfAvailable = self.bestMonthLbl.text!
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.countiesApiCall()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func setDraftData() {
        
      //  print(self.recDraft)
        
        let campAmenStr = self.recDraft.value(forKey: "campAmentiesIdStr") as! String
        let campAmenArr = campAmenStr.components(separatedBy: ",")
       // print(campAmenArr) // returns ["1", "2", "3"]
        
        let campHokupStr = self.recDraft.value(forKey: "campHokupsIdStr") as! String
        let campHokupArr = campHokupStr.components(separatedBy: ",")
      //  print(campHokupArr) // returns ["1", "2", "3"]
        
        let campTypeStr = self.recDraft.value(forKey: "campTypeIdsStr") as! String
        let campTypeArr = campTypeStr.components(separatedBy: ",")
     //   print(campTypeArr) // returns ["1", "2", "3"]
        
        self.campTypeIdsArr = campTypeArr as NSArray
        self.campHokupsIdArr = campHokupArr as NSArray
        self.campAmentiesIdArr = campAmenArr as NSArray
        
        self.campTypeLbl.text! = self.recDraft.value(forKey: "campType") as! String
        if self.campTypeLbl.text! == "" {
            self.campType.isHidden = false
            self.campTypeLbl.isHidden = true
            
            self.campType.text = ""
            
        } else {
         //   self.campType.isHidden = true
            self.campTypeLbl.isHidden = false
            
            self.campType.text = "0"
            
        }
        
        self.campsiteName.text! = self.recDraft.value(forKey: "campName") as! String
        
        self.campsiteAddress1.text! = self.recDraft.value(forKey: "campAddress1") as! String
        self.campsiteAddress2.text! = self.recDraft.value(forKey: "campAddress2") as! String
        self.closetTown.text! = self.recDraft.value(forKey: "closestTown") as! String
        self.Country.text! = self.recDraft.value(forKey: "country") as! String
        self.state.text! = self.recDraft.value(forKey: "state") as! String
        self.city.text! = self.recDraft.value(forKey: "city") as! String
        self.latitude.text! = self.recDraft.value(forKey: "latitude") as! String
        self.longitude.text! = self.recDraft.value(forKey: "longitude") as! String
        self.descriptionTxtFld.text! = self.recDraft.value(forKey: "description") as! String
        self.webSiteTxtView.text! = self.recDraft.value(forKey: "webUrl") as! String
        self.elevation.text! = self.recDraft.value(forKey: "elevation") as! String
        self.numberOfSites.text! = self.recDraft.value(forKey: "numberofsites") as! String
        self.climate.text! = self.recDraft.value(forKey: "climate") as! String
        
        self.bestMonthLbl.text! = self.recDraft.value(forKey: "bestMonths") as! String
       
        if self.bestMonthLbl.text! == "" {
            self.bestMonthToVisit.isHidden = false
            self.bestMonthLbl.isHidden = true
            
            self.bestMonthToVisit.text = ""
            
        } else {
         //   self.bestMonthToVisit.isHidden = true
            self.bestMonthLbl.isHidden = false
            
            self.bestMonthToVisit.text = "0"
            
        }
        
        self.hookupLbl.text! = self.recDraft.value(forKey: "hookups") as! String
        if self.hookupLbl.text! == "" {
            self.hookupsAvailable.isHidden = false
            self.hookupLbl.isHidden = true
            
            self.hookupsAvailable.text = ""
            
        } else {
           // self.hookupsAvailable.isHidden = true
            self.hookupLbl.isHidden = false
            
            self.hookupsAvailable.text = "0"
            
            self.hookupsAvailable.textColor = UIColor.white
            
        }
        
        self.amentiesLbl.text! = self.recDraft.value(forKey: "amenities") as! String
        if self.amentiesLbl.text! == "" {
            self.amenities.isHidden = false
            self.amentiesLbl.isHidden = true
            
            self.amenities.text = ""
            
        } else {
           // self.amenities.isHidden = true
            self.amentiesLbl.isHidden = false
            
            self.amenities.text = "0"
        }
        
        self.price.text! = self.recDraft.value(forKey: "price") as! String
        
        self.myCampImgArr = (self.recDraft.value(forKey: "MyImgArr") as! NSArray).mutableCopy() as! NSMutableArray
        if self.myCampImgArr.count != 0 {
            self.myImgHeightConstant.constant = 60
            
        } else {
            self.myImgHeightConstant.constant = 0
            
        }
       
        if self.recDraft.value(forKey: "locationOnOff") as! String == "0" {
            self.myLocationOnOffSwitch.isOn = false
            
        } else {
            self.myLocationOnOffSwitch.isOn = true
            
        }
        
        self.myCampImgCollVIew.reloadData()
        
    }
    
    @objc func closeCountryStateCityTbl() {
        self.searchActive = false
        self.countryStateCityTblView.isHidden = true
        
    }
    
    @IBAction func tapCountryBtn(_ sender: Any) {
        self.countryStateCityTop.constant = 20
        self.selectedType = country
        self.countryStateCityTblView.isHidden = false
        self.countryStateCityTblView.reloadData()
        
    }
    
    @objc func tapClosestView() {
        let acController = GMSAutocompleteViewController()
        
        // Sets the background of results - top line
        acController.primaryTextColor = UIColor.black
        UINavigationBar.appearance().barTintColor = appThemeColor
        // Sets the background of results - second line
        acController.secondaryTextColor = UIColor.black
        
        // Sets the text color of the text in search field
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
    }
    
    @objc func tapCountryView() {
        self.countryStateCityTop.constant = 20
        self.selectedType = country
        self.countryStateCityTblView.isHidden = false
        self.countryStateCityTblView.reloadData()
        
    }
    
    @objc func tapStateView() {
        if countryId != "" {
            if connectivity.isConnectedToInternet() {
                self.countryStateCityTop.constant = 100
                self.selectedType = "state"
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
                self.countryStateCityTop.constant = 100
                self.selectedType = "city"
                self.countryStateCityTblView.isHidden = false
                self.countryStateCityTblView.reloadData()
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        } else {
            CommonFunctions.showAlert(self, message: stateEmptyAlertF, title: appName)
            
        }
    }
    
    //MARK:- Target action
    @objc func searchFieldValueChanged() {
        var arr: NSArray = []
        
        print(self.Country.text!)

        
        if selectedType == country {
            self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
            let predicate = NSPredicate(format: "countryName CONTAINS[c] %@", (self.Country.text!))
           
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        } else if selectedType == "state" {
            self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
            
            let predicate = NSPredicate(format: "stateName CONTAINS[c] %@", (self.state.text!))
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        } else {
            self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
            
            let predicate = NSPredicate(format: "cityName CONTAINS[c] %@", (self.city.text!))
            arr = (self.searchData as NSArray).filtered(using: predicate) as NSArray
            
        }
        
        self.searchData = []
        if arr.count > 0 {
            self.noDataFoundLbl.isHidden = true
            self.searchData = (arr as NSArray).mutableCopy() as! NSMutableArray
            
            self.countryStateCityTblView.reloadData()
            
        } else {
            if selectedType == country {
                if self.Country.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            } else if selectedType == "state" {
                if self.state.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            } else {
                if self.city.text! == "" {
                    self.noDataFoundLbl.isHidden = true
                    self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.noDataFoundLbl.isHidden = false
                    
                }
            }
            self.countryStateCityTblView.reloadData()
            
        }
    }
    
    //MARK:- API call
    func countiesApiCall() {
        //applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "countries.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValue = dict["result"] as! NSArray
                   // print(dict)
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
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "states.php?userId=" + (DataManager.userId as! String)+"&countryId="+countryId, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let retValue = dict["result"] as! NSArray
                   // print(dict)
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
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "cities.php?userId=" + (DataManager.userId as! String)+"&stateId="+stateId, onSuccess: { (responseData) in
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
    
    func checkValidations() ->Bool {
        if(((self.campsiteName.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.campsiteName.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: campsiteEmptyAlert, title: appName)
            
            return true
        } else if (self.campTypeLbl.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: typeEmptyAlert, title: appName)
            
            return true
        } else if (self.campsiteAddress1.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.campsiteName.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: campsiteAddressAlert, title: appName)
            
            return true
        } else if (self.Country.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.Country.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: countryEmpty, title: appName)
            
            return true
        } else if (self.state.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.state.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: stateEmpty, title: appName)
            
            return true
        } else if (self.city.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.city.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cityEmpty, title: appName)
            
            return true
        } else if (self.descriptionTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.descriptionTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: descriptionEmptyAlert, title: appName)
            
            return true
        } else if (self.elevation.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.elevation.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: elevationEmptyAlert, title: appName)
            
            return true
        } else if (self.numberOfSites.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.numberOfSites.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: numberOfSitesEmptyAlert, title: appName)
            
            return true
        } else if (self.climate.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            self.climate.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: climateEmptyAlert, title: appName)
            
            return true
        } else if (self.bestMonthLbl.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: bestMonthEmptyAlert, title: appName)
            
            return true
        }
//        else if (self.hookupLbl.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
//            CommonFunctions.showAlert(self, message: hookupsEmptyalert, title: appName)
//
//            return true
//        }
        else if (self.amentiesLbl.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
            CommonFunctions.showAlert(self, message: amentiesEmptyAlert, title: appName)
            
            return true
        } else if self.myCampImgArr.count == 0 {
            CommonFunctions.showAlert(self, message: noPhotoAlert, title: appName)
            
            return true
        }
        return false
    }
    
    func selectType(campName: String, campIds: NSArray, key: String) {
        if key == "Select Type" {
            if campName == "" {
                self.campType.isHidden = false
                self.campTypeLbl.isHidden = true
                
                self.campType.text = ""
                
            } else {
                //self.campType.isHidden = true
                self.campTypeLbl.isHidden = false
                
                self.campTypeLbl.textColor = UIColor.darkGray
                self.campTypeLbl.text! = campName
                
                self.campTypeIdsArr = campIds
                
                self.campType.text = "0"
            }
        } else if key == "Select Amenities" {
            if campName == "" {
                self.amenities.isHidden = false
                self.amentiesLbl.isHidden = true
                
                self.amenities.text = ""
                
            } else {
              //  self.amenities.isHidden = true
                self.amentiesLbl.isHidden = false
                
                self.amentiesLbl.textColor = UIColor.darkGray
                self.amentiesLbl.text! = campName
                
                self.campAmentiesIdArr = campIds
                
                self.amenities.text = "0"
            }
        } else if key == "Select Months" {
            if campName == "" {
                self.bestMonthToVisit.isHidden = false
                self.bestMonthLbl.isHidden = true
                
                self.bestMonthToVisit.text = ""
            } else {
              //  self.bestMonthToVisit.isHidden = true
                self.bestMonthLbl.isHidden = false
                
                self.bestMonthLbl.textColor = UIColor.darkGray
                self.bestMonthLbl.text! = campName
                
                self.bestMonthToVisit.text = "0"
            }
        } else if key == "Select Hookups" {
            if campName == "" {
                self.hookupsAvailable.isHidden = false
                self.hookupLbl.isHidden = true
                
                self.hookupsAvailable.text = ""
                
            } else {
                //self.hookupsAvailable.isHidden = true
                self.hookupLbl.isHidden = false
                
                self.hookupLbl.textColor = UIColor.darkGray
                self.hookupLbl.text! = campName
                
                self.campHokupsIdArr = campIds
                
                self.hookupsAvailable.text = "0"
            }
        }        
    }
    
    func getLocationNameAndImage() {
        if userLocation != nil {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation!) { (placemarksArray, error) in
                if placemarksArray != nil {
                    if (placemarksArray?.count)! > 0 {
                        let placemark = placemarksArray?.first
                        
                        if self.myLocationOnOffSwitch.isOn == false {
                            self.campsiteAddress1.text = ""
                            self.campsiteAddress2.text = ""
                            self.closetTown.text = ""
                           // self.closetTown.isUserInteractionEnabled = true
                            self.Country.text = ""
                            self.state.text = ""
                            self.city.text = ""
                            self.longitude.text = ""
                            self.latitude.text = ""
                            
                            self.descriptionTxtFld.text = ""
                            self.elevation.text = ""
                            self.numberOfSites.text = ""
                            self.climate.text = ""
                            
                            self.bestMonthToVisit.text = ""
                            self.bestMonthLbl.text = ""
                            self.bestMonthLbl.isHidden = true
                            
                            self.hookupsAvailable.text = ""
                            self.hookupLbl.text = ""
                            self.hookupLbl.isHidden = true
                            self.campHokupsIdArr = []
                            
                            self.amenities.text = ""
                            self.amentiesLbl.text = ""
                            self.amentiesLbl.isHidden = true
                            self.campAmentiesIdArr = []
                            
//                            self.campType.text = ""
//                            self.campTypeLbl.text = ""
//                            self.campTypeLbl.isHidden = true
//                            self.campTypeIdsArr = []
                            
                            self.price.text = ""
                            self.myCampImgArr = []
                            self.myImgHeightConstant.constant = 0
                            self.myCampImgCollVIew.reloadData()
                            
                        } else {
                            //                        print(placemark?.addressDictionary)
                            //                        print(placemark?.addressDictionary!["State"])
                            //                        print(placemark?.country)
                            //                        print(placemark?.locality)
                            //                        print(placemark?.location)
                            //                        print(placemark?.region)
                            //                        print(placemark?.subAdministrativeArea)
                            //                        print(placemark?.subLocality)
                            //                        print(placemark?.subThoroughfare)
                            //                        print(placemark?.thoroughfare)
                            //                        print(placemark?.ocean)
                            
                           // self.closetTown.isUserInteractionEnabled = false
                            if placemark?.addressDictionary != nil {
                                if (placemark?.addressDictionary!["State"]) != nil {
                                    self.state.text = (placemark?.addressDictionary!["State"]) as? String
                                    
                                }
                                if (placemark?.addressDictionary!["Country"]) != nil {
                                    self.Country.text = (placemark?.addressDictionary!["Country"]) as? String
                                    
                                }
                                if (placemark?.addressDictionary!["City"]) != nil {
                                    self.city.text = (placemark?.addressDictionary!["City"]) as? String
                                    
                                }
                                if (placemark?.addressDictionary!["Name"]) != nil {
                                    self.campsiteAddress1.text = (placemark?.addressDictionary!["Name"]) as? String
                                    
                                }
                                
                                if (placemark?.addressDictionary!["SubLocality"]) != nil {
                                    self.campsiteAddress2.text = (placemark?.addressDictionary!["SubLocality"]) as? String
                                    
                                }
                            }
                            
                            self.getLatLong()
                            
//                            self.longitude.text = String(describing: (myCurrentLongitude))
//                            self.latitude.text = String(describing: (myCurrentLatitude))
                            
                        }
                    }
                }
            }
        }
    }
    
    func getClosestPlace(userloc: CLLocation) {
        if userloc != nil {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userloc) { (placemarksArray, error) in
                if placemarksArray != nil {
                    if (placemarksArray?.count)! > 0 {
                        let placemark = placemarksArray?.first
                        
                        if placemark?.addressDictionary != nil {
                            if (placemark?.addressDictionary!["State"]) != nil {
                                self.state.text = (placemark?.addressDictionary!["State"]) as? String
                                
                            }
                            if (placemark?.addressDictionary!["Country"]) != nil {
                                self.Country.text = (placemark?.addressDictionary!["Country"]) as? String
                                
                            }
                            if (placemark?.addressDictionary!["City"]) != nil {
                                self.city.text = (placemark?.addressDictionary!["City"]) as? String
                                
                            }
                            if (placemark?.addressDictionary!["Name"]) != nil {
                                //self.campsiteAddress1.text = (placemark?.addressDictionary!["Name"]) as? String
                                
                            }
                            
                            if (placemark?.addressDictionary!["SubLocality"]) != nil {
                                //self.campsiteAddress2.text = (placemark?.addressDictionary!["SubLocality"]) as? String
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- ImagePickerFromCamera
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imgPicker.sourceType = UIImagePickerControllerSourceType.camera
            // picker.allowsEditing = true
            
            imgPicker.videoMaximumDuration = 15
            self.present(imgPicker, animated: true, completion: nil)
        }
        else{
            CommonFunctions.showAlert(self, message: noCamera, title: appName)
        }
    }
    
    //MARK: -ImgePickerFromGallery
    func openGallary(){
        imgPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imgPicker.mediaTypes = ["public.image", "public.movie"]
        //picker.allowsEditing = true
        imgPicker.videoMaximumDuration = 15
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    //MARK:- Button Action
    @IBAction func tapProfileBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.searchActive = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.searchActive = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addCampsite(_ sender: Any) {
        self.view.endEditing(true)
        self.searchActive = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func tapNotifivationBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.searchActive = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.searchActive = false
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapSwitchBtn(_ sender: UISwitch) {
        self.view.endEditing(true)
        self.locationOn()
        
    }
    
    func locationOn() {
        self.view.endEditing(true)
        self.searchActive = false
        
        self.latitude.text! = ""
        self.longitude.text! = ""
        
        self.getLocationNameAndImage()
        
    }
    
    func saveCamp() {
        if(((self.campsiteName.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.campsiteName.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: campsiteEmptyAlert, title: appName)
            
        } else {
            
            self.searchActive = false
            
            let campTypeIdsStr = self.campTypeIdsArr.componentsJoined(by: ",")
            let campAmentiesIdStr = self.campAmentiesIdArr.componentsJoined(by: ",")
            let campHokupsIdStr = self.campHokupsIdArr.componentsJoined(by: ",")
            
            var switchStatus: String = "0"
            if self.myLocationOnOffSwitch.isOn == false {
                switchStatus = "0"
                
            } else {
                switchStatus = "1"
                
            }
            
            if self.recDraftIndex != -1 {
                let tempCampDict: NSDictionary = ["userId": DataManager.userId, "campName": self.campsiteName.text!, "campType": self.campTypeLbl.text!, "campAddress1": self.campsiteAddress1.text!, "campAddress2": self.campsiteAddress2.text!, "closestTown": self.closetTown.text!, "country": self.Country.text!, "state": self.state.text!, "city": self.city.text!, "elevation": self.elevation.text!, "numberofsites": self.numberOfSites.text!, "climate": self.climate.text!, "bestMonths": self.bestMonthLbl.text!, "hookups": "antiquing"/*self.hookupLbl.text!*/, "amenities": self.amentiesLbl.text!, "price": self.price.text!, "description": self.descriptionTxtFld.text!, "webUrl": self.webSiteTxtView.text! ,"latitude": self.latitude.text!, "longitude": self.longitude.text!, "MyImgArr": self.myCampImgArr, "campTypeIdsStr": campTypeIdsStr, "campAmentiesIdStr": campAmentiesIdStr, "campHokupsIdStr": campHokupsIdStr, "locationOnOff": switchStatus, "videoIndex": self.videoImgIndex, "videoUrl": self.videoString]
                
                if (userDefault.value(forKey: myDraft)) != nil {
                    let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
                    tempArr.removeObject(at: recDraftIndex)
                    self.mySavedCampSites = tempArr
                    
                }
                
                // print(myCampImgArr)
                
                self.mySavedCampSites.add(tempCampDict)
                let tempArr: NSArray = self.mySavedCampSites.reversed() as NSArray
                self.mySavedCampSites = tempArr.mutableCopy() as! NSMutableArray
                
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: mySavedCampSites), forKey: myDraft)
                
                // print((NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray))
                
            } else {
                let tempCampDict: NSDictionary = ["userId": DataManager.userId, "campName": self.campsiteName.text!, "campType": self.campTypeLbl.text!, "campAddress1": self.campsiteAddress1.text!, "campAddress2": self.campsiteAddress2.text!, "closestTown": self.closetTown.text!, "country": self.Country.text!, "state": self.state.text!, "city": self.city.text!, "elevation": self.elevation.text!, "numberofsites": self.numberOfSites.text!, "climate": self.climate.text!, "bestMonths": self.bestMonthLbl.text!, "hookups": "antiquing"/*self.hookupLbl.text!*/, "amenities": self.amentiesLbl.text!, "price": self.price.text!, "description": self.descriptionTxtFld.text!, "webUrl": self.webSiteTxtView.text!, "latitude": self.latitude.text!, "longitude": self.longitude.text!, "MyImgArr": self.myCampImgArr, "campTypeIdsStr": campTypeIdsStr, "campAmentiesIdStr": campAmentiesIdStr, "campHokupsIdStr": campHokupsIdStr, "locationOnOff": switchStatus, "videoIndex": self.videoImgIndex, "videoUrl": self.videoString]
                
                if (userDefault.value(forKey: myDraft)) != nil {
                    let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.mySavedCampSites = tempArr
                    
                }
                
                let tempArr1: NSArray = self.mySavedCampSites.reversed() as NSArray
                self.mySavedCampSites = tempArr1.mutableCopy() as! NSMutableArray
                self.mySavedCampSites.add(tempCampDict)
                
                let tempArr: NSArray = self.mySavedCampSites.reversed() as NSArray
                
                self.mySavedCampSites = tempArr.mutableCopy() as! NSMutableArray
                
                userDefault.set(NSKeyedArchiver.archivedData(withRootObject: mySavedCampSites), forKey: myDraft)
                
                //  print((NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray))
                
            }
            
            let alert = UIAlertController(title: appName, message: campsavedasDraft, preferredStyle: .alert)
            let okBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                
                fromSaveDraft = true
                if self.recDraftIndex != -1 {
                    if let vc = self.navigationController?.viewControllers.filter({ $0 is MyCampsiteVc }).first {
                        self.navigationController?.popToViewController(vc, animated: true)
                        
                    }
                } else {
                    if self.tabBarController?.selectedIndex == 3 {
                        self.navigationController?.popViewController(animated: true)
                        
                    } else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
                        self.tabBarController?.selectedIndex = 3
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                }
            })
            
            alert.addAction(okBtn)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func tapAddAsDraftBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.videoImgIndex == -1 {
            self.saveCamp()
            
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: appName, message: videoNotSaved, preferredStyle: .alert)
                let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                    self.myCampImgArr.removeObject(at: self.videoImgIndex-1)
                    
                    self.saveCamp()
                })
                
                let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(yesBtn)
                alert.addAction(noBtn)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
       // CommonFunctions.showAlert(self, message: campsavedasDraft, title: appName)
        
    }
    
    @IBAction func tapNextBtn(_ sender: UIButton) {
        self.searchActive = false
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.addCampSiteApiHit()
                
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapVideoBtn(_ sender: Any) {
        self.view.endEditing(true)
      
        if self.myCampImgArr.count < 5 {
            //        imgPicker.sourceType = .camera
            //        imgPicker.delegate = self
            //        imgPicker.mediaTypes = ["public.movie"]
            //
            //        present(imgPicker, animated: true, completion: nil)
            
            if self.videoImgIndex == -1 {
             //   print(self.myCampImgArr)
                
                imgPicker.delegate = self
                imgPicker.mediaTypes = ["public.movie"]
                let alert = UIAlertController(title:ChooseImage, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:Camera, style: .default, handler: { _ in
                    self.openCamera()
                }))
                
                alert.addAction(UIAlertAction(title:Gallery, style: .default, handler: { _ in
                    self.openGallary()
                }))
                
                alert.addAction(UIAlertAction.init(title:cancel, style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                CommonFunctions.showAlert(self, message: oneVidOnly, title: appName)
                
            }
        } else {
            CommonFunctions.showAlert(self, message: upoadOnly5Camp, title: appName)
            
        }
    }    
    
    @IBAction func tapCameraBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        
        imgPicker.mediaTypes = ["public.image"]
        if self.myCampImgArr.count < 5 {
            self.searchActive = false
            self.myImgHeightConstant.constant = 60
            
            let alert = UIAlertController(title:ChooseImage, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:Camera, style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title:Gallery, style: .default, handler: { _ in
                //self.openGallary()
                
                let imagePicker = OpalImagePickerController()
                imagePicker.navigationBar.barTintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
                imagePicker.imagePickerDelegate = self
                
                if self.myCampImgArr.count == 0 {
                    imagePicker.maximumSelectionsAllowed = 5
                    
                } else if self.myCampImgArr.count == 1 {
                    imagePicker.maximumSelectionsAllowed = 4
                    
                } else if self.myCampImgArr.count == 2 {
                    imagePicker.maximumSelectionsAllowed = 3
                    
                } else if self.myCampImgArr.count == 3 {
                    imagePicker.maximumSelectionsAllowed = 2
                    
                } else if self.myCampImgArr.count == 4 {
                    imagePicker.maximumSelectionsAllowed = 1
                    
                } else if self.myCampImgArr.count == 5 {
                    imagePicker.maximumSelectionsAllowed = 0
                    
                }
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }))
           
           // alert.addAction(UIAlertAction.init(title:cancel, style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title:cancel, style: .cancel, handler: { _ in
                //Cancel action?
                if self.myCampImgArr.count == 0 {
                    self.myImgHeightConstant.constant = 0
                    
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            CommonFunctions.showAlert(self, message: upoadOnly5Camp, title: appName)
            
        }
    }
    
    @IBAction func tapFetchLatLongBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        
        applicationDelegate.startProgressView(view: self.view)
        
        self.getLatLong()
        
    }
    
    func saveImgDocumentDirectory(_ pic:UIImage)->String {
        let fileManager = FileManager.default
        let randNum = arc4random_uniform(100000)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ExpertImage\(randNum)")
        let imageName = "ExpertImage\(randNum)"
        let imageData = UIImageJPEGRepresentation(pic, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return imageName
    }
}

//MARK:- API
extension AddNewCampsiteVc {
    func addCampSiteApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        let campTypeIdsStr = self.campTypeIdsArr.componentsJoined(by: ",")
        let campAmentiesIdStr = self.campAmentiesIdArr.componentsJoined(by: ",")
        let campHokupsIdStr = self.campHokupsIdArr.componentsJoined(by: ",")
        
        let param: NSDictionary = ["userId": DataManager.userId, "campName": self.campsiteName.text!, "campType": campTypeIdsStr, "campAddress1": self.campsiteAddress1.text!, "campAddress2": self.campsiteAddress2.text!, "closestTown": self.closetTown.text!, "country": self.Country.text!, "state": self.state.text!, "city": self.city.text!, "elevation": self.elevation.text!, "numberofsites": self.numberOfSites.text!, "climate": self.climate.text!, "bestMonths": self.bestMonthLbl.text!, "hookups": "antiquing"/*campHokupsIdStr*/, "amenities": campAmentiesIdStr, "price": self.price.text!, "description": self.descriptionTxtFld.text!, "webUrl": self.webSiteTxtView.text!,"latitude": self.latitude.text!, "longitude": self.longitude.text!, "videoindex": self.videoImgIndex]
        
        print(param)
        
        AlamoFireWrapper.sharedInstance.getPostMultipartForUploadMultipleImages(action: "addCampsite.php", param: param as! [String : Any], ImageArr: self.myCampImgArr, videoData: self.videoData, videoIndex: self.videoImgIndex, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyCampsiteVc") as! MyCampsiteVc
                    
                    if self.recDraftIndex != -1 {
                        if (userDefault.value(forKey: myDraft)) != nil {
                            let tempArr: NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray).mutableCopy() as! NSMutableArray
                            tempArr.removeObject(at: self.recDraftIndex)
                            self.mySavedCampSites = tempArr
                            
                        }
                       
                        userDefault.set(NSKeyedArchiver.archivedData(withRootObject: self.mySavedCampSites), forKey: myDraft)
                        
                       // print((NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.value(forKey: myDraft)) as! Data) as! NSArray))
                        
                    }
                    
                    vc.comeFrom = addCampsiteComeFrom
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
    
    func addKeyBoardObservers() {
        //keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVc.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVc.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        let keyBoardHeight = keyboardSize.height
        var contentInset:UIEdgeInsets = self.scroolView.contentInset
        
        if selectedType == country || selectedType == "state" || selectedType == "city" {
            contentInset.bottom = keyBoardHeight + 150
            
        } else {
            contentInset.bottom = keyBoardHeight
            
        }
        self.scroolView.contentInset = contentInset
        
    }
    
    @objc func removeImgFromArr(sender: UIButton) {
        let alert = UIAlertController(title: appName, message: sureALert, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            self.myCampImgArr.removeObject(at: sender.tag)
            
            if sender.tag == self.videoImgIndex - 1 {
                self.videoString = ""
                self.videoImg = nil
                self.videoData = nil
                
                self.videoImgIndex = -1
            }
            
            if self.myCampImgArr.count == 0 {
                self.myImgHeightConstant.constant = 0
                
            }
            self.myCampImgCollVIew.reloadData()
            
        })
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scroolView.contentInset = contentInset
        
    }
    
    func getLongiLatti(address1: String, address2: String, address3: String, address4: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address1) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                 //   applicationDelegate.dismissProgressView(view: self.view)
                    // handle no location found
                   // CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
                   self.getLongiLatti(address2: address2, address3: address3, address4: address4)
                    return
            }
           
            applicationDelegate.dismissProgressView(view: self.view)
            self.latitude.text! = String(describing: (location.coordinate.latitude).roundToDecimal(4))
            self.longitude.text! = String(describing: (location.coordinate.longitude).roundToDecimal(4))
            
        }
    }
    
    func getLongiLatti(address2: String, address3: String, address4: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address2) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                   // applicationDelegate.dismissProgressView(view: self.view)
                    // handle no location found
                    //CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
                    self.getLongiLatti(address3: address3, address4: address4)
                    
                    return
            }
            
            applicationDelegate.dismissProgressView(view: self.view)
            self.latitude.text! = String(describing: (location.coordinate.latitude).roundToDecimal(4))
            self.longitude.text! = String(describing: (location.coordinate.longitude).roundToDecimal(4))
            
        }
    }
    
    func getLongiLatti(address3: String, address4: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address3) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    //applicationDelegate.dismissProgressView(view: self.view)
                    // handle no location found
                   // CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
                    
                    self.getLongiLatti(address4: address4)
                    
                    return
            }
            
            applicationDelegate.dismissProgressView(view: self.view)
            self.latitude.text! = String(describing: (location.coordinate.latitude).roundToDecimal(4))
            self.longitude.text! = String(describing: (location.coordinate.longitude).roundToDecimal(4))
            
        }
    }
    
    func getLongiLatti(address4: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address4) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    applicationDelegate.dismissProgressView(view: self.view)
                    // handle no location found
                    CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
                    
                    return
            }
            
            applicationDelegate.dismissProgressView(view: self.view)
            self.latitude.text! = String(describing: (location.coordinate.latitude).roundToDecimal(4))
            self.longitude.text! = String(describing: (location.coordinate.longitude).roundToDecimal(4))
            
        }
    }
    
    @objc func doneButtonTextView(_ sender: UITextView) {
        self.view.endEditing(true)
        
    }
}
extension AddNewCampsiteVc :UITextFieldDelegate, UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .darkGray
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneButtonTextView(_:)))
        doneButton.tintColor = UIColor.white
        let items:Array = [doneButton]
        toolbar.items = items
        
        textView.inputAccessoryView = toolbar
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == campsiteAddress1 || textField == campsiteAddress2 || textField == Country || textField == state || textField == city {
            self.myLocationOnOffSwitch.setOn(false, animated: true);
            
            self.latitude.text! = ""
            self.longitude.text! = ""
            
        } else if textField == descriptionTxtFld {
            let currentCharacterCount = textField.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 500
            
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .darkGray
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneButtonTextView(_:)))
        doneButton.tintColor = UIColor.white
        let items:Array = [doneButton]
        toolbar.items = items
        
        if textField == self.elevation || textField == self.numberOfSites || textField == self.price {
            textField.inputAccessoryView = toolbar
        }
        return true
    }
    
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if (textField == hookupsAvailable ) {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
//            vc.key = "Select Hookups"
//            vc.delegate = self
//            
//            vc.setCampNameIfAvailable = self.hookupLbl.text!
//            
//            self.navigationController?.pushViewController(vc, animated: true)
//            return false
//            
//        } else if (textField == amenities ) {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
//            vc.key = "Select Amenities"
//            vc.delegate = self
//            
//            vc.setCampNameIfAvailable = self.amentiesLbl.text!
//            
//            self.navigationController?.pushViewController(vc, animated: true)
//            return false
//            
//        } else if (textField == bestMonthToVisit ) {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
//            vc.key = "Select Months"
//            vc.delegate = self
//            
//            vc.setCampNameIfAvailable = self.bestMonthLbl.text!
//            
//            self.navigationController?.pushViewController(vc, animated: true)
//            return false
//            
//        }else if (textField == campType ) {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier:"SelectOptionVC") as! SelectOptionVC
//            vc.key = "Select Type"
//            vc.delegate = self
//            
//            vc.setCampNameIfAvailable = self.campTypeLbl.text!
//            
//            self.navigationController?.pushViewController(vc, animated: true)
//            return false
//            
//        }
//        return true
//    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.Country || textField == state || textField == city {
            self.searchActive = true
            if textField == Country {
                self.selectedType = country
                self.countryStateCityTop.constant = 4
                self.countryStateCityTblView.isHidden = false
                
                self.searchData = (self.countiesArr).mutableCopy() as! NSMutableArray
                self.countryStateCityTblView.reloadData()
                
            } else if textField == state {
                if countryId == "" {
                   // CommonFunctions.showAlert(self, message: countryEmptyAlertF, title: appName)
                    
                    
                    
                } else {
                    self.selectedType = "state"
                    self.countryStateCityTop.constant = 70
                    self.countryStateCityTblView.isHidden = false
                    
                    self.searchData = (self.stateArr).mutableCopy() as! NSMutableArray
                    self.countryStateCityTblView.reloadData()
                    
                }
            } else if textField == city {
                if stateId == "" {
                    //CommonFunctions.showAlert(self, message: stateEmptyAlertF, title: appName)
                    
                } else {
                    self.selectedType = "city"
                    self.countryStateCityTop.constant = 70
                    self.countryStateCityTblView.isHidden = false
                    
                    self.searchData = (self.cityArr).mutableCopy() as! NSMutableArray
                    self.countryStateCityTblView.reloadData()
                    
                }
            }
        } else {
            self.selectedType = ""
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchActive = false
        self.countryStateCityTblView.isHidden = true

    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.searchActive = false
//        self.countryStateCityTblView.isHidden = true
//
//        if textField == self.Country || textField == self.state || textField == self.city || textField == self.closetTown {
//
//            var address: String = ""
//            if self.closetTown.text! != "" {
//                address = self.closetTown.text!
//
//            } else {
//
//                if self.Country.text != "" {
//                    address.append(self.Country.text!)
//                    address.append(",")
//
//                }
//                if self.state.text != "" {
//                    address.append(self.state.text!)
//                    address.append(",")
//
//                }
//                if self.city.text != "" {
//                    address.append(self.city.text!)
//                    address.append(",")
//
//                }
//
//                address = String(address.dropLast())
//
//            }
//            let geoCoder = CLGeocoder()
//            geoCoder.geocodeAddressString(address) { (placemarks, error) in
//                guard
//                    let placemarks = placemarks,
//                    let location = placemarks.first?.location
//                    else {
//                        // handle no location found
//                        if textField == self.closetTown {
//                            CommonFunctions.showAlert(self, message: diffClosestLoc, title: appName)
//
//                        } else {
//                            self.closetTown.isUserInteractionEnabled = true
//                            CommonFunctions.showAlert(self, message: locationNotFound, title: appName)
//
//                        }
//                        return
//                }
//                self.closetTown.isUserInteractionEnabled = false
////                if self.campsiteAddress1.text! == "" {
////                    CommonFunctions.showAlert(self, message: campsiteAddr1Empty, title: appName)
////
////                } else if self.Country.text! == "" {
////                    CommonFunctions.showAlert(self, message: countryEmpty, title: appName)
////
////                } else if self.city.text! == "" {
////                    CommonFunctions.showAlert(self, message: cityEmpty, title: appName)
////
////                } else if self.state.text! == "" {
////                    CommonFunctions.showAlert(self, message: stateEmpty, title: appName)
////
////                } else {
//                    self.latitude.text! = String(describing: (location.coordinate.latitude).roundToDecimal(4))
//                    self.longitude.text! = String(describing: (location.coordinate.longitude).roundToDecimal(4))
//
//               // }
//            }
//        }
//    }
}

//image and collctionView
extension AddNewCampsiteVc:  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myCampImgArr.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.myCampImgCollVIew.dequeueReusableCell(withReuseIdentifier: "CampImagesCollectionViewCell", for: indexPath) as! CampImagesCollectionViewCell
        cell.campImgVIew.image = self.myCampImgArr.object(at: indexPath.row) as? UIImage
        
        cell.removeImgBtn.tag = indexPath.row
        cell.removeImgBtn.addTarget(self, action: #selector(self.removeImgFromArr(sender:)), for: .touchUpInside)
        
        let image = UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate)
        cell.removeImgBtn.setImage(image, for: .normal)
        cell.removeImgBtn.tintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.width))
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    //MARK:- ImagepickerDelegate
    func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            // Select the right one based on which version you are using
//            // Swift 4.2
//            let cgImage = try imageGenerator.copyCGImage(at: .zero,
//                                                         actualTime: nil)
//            // Swift 4.0
            let cgImage = try imageGenerator.copyCGImage(at: kCMTimeZero,
                                                         actualTime: nil)
            
            
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            
            return nil
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let image = pickedImage.compressTo(500)
            
            if image != nil {
                
                let fixImgUp = fixOrientation(img: pickedImage)
                imageData = UIImageJPEGRepresentation(fixImgUp, 0.5)! as NSData as Data
                
                self.myCampImgArr.add(fixImgUp)
                self.myImgHeightConstant.constant = 60
                self.myCampImgCollVIew.reloadData()
                
                if let imageData = fixImgUp.jpeg(.lowest) {
                    
                   // print(imageData.count)
                }
            }
        } else if info[UIImagePickerControllerMediaType] as! NSString == kUTTypeMovie {
            
            let ttlCount = self.myCampImgArr.count
            if ttlCount < 5 {
                
                let moviePlayer =  info[UIImagePickerControllerMediaURL] as! NSURL
                self.videoString = moviePlayer.absoluteString!
                
              //  print(self.videoString)
                
                self.videoImg = self.generateThumbnail(url: moviePlayer as URL)
                
                self.videoImgIndex = ttlCount + 1
                self.myCampImgArr.add(self.videoImg)
                self.myImgHeightConstant.constant = 60
                self.myCampImgCollVIew.reloadData()
                
                cropVideo(sourceURL1: moviePlayer, statTime: 0.0, endTime: 15.0)
//                do {
//                    self.videoData = try Data(contentsOf: moviePlayer as URL) as NSData as Data
//
//                    //cropVideo(atURL: moviePlayer as URL)
//
//                    imgPicker.allowsEditing = true
//                    imgPicker.videoMaximumDuration = 15
//                   // imgPicker.startVideoCapture()
//
//                } catch {
//                    print("Unable to load data: \(error)")
//
//                }
            } else {
                CommonFunctions.showAlert(self, message: upoadOnly5Camp, title: appName)
                
            }
        }

        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if self.myCampImgArr.count == 0 {
            self.myImgHeightConstant.constant = 0
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func cropVideo(sourceURL1: NSURL, statTime:Float, endTime:Float)
    {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard let url = sourceURL1 as? NSURL else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(url: url as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
         //   print("video length: \(length) seconds")
            
            let start = statTime
            let end = endTime
            
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                let name = "video"
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ?? 0), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ?? length), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                  //  print("exported at \(outputURL)")
                    
                    do {
                        self.videoData = try Data(contentsOf: outputURL) as NSData as Data
                        
                        
                    } catch {
                        print("Unable to load data: \(error)")
                        
                    }

                    
                 //   self.saveVideoTimeline(outputURL)
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(exportSession.error)")
                    
                default: break
                }
            }
        }
    }
    
}

extension AddNewCampsiteVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive == true {
            if self.countryStateCityTblView.isHidden == false {
                if self.searchData.count == 0 {
                    self.noDataFoundLbl.isHidden = false
                    
                } else {
                    self.noDataFoundLbl.isHidden = true
                    
                }
            } else {
                self.noDataFoundLbl.isHidden = true
                
            }
            
            return self.searchData.count
            
        } else {
            if self.selectedType == country {
                return self.countiesArr.count
                
            } else if self.selectedType == "state" {
                if self.stateArr.count <= 5 && self.stateArr.count > 2 {
                    self.countryStateCityHeight.constant = CGFloat(self.stateArr.count * 44)
                    
                } else if self.stateArr.count == 1 {
                    self.countryStateCityHeight.constant = 100
                    
                } else {
                    self.countryStateCityHeight.constant = 250
                    
                }
                return self.stateArr.count
                
            } else if self.selectedType == "city" {
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
                
            } else if self.selectedType == "state" {
                cell.countryStateCityLbl.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
            } else if self.selectedType == "city" {
                cell.countryStateCityLbl.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
            }
            
        } else {
            if self.selectedType == country {
                cell.countryStateCityLbl.text! = (self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
            } else if self.selectedType == "state" {
                cell.countryStateCityLbl.text! = (self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
            } else if self.selectedType == "city" {
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
                self.Country.text! = ""
                self.state.text! = ""
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.countryId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryId"))!)
                self.stateApiCall()
                self.Country.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
                self.getLatLong()
                
              //  self.getLongiLatti(address: self.Country.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
                
            } else if self.selectedType == "state" {
                self.view.endEditing(true)
                self.state.text! = ""
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.stateId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateId"))!)
                self.cityApiCall()
                self.state.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
                self.getLatLong()
                
               // self.getLongiLatti(address: self.Country.text! + "," + self.state.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
                
            } else if self.selectedType == "city" {
                self.view.endEditing(true)
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.cityId = String(describing: ((self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityId"))!)
                self.city.text! = (self.searchData.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
                self.getLatLong()
                
                //self.getLongiLatti(address: self.Country.text! + "," + self.state.text! + "," + self.city.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
            }
        } else {
            if self.selectedType == country {
                self.view.endEditing(true)
                self.Country.text! = ""
                self.state.text! = ""
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.countryId = String(describing: ((self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryId"))!)
                self.stateApiCall()
                self.Country.text! = (self.countiesArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "countryName") as! String
                
                self.getLatLong()
                
               // self.getLongiLatti(address: self.Country.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
                
            } else if self.selectedType == "state" {
                self.view.endEditing(true)
                self.state.text! = ""
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.stateId = String(describing: ((self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateId"))!)
                self.cityApiCall()
                self.state.text! = (self.stateArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "stateName") as! String
                
                self.getLatLong()
                
              //  self.getLongiLatti(address: self.Country.text! + "," + self.state.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
                
            } else if self.selectedType == "city" {
                self.view.endEditing(true)
                self.city.text! = ""
                
                self.countryStateCityTblView.isHidden = true
                self.cityId = String(describing: ((self.cityArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityId"))!)
                self.city.text! = (self.cityArr.object(at: indexPath.row) as! NSDictionary).value(forKey: "cityName") as! String
                
                self.getLatLong()
                
               // self.getLongiLatti(address: self.Country.text! + "," + self.state.text! + "," + self.city.text! + "," + self.campsiteAddress1.text! + "," + self.campsiteAddress2.text!)
                
            }
        }
    }
    
    func getLatLong() {
        let addr1 = self.campsiteAddress1.text! + "," + self.campsiteAddress2.text! + "," + self.Country.text! + "," + self.state.text! + "," + self.city.text!
        let addr2 = self.campsiteAddress1.text! + "," + self.Country.text! + "," + self.state.text! + "," + self.city.text!
        let addr3 = self.campsiteAddress2.text! + "," + self.Country.text! + "," + self.state.text! + "," + self.city.text!
        let addr4 = self.Country.text! + "," + self.state.text! + "," + self.city.text!
        
        self.getLongiLatti(address1: addr1, address2: addr2, address3: addr3, address4: addr4)
        
    }
}

extension AddNewCampsiteVc: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        self.closetTown.text = place.name
        
        self.getClosestPlace(userloc: CLLocation(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude)))
        self.myLocationOnOffSwitch.setOn(false, animated: true);
        
        self.latitude.text! = String(describing: (place.coordinate.latitude))
        self.longitude.text! = String(describing: (place.coordinate.longitude))
        
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        
        dismiss(animated: true, completion: nil)
        
    }
}

extension AddNewCampsiteVc: OpalImagePickerControllerDelegate {
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        //Cancel action?
        if self.myCampImgArr.count == 0 {
            self.myImgHeightConstant.constant = 0
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        //Save Images, update UI
     //   print("images ",images)
        var chosenImage = UIImage()
        
        for i in 0..<images.count {
            chosenImage = images[i]
            
            let fixImgUp = fixOrientation(img: chosenImage)
            imageData = UIImageJPEGRepresentation(fixImgUp, 0.5)! as NSData as Data
            //            let ImageString = saveImgDocumentDirectory(fixImgUp)
            //            ImageUrl = ImageString
            //            print("ImageUrl ",ImageUrl)
            
            self.myCampImgArr.add(fixImgUp)
            self.myImgHeightConstant.constant = 60
            self.myCampImgCollVIew.reloadData()
            
            if let imageData = fixImgUp.jpeg(.lowest) {
                
              //  print(imageData.count)
            }
            
           // tableData.objects.insert(ImageUrl, at: 0)
        }
        //firstTable.reloadData()
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerNumberOfExternalItems(_ picker: OpalImagePickerController) -> Int {
        return 1
    }
    
    func imagePickerTitleForExternalItems(_ picker: OpalImagePickerController) -> String {
        
        return NSLocalizedString("External", comment: "External (title for UISegmentedControl)")
    }
    
    func imagePicker(_ picker: OpalImagePickerController, imageURLforExternalItemAtIndex index: Int) -> URL? {
        return URL(string: "https://placeimg.com/500/500/nature")
    }
    
}

extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInKb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInKb * 1024 //* 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = UIImageJPEGRepresentation(self, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
     //   print(sizeInBytes)
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}
