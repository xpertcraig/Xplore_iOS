//
//  addReviewVc.swift
//  XploreProject
//
//  Created by shikha kochar on 24/03/18.
//  Copyright © 2018 Apple. All rights reserved.

import UIKit
import Cosmos

import OpalImagePicker
import Photos

class addReviewVc: UIViewController, UIGestureRecognizerDelegate{
    
    //MARK:- iboutlets
    @IBOutlet weak var scroolview: UIScrollView!
    @IBOutlet weak var reviewCollection: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var dateOfStayView: UIView!
    @IBOutlet weak var dateOfStayTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var lengthOfDaysLbl: UITextFieldCustomClass!
    @IBOutlet weak var scenicBeautiStarView: CosmosView!
    @IBOutlet weak var locationStarView: CosmosView!
    @IBOutlet weak var familyFriendStarView: CosmosView!
    @IBOutlet weak var privacyStarView: CosmosView!
    @IBOutlet weak var cleaninessStarView: CosmosView!
    @IBOutlet weak var bugFactoeStarView: CosmosView!
    
  //  @IBOutlet weak var addATipTxtView: UITextFieldCustomClass!
    
    @IBOutlet weak var addATipTxtView: UITextView!
    
    @IBOutlet weak var pickDatePicker: UIDatePicker!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- variable declarations
    var portfolioList = NSMutableArray ()
    var imageArray = NSMutableArray ()
    var selecteditem = NSMutableArray ()
    var isLongPressed = Bool()
    var addPhotosArr: NSMutableArray = []
    //image picker
    let imgPicker = UIImagePickerController()
    var imageData: Data?
    var campId: String = ""
    
    /////multiple images
    var ImageUrlPath:[String] = [String()]
    var ImageUrl = String()
    
    
    var datePicker : UIDatePicker = UIDatePicker()
    var datePickerContainer = UIView()
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        self.startFunction()
        
        //
        self.delegateMethods()
        self.pickDatePicker.isHidden = true
        //
        self.addKeyBoardObservers()
        self.imgPicker.delegate = self
        
