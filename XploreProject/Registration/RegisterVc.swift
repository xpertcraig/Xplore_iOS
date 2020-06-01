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
import AuthenticationServices
import SwiftKeychainWrapper

class RegisterVc: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate {
    
    //MARK:- IbOutlets
    @IBOutlet weak var ScroolView: UIScrollView!
    @IBOutlet weak var nameTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var emailTextFeild: UITextFieldCustomClass!
    @IBOutlet weak var passwordTextfeild: UITextFieldCustomClass!
    @IBOutlet weak var confirmPassowrd: UITextFieldCustomClass!
    @IBOutlet weak var applePayBtn: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    
    //MARK:- Variable Declarations
    var fbbDataDict: NSDictionary = [:]
    private let commonViewModel = CommonUseViewModel()
    
    //Pappal Config Object
    var payPalConfig = PayPalConfiguration() // default
    //PayPal Environment Closure
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
            
        }
    }
    
    //MARK:- Inbuild Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.setUpSignInAppleButton()
        } else {
            self.applePayBtn.isHidden = true
            // Fallback on earlier versions
        }
        self.overlayView.isHidden = true
        //call googleSignIn delegate
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    
        /////
        self.addKeyBoardObservers()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setUpPaypal()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
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
    
    @IBAction func tapPayNowBtn(_ sender: UIButton) {
        self.payPalButtonPressed()
        
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
        
        let param: [String:Any] = ["name": self.nameTxtFld.text!.trimmingCharacters(in: .whitespaces), "email": self.emailTextFeild.text!.trimmingCharacters(in: .whitespaces),"password": self.passwordTextfeild.text!.trimmingCharacters(in: .whitespaces), "cpwd": self.confirmPassowrd.text!.trimmingCharacters(in: .whitespaces), "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": "", "googleToken": "", "appleToken" : "" , "longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
       // print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                
            //    print(dict)
                
                if (String(describing: (dict["success"])!)) == "1" {
                   // let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    self.verifyEmailAndLogin()
                    
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
    
    func verifyEmailAndLogin() {
        //   print(retValues)
           let alert = UIAlertController(title: appName, message: verifyEmail, preferredStyle: .alert)
           let yesBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
               alert.dismiss(animated: true, completion: nil)
               self.navigationController?.popViewController(animated: true)
           })
           alert.addAction(yesBtn)
           self.present(alert, animated: true, completion: nil)
        
    }
    
    func FbLoginApiHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set(0, forKey: "DeviceToken")
            
        }
        let param: [String:Any] = ["name": String(describing: (fbbDataDict["name"]!)), "email": String(describing: (fbbDataDict["email"]!)),"password": "", "cpwd": "", "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": String(describing: (fbbDataDict["id"]!)), "googleToken": "", "appleToken" : "" ,"longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
      //  print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as! String
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    self.checkSubscription(recValue: retValues)
                    self.commonViewModel.updateFirebaseProfile()
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
        
        let param: [String:Any] = ["name": userFullName, "email": email,"password": "", "cpwd": "", "deviceToken": userDefault.value(forKey: "DeviceToken")!, "deviceType": deviceType, "deviceId": UIDevice.current.identifierForVendor!.uuidString, "facebookToken": "", "googleToken": userId, "appleToken" : "" ,"longitude": myCurrentLongitude, "latitude": myCurrentLatitude]
        
       // print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as! String
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    self.checkSubscription(recValue: retValues)
                    self.commonViewModel.updateFirebaseProfile()
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

@available(iOS 13.0, *)
extension RegisterVc: ASAuthorizationControllerDelegate {
    func setUpSignInAppleButton() {
        UserDefaults.standard.set(appleLogin, forKey: XPLoginStatus)
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .whiteOutline)
        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        
        authorizationButton.frame = CGRect(x: 0, y: 0, width: 140, height: 42)
        authorizationButton.cornerRadius = 21
        
          //Add button on some view or stack
        self.applePayBtn.addSubview(authorizationButton)
    }

    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider().createRequest()
    //    let passwordProvider = ASAuthorizationPasswordProvider().createRequest()
        let request = appleIDProvider
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            if email != "" && email != nil {
                var dict: [String: String] = [:]
                dict["id"] = userIdentifier
                dict["fullName"] = "\(fullName!.givenName!) \(fullName!.familyName!)"
                dict["email"] = email
                self.commonViewModel.saveToKeychaine(dict: dict)
            } else if let name = fullName?.givenName {
                if name == "" && email! == "" {
                    CommonFunctions.showAlert(self, message: NoEmailinAppleId, title: appName)
                }
            }
            
            print("User id is \(userIdentifier) Full Name is \(fullName) Email id is \(email)")
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
                 switch credentialState {
                    case .authorized:
                        // The Apple ID credential is valid.
                        DispatchQueue.main.async {
                            applicationDelegate.startProgressView(view: self.view)
                        }
                        self.commonViewModel.appleLoginApiHit { (message, retValues) in
                            DispatchQueue.main.async {
                                applicationDelegate.dismissProgressView(view: self.view)
                            }
                            if message == success {
                                applicationDelegate.notificationCountApi()
                                self.commonViewModel.updateFirebaseProfile()
                                self.checkSubscription(recValue: retValues)
                            } else {
                                CommonFunctions.showAlert(self, message: message, title: appName)
                            }
                        }
                        
                        print("authorization")
                        break
                    case .revoked:
                        // The Apple ID credential is revoked.
                        break
                    case .notFound:
                        // No credential was found, so show the sign-in UI.
                        break
                    default:
                        break
                 }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }

}

