//
//  RegisterVc.swift
//  XploreProject
//
//  Created by shikha kochar on 22/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class RegisterVc: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate {
    
    //MARK:- IbOutlets
    @IBOutlet weak var ScroolView: UIScrollView!
    @IBOutlet weak var nameTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var emailTextFeild: UITextFieldCustomClass!
    @IBOutlet weak var passwordTextfeild: UITextFieldCustomClass!
    @IBOutlet weak var confirmPassowrd: UITextFieldCustomClass!
    
    //MARK:- Variable Declarations
    var fbbDataDict: NSDictionary = [:]
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call googleSignIn delegate
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    
        /////
        self.addKeyBoardObservers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    //MARK:- google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            
        } else {
            // Perform any operations on signed in user here.
            //            let userId = user.userID                  // For client-side use only!
            //            let idToken = user.authentication.idToken // Safe to send to the server
            //            let fullName = user.profile.name
            //            let givenName = user.profile.givenName
            //            let familyName = user.profile.familyName
            //            let email = user.profile.email
            // ...
            
//            print(user.profile.email!)
//            print(user.userID!)
//            print(user.authentication.idToken!)
//            print(user.profile.name!)
            
//            user.profile.familyName
//            user.profile.givenName
//            user.profile.imageURL(withDimension: 200*400)
            
            self.googleLoginApiHit(email: user.profile.email!, userId: user.userID!, tokenId: user.authentication.idToken!, userFirstName: user.profile.givenName, userLastName: user.profile.familyName, userFullName: user.profile.name)
            
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    //MARK:- button Action
    @IBAction func signUPAction(_ sender: Any){
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.hitRegisterApi()
                
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func signInAction(_ sender: Any){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        self.view.endEditing(true)
        
        UserDefaults.standard.set(facbookLogin, forKey: XPLoginStatus)
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                
                                if (error == nil){
                                    self.fbbDataDict = (result as! [String : AnyObject] as NSDictionary)
                                   
                                    //print(self.fbbDataDict)
                                    
                                    self.FbLoginApiHit()
                                }
                            })
                        }
                    }
                }
                fbLoginManager.logOut()
                
            }else {
                print("error")
                
            }
        }
    }
    
    @IBAction func gmailAction(_ sender: Any) {
        self.view.endEditing(true)
        
        UserDefaults.standard.set(gmailLogin, forKey: XPLoginStatus)
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapShowHidePassBtn(_ sender: UIButton) {
        if self.confirmPassowrd.isSecureTextEntry == true {
            self.confirmPassowrd.isSecureTextEntry = false
            
        } else {
            self.confirmPassowrd.isSecureTextEntry = true
            
        }
    }
}

extension RegisterVc {
    //MARK: validations on textField
    func validateEmail(_ enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func checkValidations() ->Bool {
        if(((nameTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.nameTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: nameFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if(((emailTextFeild.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.emailTextFeild.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: emailFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if !((emailTextFeild.text!).isValidEmail()) {
            CommonFunctions.showAlert(self, message: invalidEmailAlertMessage, title: appName)
            self.emailTextFeild.becomeFirstResponder()
            
            return true
        } else if(((passwordTextfeild.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.passwordTextfeild.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: passwordFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if(((confirmPassowrd.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.confirmPassowrd.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: confirmPasswordEmptyAlert, title: appName)
            
            return true
        } else if(((confirmPassowrd.text!.trimmingCharacters(in: .whitespaces)))) != (((passwordTextfeild.text!.trimmingCharacters(in: .whitespaces)))) {
            self.confirmPassowrd.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: mismatchPass, title: appName)
            
            return true
        }
        return false
    }
        
    //MARK:- API
    func hitRegisterApi () {
        self.view.endEditing(true)
        applicationDelegate.startProgressView(view: self.view)
        
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set("", forKey: "DeviceToken")
            
        }
        
        let param: [String:Any] = ["name": self.nameTxtFld.text!.trimmingCharacters(in: .whitespaces), "email": self.emailTextFeild.text!.trimmingCharacters(in: .whitespaces),"password": self.passwordTextfeild.text!.trimmingCharacters(in: .whitespaces), "cpwd": self.confirmPassowrd.text!.trimmingCharacters(in: .whitespaces), "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": "", "googleToken": "", "longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
     //   print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                
            //    print(dict)
                
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    
                 //   print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                   // objUser.parseUserData(recUserDict: retValues)
                    DataManager.isUserLoggedIn = true
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
        
        //userDefault.set(true,forKey: login.USER_DEFAULT_LOGIN_CHECK_Key)
//        let Obj = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
//        self.navigationController?.pushViewController(Obj, animated: true)
    }
    
    func FbLoginApiHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set(0, forKey: "DeviceToken")
            
        }
        let param: [String:Any] = ["name": String(describing: (fbbDataDict["name"]!)), "email": String(describing: (fbbDataDict["email"]!)),"password": "", "cpwd": "", "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": String(describing: (fbbDataDict["id"]!)), "googleToken": "", "longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
      //  print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    
                //    print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                    //objUser.parseUserData(recUserDict: retValues)
                    DataManager.isUserLoggedIn = true
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
    
    func googleLoginApiHit(email: String, userId: String, tokenId: String, userFirstName: String, userLastName: String, userFullName: String){
        applicationDelegate.startProgressView(view: self.view)
        
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set(0, forKey: "DeviceToken")
            
        }
        
        let param: [String:Any] = ["name": userFullName, "email": email,"password": "", "cpwd": "", "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": "", "googleToken": userId, "longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
       // print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    
               //     print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                    //objUser.parseUserData(recUserDict: retValues)
                    DataManager.isUserLoggedIn = true
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
        var contentInset:UIEdgeInsets = self.ScroolView.contentInset
        contentInset.bottom = keyBoardHeight
        self.ScroolView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.ScroolView.contentInset = contentInset
    }
}
extension RegisterVc :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.passwordTextfeild || textField == self.confirmPassowrd {
            let maxLength = 8
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        return true
    }
}