        self.dateOfStayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapdaysOfStayView)))
        
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if notificationCount > 9 {
            self.notificationCountLbl.text! = "\(9)+"
        } else {
            self.notificationCountLbl.text! = "\(notificationCount)"
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
    
    //MARK:- Function definitions
    @objc func tapdaysOfStayView() {

        //Create the view
        
        self.view.endEditing(true)
        datePickerContainer.frame = CGRect(x: 0.0, y: self.view.frame.height/2, width: self.view.frame.width
            , height: 280)
        datePickerContainer.backgroundColor = UIColor.white
        
        var pickerSize : CGSize = datePicker.sizeThatFits(CGSize.zero)
        datePicker.frame = CGRect(x: 0.0, y: 20.0, width: pickerSize.width, height: 300)
        //datePicker.setDate(NSDate() as Date, animated: true)
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
        datePickerContainer.addSubview(datePicker)
        
   //     datePicker.minimumDate = Date()
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        doneButton.backgroundColor = UIColor.lightGray
        doneButton.addTarget(self, action: #selector(doneButton(sender:)), for: UIControlEvents.touchUpInside)
        doneButton.frame = CGRect(x: self.view.frame.width/2, y: 10.0, width: self.view.frame.width/2, height: 37.0)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        cancelButton.backgroundColor = UIColor.lightGray
        cancelButton.addTarget(self, action: #selector(doneButton(sender:)), for: UIControlEvents.touchUpInside)
        cancelButton.frame = CGRect(x: 0, y: 10.0, width: self.view.frame.width/2, height: 37.0)
        
        datePickerContainer.addSubview(doneButton)
        datePickerContainer.addSubview(cancelButton)
        
        self.view.addSubview(datePickerContainer)
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        self.view.endEditing(true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.dateOfStayTxtFld.text = dateFormatter.string(from: sender.date)
        
    }
    
    @objc func doneButton(sender: UIButton) {
        
        datePickerContainer.removeFromSuperview()
        
//        self.pickDatePicker.resignFirstResponder() // To resign the inputView on clicking done.
//        self.pickDatePicker.isHidden = true
    }
    
    func checkValidations() ->Bool {
        if(((self.dateOfStayTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))){            
            CommonFunctions.showAlert(self, message: dateOfStayAlert, title: appName)
            
            return true
        } else if(((self.lengthOfDaysLbl.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.lengthOfDaysLbl.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: lenghtOfStay, title: appName)
            
            return true
        } else if self.scenicBeautiStarView.rating == 0.0 {
            CommonFunctions.showAlert(self, message: scenicAlert, title: appName)

            return true
        } else if self.locationStarView.rating == 0.0{
            CommonFunctions.showAlert(self, message: locationAlert1, title: appName)

            return true
        } else if self.familyFriendStarView.rating == 0.0{
            CommonFunctions.showAlert(self, message: familyFriendAlert, title: appName)

            return true
        } else if self.privacyStarView.rating == 0.0 {
            CommonFunctions.showAlert(self, message: privacyAlert, title: appName)

            return true
        } else if self.cleaninessStarView.rating == 0.0{
            CommonFunctions.showAlert(self, message: cleanlinessAlert, title: appName)

            return true
        } else if self.bugFactoeStarView.rating == 0.0{
            CommonFunctions.showAlert(self, message: bugFactorAlert, title: appName)
            
            return true
        } else if (((self.descriptionTextView.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            CommonFunctions.showAlert(self, message: descriptionAlert1, title: appName)
            
            return true
        } else if (((self.addATipTxtView.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            CommonFunctions.showAlert(self, message: addtipAlert, title: appName)
            
            return true
        }
        return false
    }
    
    //MARK:- Api Call
    func addReviewApiCall() {
        self.view.endEditing(true)
        applicationDelegate.startProgressView(view: self.view)
        
        let param: [String:Any] = ["campId": self.campId, "userId": DataManager.userId,"dateofStay": self.dateOfStayTxtFld.text!.trimmingCharacters(in: .whitespaces), "lengthofStay": self.lengthOfDaysLbl.text!.trimmingCharacters(in: .whitespaces), "scienicBeauty": self.scenicBeautiStarView.rating, "location": self.locationStarView.rating, "familyFriendly": self.familyFriendStarView.rating, "privacy": self.privacyStarView.rating, "cleanliness": self.cleaninessStarView.rating, "bugFactor": self.bugFactoeStarView.rating, "description": self.descriptionTextView.text!, "tip": self.addATipTxtView.text!]
        
      //  print(param)
        
        AlamoFireWrapper.sharedInstance.getPostMultipartForUploadMultipleImages(action: "addReview.php", param: param , ImageArr: self.addPhotosArr, videoData: nil, videoIndex: -1, onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: appName, message: reviewAdded, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
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
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func profileAction(_ sender: Any) {
        let Obj = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(Obj, animated: true)
        
    }
    
    @IBAction func tapNearByUserBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NearByUsersVC") as! NearByUsersVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func addCampAction(_ sender: Any) {
        let Obj = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCampsiteVc") as! AddNewCampsiteVc
        self.navigationController?.pushViewController(Obj, animated: true)
        
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let Obj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        self.navigationController?.pushViewController(Obj, animated: true)
        
    }
    
    @IBAction func tapNextBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.addReviewApiCall()
                
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }

    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    //MARK:- supporting Function
    func changebutton() {

    }
    
    func startFunction() {
        self.addPhotosArr.add("")
        self.reviewCollection.reloadData()
    }
    
    func delegateMethods() {
        self.descriptionTextView.text = "Description"
        self.descriptionTextView.delegate = self
        self.descriptionTextView.textColor = UIColor.lightGray
        
        self.addATipTxtView.text = "Add a Tip"
        self.addATipTxtView.delegate = self
        self.addATipTxtView.textColor = UIColor.lightGray
        
    }
    
    func getImages () {
        let picker = UIImagePickerController()
        let alert:UIAlertController=UIAlertController(title: chooseImage, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: Camera, style: UIAlertActionStyle.default) {
            UIAlertAction in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self .present(picker, animated: true, completion: nil)
                
            }else {
                picker.allowsEditing = false
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
        }
        let gallaryAction = UIAlertAction(title: Gallery, style: UIAlertActionStyle.default) {
            UIAlertAction in
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Cancel, style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        // Add the actions
        picker.delegate = self as UIImagePickerControllerDelegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func doneButtonTextView(_ sender: UITextView) {
        self.view.endEditing(true)
        
    }
}


extension addReviewVc {
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
        var contentInset:UIEdgeInsets = self.scroolview.contentInset
        contentInset.bottom = keyBoardHeight
        self.scroolview.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scroolview.contentInset = contentInset
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
    
    @objc func removeImgFromArr(sender: UIButton) {
        let alert = UIAlertController(title: appName, message: sureALert, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            self.addPhotosArr.removeObject(at: sender.tag)
            self.reviewCollection.reloadData()
            
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
}
extension addReviewVc :UITextFieldDelegate ,UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- ImagepickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        
        let fixImgUp = fixOrientation(img: chosenImage)
        imageData = UIImageJPEGRepresentation(fixImgUp, 0.5)! as NSData as Data
        
        self.addPhotosArr.add(fixImgUp)
        
      //  print(self.addPhotosArr.count)
        
        self.reviewCollection.reloadData()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    //uitextfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.datePickerContainer.removeFromSuperview()
        
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
        
        if textField == self.lengthOfDaysLbl {
            textField.inputAccessoryView = toolbar
        }
        return true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        
    }
    
    //uitextview delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.pickDatePicker.isHidden = true
        
        if (textView == self.descriptionTextView) {
            if textView.text == "Description" {
                textView.text = ""
                textView.textColor = UIColor.darkGray
            }
        } else if (textView == self.addATipTxtView) {
            if textView.text == "Add a Tip" {
                textView.text = ""
                textView.textColor = UIColor.darkGray
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.pickDatePicker.isHidden = true
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .darkGray
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(doneButtonTextView(_:)))
        doneButton.tintColor = UIColor.white
        let items:Array = [doneButton]
        toolbar.items = items
        
        if textView == self.descriptionTextView {
            if self.descriptionTextView.text == "Description" {
                self.descriptionTextView.text = ""
                self.descriptionTextView.textColor = UIColor.darkGray
            }
            textView.inputAccessoryView = toolbar
        } else if textView == self.addATipTxtView {
            if self.descriptionTextView.text == "Add a Tip" {
                self.descriptionTextView.text = ""
                self.descriptionTextView.textColor = UIColor.darkGray
            }
            textView.inputAccessoryView = toolbar
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if self.descriptionTextView.text == "" {
            self.descriptionTextView.text = "Description"
            
        } else if self.descriptionTextView.text == "" {
            self.descriptionTextView.text = "Add a Tip"
            
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == addATipTxtView {
            let currentCharacterCount = textField.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 400
            
        }
        return true
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        //500 chars restriction
       // print(textView.text.count)
        return textView.text.count + (text.count - range.length) <= 500
        
    }
}

//MARK:- Collection Delegate DataSource Extension
extension addReviewVc: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.addPhotosArr.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.reviewCollection.dequeueReusableCell(withReuseIdentifier: "addPhotosCollectionViewCell", for: indexPath) as! addPhotosCollectionViewCell
        
        if indexPath.row == 0 {
            cell.selectedIMgView.isHidden = true
            cell.removeImageBtn.isHidden = true
            cell.addCameraBtn.isHidden = false
            
        } else {
            cell.selectedIMgView.image = self.addPhotosArr.object(at: indexPath.row) as? UIImage
            
            //add target
            cell.removeImageBtn.tag = indexPath.row
            cell.removeImageBtn.addTarget(self, action: #selector(self.removeImgFromArr(sender:)), for: .touchUpInside)
            
            cell.addCameraBtn.isHidden = true
            cell.selectedIMgView.isHidden = false
            cell.removeImageBtn.isHidden = false
            
        }
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 67, height: 55)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        self.pickDatePicker.isHidden = true
        
        if indexPath.row == 0 {
            if self.addPhotosArr.count < 6 {
                let alert = UIAlertController(title:ChooseImage, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:Camera, style: .default, handler: { _ in
                    self.openCamera()
                }))
                
                alert.addAction(UIAlertAction(title:Gallery, style: .default, handler: { _ in
                    //self.openGallary()
                    
                    let imagePicker = OpalImagePickerController()
                    imagePicker.navigationBar.barTintColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
                    imagePicker.imagePickerDelegate = self
                    
                    if self.addPhotosArr.count == 1 {
                        imagePicker.maximumSelectionsAllowed = 5
                        
                    } else if self.addPhotosArr.count == 2 {
                        imagePicker.maximumSelectionsAllowed = 4
                        
                    } else if self.addPhotosArr.count == 3 {
                        imagePicker.maximumSelectionsAllowed = 3
                        
                    } else if self.addPhotosArr.count == 4 {
                        imagePicker.maximumSelectionsAllowed = 2
                        
                    } else if self.addPhotosArr.count == 5 {
                        imagePicker.maximumSelectionsAllowed = 1
                        
                    } else if self.addPhotosArr.count == 6 {
                        imagePicker.maximumSelectionsAllowed = 0
                        
                    }
                    self.present(imagePicker, animated: true, completion: nil)
                    
                }))
                
                alert.addAction(UIAlertAction.init(title:cancel, style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                CommonFunctions.showAlert(self, message: upoadOnly5, title: appName)
                
            }
        }
    }
}

extension UIDatePicker {
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    }
}

extension addReviewVc: OpalImagePickerControllerDelegate {
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        //Cancel action?
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        //Save Images, update UI
    //    print("images ",images)
        var chosenImage = UIImage()
        
        for i in 0..<images.count {
            chosenImage = images[i]
            
            let fixImgUp = fixOrientation(img: chosenImage)
            imageData = UIImageJPEGRepresentation(fixImgUp, 0.5)! as NSData as Data
            //            let ImageString = saveImgDocumentDirectory(fixImgUp)
            //            ImageUrl = ImageString
            //            print("ImageUrl ",ImageUrl)
            
            self.addPhotosArr.add(fixImgUp)
            self.reviewCollection.reloadData()
            
            if let imageData = fixImgUp.jpeg(.lowest) {
               // print(imageData.count)
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

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
