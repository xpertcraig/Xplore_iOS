//
//  ResetPasswordVc.swift
//  XploreProject
//
//  Created by shikha kochar on 26/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ResetPasswordVc: UIViewController {

    //MARK:- Iboutlets
    @IBOutlet weak var previousPassword: UITextFieldCustomClass!
    @IBOutlet weak var newPassword: UITextFieldCustomClass!
    @IBOutlet weak var ConfirmPassword: UITextFieldCustomClass!
    @IBOutlet weak var scroolView: UIScrollView!
    
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    var hasLoaded = Bool()
    
    //MARK:- InBuild Function
    override func viewDidLoad() {
        super.viewDidLoad()
       addKeyBoardObservers()
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
        
         self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }

    //MARK:- Function Definition
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
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
    
    @IBAction func tapShowHidePassBtn(_ sender: UIButton) {
        if self.ConfirmPassword.isSecureTextEntry == true {
            self.ConfirmPassword.isSecureTextEntry = false
            
        } else {
            self.ConfirmPassword.isSecureTextEntry = true
            
        }
    }
    
    @IBAction func changePassword(_ sender: Any){
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.hitResetApi()
                
            }
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension ResetPasswordVc {
    func checkValidations() ->Bool {
        if(((previousPassword.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.previousPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: PreviouspasswordFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if(previousPassword.text!).count < 8 {
            self.previousPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: prePasswordLengthAlert, title: appName)
            
            return true
        } else if(((newPassword.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.newPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: newPasswordMatchAlert, title: appName)
            
            return true
        } else if(newPassword.text!).count < 8 {
            self.newPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: newPasswordLengthAlert, title: appName)
            
            return true
        } else if(((ConfirmPassword.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.ConfirmPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: confirmPasswordEmptyAlert, title: appName)
            
            return true
        } else if(((ConfirmPassword.text!.trimmingCharacters(in: .whitespaces)))) != (((newPassword.text!.trimmingCharacters(in: .whitespaces)))){
            self.ConfirmPassword.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: mismatchPass, title: appName)
            
            return true
        }
        return false
    }
    
    func hitResetApi() {
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["userId": DataManager.userId, "ppwd": previousPassword.text!.trimmingCharacters(in: .whitespaces), "npwd": newPassword.text!.trimmingCharacters(in: .whitespaces), "cpwd": ConfirmPassword.text!.trimmingCharacters(in: .whitespaces)]
        
       // print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "resetPassword.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: appName, message: changeSuccessfully, preferredStyle: .alert)
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
extension ResetPasswordVc :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
