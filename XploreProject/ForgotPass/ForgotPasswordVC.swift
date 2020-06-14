//
//  ForgotPasswordVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 03/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    //MARK:- Iboutlets
    @IBOutlet weak var forgotPassScrollView: UIScrollView!
    @IBOutlet weak var emailTxtFld: UITextFieldCustomClass!
    
    //MARK:- Variable Declaration
    
    //MARK:- Inbuild Function
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addKeyboardObserver()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        
    }
   
    //MARK:- Function Definitions
    func checkValidations() ->Bool {
        if(((emailTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty))){
            self.emailTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: emailFieldEmptyAlertMessage, title: appName)
            
            return true
        } else if !((emailTxtFld.text!).isValidEmail()) {
            CommonFunctions.showAlert(self, message: invalidEmailAlertMessage, title: appName)
            self.emailTxtFld.becomeFirstResponder()
            
            return true
        }
        return false
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        let keyBoardHeight = keyboardSize.height + 50
        var contentInset:UIEdgeInsets = self.forgotPassScrollView.contentInset
        contentInset.bottom = keyBoardHeight
        self.forgotPassScrollView.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.forgotPassScrollView.contentInset = contentInset
        
    }
    
    //MARK:- API
    func forgotPassApiHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["email": emailTxtFld.text!.trimmingCharacters(in: .whitespaces)]
        
        AlamoFireWrapper.sharedInstance.getPost(action: "forgotPassword.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: appName, message: passwordSendToEmail, preferredStyle: .alert)
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
                self.showToast(message: serverError, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
                //CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    //MARK:- BUtton Actions
    @IBAction func tapSubmitBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if connectivity.isConnectedToInternet() {
            if !(self.checkValidations()) {
                self.forgotPassApiHit()
                
            }
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
         //   CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}
