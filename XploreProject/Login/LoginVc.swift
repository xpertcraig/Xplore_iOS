//
//  LoginVc.swift
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

class LoginVc: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate, PayPalPaymentDelegate {
    
    //MARK:- IbOutlets
    @IBOutlet weak var emailTextfeild: UITextFieldCustomClass!
    @IBOutlet weak var passwordTextFeild: UITextFieldCustomClass!
    @IBOutlet weak var scroolView: UIScrollView!
    
    @IBOutlet weak var backBtnImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var applePayBtn: UIView!
    
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
    
    //
   // var paypalTransaction_id = "0"
    
    //MARK:- Inbuild functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.setUpSignInAppleButton()
        } else {
            self.applePayBtn.isHidden = true
            // Fallback on earlier versions
        }
        self.overlayView.isHidden = true
        //Paypal
        self.setUpPaypal()
        
        self.addKeyBoardObservers()
        
        //call googleSignIn delegate
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        let sing = Singleton.sharedInstance
//        if sing.loginComeFrom == fromTopBar || sing.loginComeFrom == fromProfile || sing.loginComeFrom == fromNearByuser || sing.loginComeFrom == fromAddCamps || sing.loginComeFrom == fromNoti || sing.loginComeFrom == fromSearch || sing.loginComeFrom == fromFavCamps || sing.loginComeFrom == fromRevFavCamp {
            self.backBtn.isHidden = false
            self.backBtnImg.isHidden = false
           // self.navigationController?.tabBarController?.tabBar.isHidden = true
//        } else {
//            self.backBtn.isHidden = true
//            self.backBtnImg.isHidden = true
//            self.navigationController?.tabBarController?.tabBar.isHidden = false
//        }
        //PayPal
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
    
    //MARK:- Function definitions
    func setUpPaypal() {
        //PayPal SetUp
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Xplore"//Your Company Name
        
        UINavigationBar.appearance().barTintColor = appThemeColor
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
    
    //MARK:- google SignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            
        } else {
            self.googleLoginApiHit(email: user.profile.email!, userId: user.userID!, tokenId: user.authentication.idToken!, userFirstName: user.profile.givenName, userLastName: user.profile.familyName, userFullName: user.profile.name)
            
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    //MARK:- Button Action
    @IBAction func tapPayNowBtn(_ sender: UIButton) {
        self.payPalButtonPressed()
        
    }
    
    @IBAction func signInAction(_ sender: Any) {
        self.view.endEditing(true)
        self.hitLoginApi()
        
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        self.view.endEditing(true)
        let swRevealObj = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVc") as! RegisterVc
        self.navigationController?.pushViewController(swRevealObj, animated: true)
        
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
    
    @IBAction func googleAction(_ sender: Any) {
        self.view.endEditing(true)
        
        UserDefaults.standard.set(gmailLogin, forKey: XPLoginStatus)
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: false)
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func tapClosePaymentView(_ sender: Any) {
        self.view.endEditing(true)
        self.overlayView.isHidden = true
        
    }
}
extension LoginVc {
    //MARK: validations on textField
    func validateEmail(_ enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    func checkValidations() ->Bool {
        if(((emailTextfeild.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.emailTextfeild.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: emailFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if !((emailTextfeild.text!).isValidEmail()) {
            CommonFunctions.showAlert(self, message: invalidEmailAlertMessage, title: appName)
            self.emailTextfeild.becomeFirstResponder()
            
            return true
        } else if(((self.passwordTextFeild.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.passwordTextFeild.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: passwordFieldEmptyAlertMessage, title: appName)
            
            return true
        }
        return false
    }
    
    func hitLoginApi () {
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.LogInApiHit()
                
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func LogInApiHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        if userDefault.value(forKey: "DeviceToken") as? String == nil {
            userDefault.set(0, forKey: "DeviceToken")
            
        }
        
        let param: NSDictionary = ["email": self.emailTextfeild.text!.trimmingCharacters(in: .whitespaces), "password": passwordTextFeild.text!.trimmingCharacters(in: .whitespaces), "deviceToken": userDefault.value(forKey: "DeviceToken")! ,"deviceType": "ios","latitude": myCurrentLatitude, "longitude": myCurrentLongitude]
        
      //  print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "login.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    
                   // print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                    applicationDelegate.notificationCountApi()
                    
                 //   objUser.parseUserData(recUserDict: retValues)
                    self.checkSubscription(recValue: retValues)
                    self.commonViewModel.updateFirebaseProfile()
                    
                } else {
                    if (String(describing: (dict["error"])!)) == passMismatch {
                        CommonFunctions.showAlert(self, message: showOnPassMismatch, title: appName)
                    } else {
                        CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    }
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
                    
                 //   print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                    applicationDelegate.notificationCountApi()
                    //objUser.parseUserData(recUserDict: retValues)
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
        
      //  print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "register.php", param: param , onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    let retValues = ((dict["result"]! as AnyObject) as! [String : Any])
                    
             //       print(retValues)
                    
                    DataManager.userId = retValues["userId"] as AnyObject
                    DataManager.emailAddress = retValues["email"] as AnyObject
                    DataManager.name = retValues["name"] as AnyObject
                    DataManager.pushNotification = retValues["isPushNotificationsEnabled"] as AnyObject
                    DataManager.isPaid = retValues["isPaid"] as AnyObject
                    
                    applicationDelegate.notificationCountApi()
                    //objUser.parseUserData(recUserDict: retValues)
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
    
    func checkSubscription(recValue: [String : Any]) {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "isPaid.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            
            applicationDelegate.dismissProgressView(view: self.view)
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                  //  print(dict)
                    if String(describing: (dict["result"])!) == "1" {
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
        contentInset.bottom = keyBoardHeight
        self.scroolView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scroolView.contentInset = contentInset
    }
}
extension LoginVc :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}


@available(iOS 13.0, *)
extension LoginVc: ASAuthorizationControllerDelegate {
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
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
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