//check and update subscription
extension RegisterVc: PayPalPaymentDelegate {
    func checkSubscription(recValue: [String : Any]) {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "isPaid.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                  //  print(dict)
                    if String(describing: (dict["result"])!) == "1" {
                        objUser.parseUserData(recUserDict: recValue)
                        self.moveBackToApp()
                        
                    } else {
                        self.subscriptionCargesAPIHit()
                        objUser.parseUserData(recUserDict: recValue)
                        
                        self.overlayView.isHidden = false
                        
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
    
    func subscriptionCargesAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "subscriptioncharges.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    //  print(dict)
                    self.amountLbl.text = "$" + String(describing: ((dict["result"] as! NSDictionary).value(forKey: "charges"))!)
                    
                } else {
                    // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
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
    
        func paymentDoneSendToBackendAPI(transactionId: String) {
            applicationDelegate.startProgressView(view: self.view)
            
            let param: NSDictionary = ["userId": DataManager.userId, "transactionId": transactionId, "transactionAmount": (amountLbl.text!).replacingOccurrences(of: "$", with: "")]
            
            //   print(param)
            
            AlamoFireWrapper.sharedInstance.getPost(action: "paypalpayment.php", param: param as! [String : Any], onSuccess: { (responseData) in
                applicationDelegate.dismissProgressView(view: self.view)
                
                if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                    if (String(describing: (dict["success"])!)) == "1" {
                        
                        let alert = UIAlertController(title: appName, message: paySuccAlert, preferredStyle: .alert)
                        let okBtn = UIAlertAction(title: okBtnTitle, style: .default, handler: { (UIAlertAction) in
                            alert.dismiss(animated: true, completion: nil)
                            
                            self.overlayView.isHidden = true
    //                        objUser.parseUserData(recUserDict: recValue)
                            
                            self.moveBackToApp()
    //                        DataManager.isUserLoggedIn = true
    //
    //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
    //                        self.navigationController?.pushViewController(vc, animated: true)
                            
                        })
                        
                        alert.addAction(okBtn)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                        
                    }
                }
            }) { (error) in
              //  print(error.localizedDescription)
                
                applicationDelegate.dismissProgressView(view: self.view)
                if connectivity.isConnectedToInternet() {
                    CommonFunctions.showAlert(self, message: serverError, title: appName)
                    
                } else {
                    CommonFunctions.showAlert(self, message: noInternet, title: appName)
                    
                }
            }
        }
    
    func setUpPaypal() {
        //PayPal SetUp
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Xplore"//Your Company Name
        
        //Url's are just Paypal Merchant Policy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //language in which paypal sdk is shown. 0 for default language of app
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //If you use paypal, it is use address which is register in paypal. if you use both customer have the option to choose different or use paypal address
        payPalConfig.payPalShippingAddressOption = .both
        
    }
    
    //MARK:- Paypal Button Pressed
    //By Palpal
    func payPalButtonPressed() {
        //these are items which are being sold by merchant
        //if there is no amount in "NSDecimalNumber" paypal gives message "Payment not processalbe" and amount sholud be what the user enter reward for help request
        // NSDecimalNumber(string: "\(bidamount)")
        let amnt: String = (amountLbl.text!).replacingOccurrences(of: "$", with: "")
        
        let item1 = PayPalItem(name: "Subscription", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(amnt)"), withCurrency: "USD", withSku: "Hip-0037")
        
        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Subscription", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            UINavigationBar.appearance().barTintColor = appThemeColor
            UINavigationBar.appearance().tintColor = nil
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable, and you'd want
            // to handle that here.
            print("Payment not processalbe: \(payment)")
        }
    }
    
    // PayPalPaymentDelegate
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        print("PayPal Payment Success !")
        
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
           // self.paypalTransaction_id = String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!)
            
            self.paymentDoneSendToBackendAPI(transactionId: String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!))
            
        })
    }
}
