//
//  EditProfileVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 26/09/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

//MARK: step 1 Add Protocol here.
protocol updateProfileDelegate: class {
    func updateProfile(dict: NSDictionary)
    
}

class EditProfileVC: UIViewController {

    //MARK:- IbOutlets
    @IBOutlet weak var editProfileScrollView: UIScrollView!
    @IBOutlet weak var userProfileImgView: UIImageViewCustomClass!
    @IBOutlet weak var nameTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var emailTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var contactNumTxtFld: UITextFieldCustomClass!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
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
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
        self.setUserInfo()
        self.addKeyBoardObservers()        
        self.imgPicker.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    //MARK:- Function Definition
    func setUserInfo() {
        self.nameTxtFld.text! = myProfileInfoDict.value(forKey: "name") as! String
        self.emailTxtFld.text! = myProfileInfoDict.value(forKey: "email") as! String
        self.contactNumTxtFld.text! = myProfileInfoDict.value(forKey: "phoneNumber") as! String
        
        if let profileImg = (myProfileInfoDict.value(forKey: "profileImage") as? String) {
            
            self.userProfileImgView.sd_setShowActivityIndicatorView(true)
            self.userProfileImgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            self.userProfileImgView.sd_setImage(with: URL(string: profileImg), placeholderImage: UIImage(named: ""))
            
        }        
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
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
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
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
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
