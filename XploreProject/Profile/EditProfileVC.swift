//
//  EditProfileVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 26/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CoreLocation

//MARK: step 1 Add Protocol here.
protocol updateProfileDelegate: class {
    func updateProfile(dict: NSDictionary)
    
}

class EditProfileVC: UIViewController {

    //MARK:- IbOutlets
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var editProfileScrollView: UIScrollView!
    @IBOutlet weak var userProfileImgView: UIImageViewCustomClass!
    @IBOutlet weak var nameTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var emailTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var contactNumTxtFld: UITextFieldCustomClass!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var countryCode: SkyFloatingDiffFont!
    @IBOutlet weak var countryCodeLbl: UILabel!
    
    //MARK:- Variable Declaration
    //image picker
    let imgPicker = UIImagePickerController()
    var imageData: Data?
    var myProfileInfoDict: NSDictionary = [:]
    
    //MARK: step 2 Create a delegate property here.
    var delegate: updateProfileDelegate?
    var userProfileImg: UIImage?
    
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUserInfo()
        self.addKeyBoardObservers()        
        self.imgPicker.delegate = self
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
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
    
    //MARK:- Function Definition
    func setUserInfo() {
        self.nameTxtFld.text! = myProfileInfoDict.value(forKey: "name") as! String
        self.emailTxtFld.text! = myProfileInfoDict.value(forKey: "email") as! String
        
        let currentLocale = NSLocale.current.regionCode
        let countryCode = currentLocale//get the set country name, code of your iphone
        self.countryCodeLbl.text! = "+\(getCountryCallingCode(countryRegionCode: countryCode!)) "
        
        print(self.countryCode.text!)
        
        self.contactNumTxtFld.text! = myProfileInfoDict.value(forKey: "phoneNumber") as! String
        
        if let profileImg = (myProfileInfoDict.value(forKey: "profileImage") as? String) {
            
            self.userProfileImgView.sd_setShowActivityIndicatorView(true)
            self.userProfileImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            self.userProfileImgView.loadImageFromUrl(urlString: profileImg, placeHolderImg: "", contenMode: .scaleAspectFit)
            
           // self.userProfileImgView.sd_setImage(with: URL(string: profileImg), placeholderImage: UIImage(named: ""))
            
        }        
    }
    
    func getLocationNameAndImage() {
        if userLocation != nil {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation!) { (placemarksArray, error) in
                if placemarksArray != nil {
                    if (placemarksArray?.count)! > 0 {
                        let placemark = placemarksArray?.first
                        
                            if placemark?.addressDictionary != nil {
                                
                                if (placemark?.addressDictionary!["Country"]) != nil {
                                    
                                    let country = (placemark?.addressDictionary!["Country"]) as? String
                                    
                                }
                        }
                    }
                }
            }
        }
    }
    
    func getCountryCallingCode(countryRegionCode:String)->String{
        
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryRegionCode]
        return countryDialingCode!
        
    }
    
    @objc func doneButtonTextView(_ sender: UITextView) {
        self.view.endEditing(true)
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.editProfileScrollView.contentInset = contentInset
        
    }
    
    //MARK:- ImagePickerFromCamera
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imgPicker.sourceType = UIImagePickerControllerSourceType.camera
            // picker.allowsEditing = true
            self.present(imgPicker, animated: true, completion: nil)
        }
        else{
            CommonFunctions.showAlert(self, message: noCamera, title: appName)
        }
    }
    
    //MARK: -ImgePickerFromGallery
    func openGallary(){
        imgPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //picker.allowsEditing = true
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
        var contentInset:UIEdgeInsets = self.editProfileScrollView.contentInset
        contentInset.bottom = keyBoardHeight
        self.editProfileScrollView.contentInset = contentInset
        
    }
    
    func checkValidations() ->Bool {
        if(((self.nameTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.nameTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: nameFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if(((self.contactNumTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.contactNumTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: mobileAlert, title: appName)
            
            return true
        }
        return false
    }
    
    func updateProfileApiCall() {
        self.view.endEditing(true)
        applicationDelegate.startProgressView(view: self.view)
        
        let param: [String:Any] = ["userId": DataManager.userId, "name": self.nameTxtFld.text!.trimmingCharacters(in: .whitespaces),"email": self.emailTxtFld.text!.trimmingCharacters(in: .whitespaces), "phoneNumber": self.contactNumTxtFld.text!.trimmingCharacters(in: .whitespaces)]
        
        //print(param)
        
        AlamoFireWrapper.sharedInstance.getPostMultipart(action: "UpdateProfile.php", param: param , imageData: imageData, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                  //  print(dict)
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: appName, message: ProfileUpdateAlert, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
                            
                            let dict: NSDictionary = ["name": self.nameTxtFld.text!, "profileImage": self.userProfileImgView.image]
                            
                            //MARK: step 3 Add the delegate method call here.
                            self.delegate?.updateProfile(dict: dict)
                            self.navigationController?.popViewController(animated: true)
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                } else {
                    CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
               // CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func tapUpdateProfileBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.updateProfileApiCall()
                
            }
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
          //  CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapCameraBtn(_ sender: UIButton) {
        let alert = UIAlertController(title:ChooseImage, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:Camera, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title:Gallery, style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title:cancel, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
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
}

//image and collctionView
extension EditProfileVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    //MARK:- ImagepickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let chosenImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)  else { return }
        
        
        let fixImgUp = fixOrientation(img: chosenImage)
        imageData = UIImageJPEGRepresentation(fixImgUp, 0.5)! as NSData as Data
        
      //  self.userProfileImgView.image = fixImgUp
        self.userProfileImg = fixImgUp
        if let imageData = fixImgUp.jpeg(.lowest) {
            
            
        }
       // picker.dismiss(animated: true,completion: nil)
        
       // dismiss(animated: true, completion: nil)
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: fixImgUp)
        cropController.delegate = self
        
        cropController.modalPresentationStyle = .fullScreen
        // Uncomment this if you wish to provide extra instructions via a title label
        //cropController.title = "Crop Image"
        
        // -- Uncomment these if you want to test out restoring to a previous crop setting --
        //cropController.angle = 90 // The initial angle in which the image will be rotated
        //cropController.imageCropFrame = CGRect(x: 0, y: 0, width: 2848, height: 4288) //The initial frame that the crop controller will have visible.
        
        // -- Uncomment the following lines of code to test out the aspect ratio features --
        //cropController.aspectRatioPreset = .presetSquare; //Set the initial aspect ratio as a square
        //cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
        //cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default
        //cropController.aspectRatioPickerButtonHidden = true
        
        // -- Uncomment this line of code to place the toolbar at the top of the view controller --
        //cropController.toolbarPosition = .top
        
        //cropController.rotateButtonsHidden = true
        //cropController.rotateClockwiseButtonHidden = true
        
        //cropController.doneButtonTitle = "Title"
        //cropController.cancelButtonTitle = "Title"
        
        self.image = fixImgUp
        
        //If profile picture, push onto the same navigation stack
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        self.userProfileImgView.image = image
      //  layoutImageView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if cropViewController.croppingStyle != .circular {
           // imageView.isHidden = true
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: self.userProfileImgView,
                                                   toFrame: CGRect.zero,
                                                   setup: { //self.layoutImageView()
                                                    
            },
                                                   completion: { //self.imageView.isHidden = false
                                                    
            })
        }
        else {
           // self.imageView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditProfileVC: UITextFieldDelegate {
    //MARK:- UItextView DElegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        
        if textField == self.contactNumTxtFld {
            textField.inputAccessoryView = toolbar
        }
        return true
    }
}
