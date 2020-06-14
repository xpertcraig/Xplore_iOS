//
//  PaymentVC.swift
//  XploreProject
//
//  Created by iMark_IOS on 25/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController, PayPalPaymentDelegate {

    //MARK:- Iboutlets
    @IBOutlet weak var paymentScrollVIew: UIScrollView!
    
    @IBOutlet weak var amountLbl: UILabel!
    
    @IBOutlet weak var cardNum1Lbl: UILabel!
    @IBOutlet weak var cardNum1Btn: UIButton!
    
    @IBOutlet weak var cardNum2Lbl: UILabel!
    @IBOutlet weak var cardNum2Btn: UIButton!
    
    @IBOutlet weak var cardNum3Lbl: UILabel!
    @IBOutlet weak var cardNum3Btn: UIButton!
    
    @IBOutlet weak var enterCardNumTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var enterCardHolderNameTxtFld: UITextFieldCustomClass!
    @IBOutlet weak var expiryTxtFLd: UITextFieldCustomClass!
    @IBOutlet weak var cvvTxtFld: UITextFieldCustomClass!
    
    @IBOutlet weak var firstCardView: UIView!
    @IBOutlet weak var secondCardView: UIView!
    @IBOutlet weak var thirldCardView: UIView!
    
    @IBOutlet weak var firstCardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondCardViewHeight: NSLayoutConstraint!
    @IBOutlet weak var thirldCardViewHeight: NSLayoutConstraint!
    
    //MARK:- Variable Declarations
    var myCardListArr: NSArray = []
    
    var cvvLength = 0
    var cardNumLength = 0
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    
    
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
    //paypal
    var selectedPaymentMethodDetail: NSDictionary = [:]
    //
    var paypalTransaction_id = "0"
    var paymentType: String = "0"
    
    //MARK:- inbuild functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.paymentScrollVIew.isHidden = true
        self.enterCardNumTxtFld.addTarget(self, action: #selector(addSpaceInTxtFld), for: .editingChanged)
        
        ///////
        self.callAPI()
        self.addKeyBoardObservers()
        
        //Paypal
        self.setUpPaypal()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //PayPal
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    //MARK:- Function Definitions
    func setUpPaypal() {
        //PayPal SetUp
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Awesome Shirts, Inc."//Your Company Name
        
        //Url's are just Paypal Merchant Policy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //language in which paypal sdk is shown. 0 for default language of app
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //If you use paypal, it is use address which is register in paypal. if you use both customer have the option to choose different or use paypal address
        payPalConfig.payPalShippingAddressOption = .both
        
    }

    
    func setDesign() {
        if self.myCardListArr.count == 0{
            self.firstCardViewHeight.constant = 0
            self.secondCardViewHeight.constant = 0
            self.thirldCardViewHeight.constant = 0
            
            self.firstCardView.isHidden = true
            self.secondCardView.isHidden = true
            self.thirldCardView.isHidden = true
            
        } else if self.myCardListArr.count == 1 {
            self.secondCardViewHeight.constant = 0
            self.thirldCardViewHeight.constant = 0
            
            self.firstCardView.isHidden = false
            self.secondCardView.isHidden = true
            self.thirldCardView.isHidden = true
            
        } else if self.myCardListArr.count == 2 {
            self.secondCardViewHeight.constant = 0
            
            self.firstCardView.isHidden = false
            self.secondCardView.isHidden = false
            self.thirldCardView.isHidden = true
            
        }
    }
    
    func callAPI() {
        if connectivity.isConnectedToInternet() {
            self.myCardAPIHit()
            self.subscriptionCargesAPIHit()
            
        } else {
            self.showToast(message: noInternet, font: .systemFont(ofSize: 12.0))
            //CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    func addKeyBoardObservers() {
        //keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        let keyBoardHeight = keyboardSize.height
        var contentInset:UIEdgeInsets = self.paymentScrollVIew.contentInset
        contentInset.bottom = keyBoardHeight
        self.paymentScrollVIew.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.paymentScrollVIew.contentInset = contentInset
    }
    
    func checkValidation() {
        if enterCardNumTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.enterCardNumTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cardNumAlert, title: appName)
            
        } else if (self.enterCardNumTxtFld.text?.count)! < self.cardNumLength {
            self.enterCardNumTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cardNumRangeAlert, title: appName)
            
        } else if enterCardHolderNameTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.enterCardHolderNameTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cardHolderAlert, title: appName)
            
        } else if expiryTxtFLd.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.expiryTxtFLd.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cardExpiryAlert, title: appName)
            
        } else if expiryTxtFLd.text!.trimmingCharacters(in: .whitespaces).count < 5{
            self.expiryTxtFLd.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cardExpiryRangeAlert, title: appName)
            
        } else if cvvTxtFld.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.cvvTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cvvAlert, title: appName)
            
        } else if cvvTxtFld.text!.trimmingCharacters(in: .whitespaces).count < cvvLength {
            self.cvvTxtFld.becomeFirstResponder()
            CommonFunctions.showAlert(self, message: cvvRangeAlert, title: appName)
            
        }else {
            self.view.endEditing(true)
            self.payPalButtonPressed()
            
        }
    }
    
    //MARK:- Paypal Button Pressed
    //By Palpal
    func payPalButtonPressed() {
        //these are items which are being sold by merchant
        //if there is no amount in "NSDecimalNumber" paypal gives message "Payment not processalbe" and amount sholud be what the user enter reward for help request
        // NSDecimalNumber(string: "\(bidamount)")
        
        let item1 = PayPalItem(name: "Subscription", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(String(describing: amountLbl.text!))"), withCurrency: "USD", withSku: "Hip-0037")
        
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
            
            self.paypalTransaction_id = String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!)
            
            print(self.paypalTransaction_id)
            
           // self.postHelpRequestWeb()
            
        })
    }
    
    //MARK:- Api's Hit
    func myCardAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "myCards.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            self.paymentScrollVIew.isHidden = false
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                 //   print(dict)
                    self.myCardListArr = dict["result"] as! NSArray
                
                } else {
                    //CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
                self.setDesign()
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
    
    func subscriptionCargesAPIHit(){
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "subscriptioncharges.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            self.paymentScrollVIew.isHidden = false
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                   
                  //  print(dict)
                    self.amountLbl.text = String(describing: ((dict["result"] as! NSDictionary).value(forKey: "charges"))!) + "$"
                    
                } else {
                   // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
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
    
    //MARK:- IbAction
    @IBAction func tapPayBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.checkValidation()
        
    }
    
    @IBAction func tapCard1Btn(_ sender: UIButton) {
        if (self.cardNum1Btn.currentImage?.isEqual(UIImage(named: "FilledTick")))! {

        } else {
            self.cardNum1Btn.setImage(#imageLiteral(resourceName: "FilledTick"), for: .normal)
            self.cardNum2Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            self.cardNum3Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            
        }
    }
    
    @IBAction func tapCard2Btn(_ sender: UIButton) {
        if (self.cardNum2Btn.currentImage?.isEqual(UIImage(named: "FilledTick")))! {

        } else {
            self.cardNum2Btn.setImage(#imageLiteral(resourceName: "FilledTick"), for: .normal)
            self.cardNum1Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            self.cardNum3Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            
        }        
    }
    
    @IBAction func tapCard3Btn(_ sender: UIButton) {
        if (self.cardNum3Btn.currentImage?.isEqual(UIImage(named: "FilledTick")))! {

        } else {
            self.cardNum3Btn.setImage(#imageLiteral(resourceName: "FilledTick"), for: .normal)
            self.cardNum2Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            self.cardNum1Btn.setImage(#imageLiteral(resourceName: "unfilledTick"), for: .normal)
            
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension PaymentVC :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == enterCardNumTxtFld {
            previousTextFieldContent = textField.text;
            previousSelection = textField.selectedTextRange;
            
        } else if textField == enterCardHolderNameTxtFld {
            
            
        }else if textField == cvvTxtFld {
            if enterCardNumTxtFld.text == "" {
                return false
                
            } else {
                if ((enterCardNumTxtFld.text)?.hasPrefix("37"))! || ((enterCardNumTxtFld.text)?.hasPrefix("34"))! {
                    if range.location == 4 {
                        return false
                    }
                    
                } else if ((enterCardNumTxtFld.text)?.hasPrefix("4"))! || ((enterCardNumTxtFld.text)?.hasPrefix("5"))! || ((enterCardNumTxtFld.text)?.hasPrefix("6"))!  {
                    if range.location == 3 {
                        return false
                    }
                }
            }
            
        } else {
            if range.length > 0 {
                return true
            }
            if string == "" {
                return false
            }
            if range.location > 4 {
                return false
            }
            var originalText = textField.text
            let replacementText = string.replacingOccurrences(of: " ", with: "")
            
            //Verify entered text is a numeric value
            if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: replacementText)) {
                return false
            }
            
            //Put / after 2 digit
            if range.location == 2 {
                originalText?.append("/")
                textField.text = originalText
            }
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .darkGray
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target:self, action:#selector(tapDoneButton))
        doneButton.tintColor = UIColor.white
        let items:Array = [doneButton]
        toolbar.items = items
        
        textField.inputAccessoryView = toolbar
        return true
        
    }
    
    @objc func tapDoneButton() {
        self.view.endEditing(true)
        
    }
    
    @objc func addSpaceInTxtFld(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if ((textField.text)?.hasPrefix("37"))! || ((textField.text)?.hasPrefix("34"))! {
            if cardNumberWithoutSpaces.count > 15 {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                
                self.cvvLength = 4
                self.cardNumLength = 15
                return
            }
            
        } else if ((textField.text)?.hasPrefix("4"))! || ((textField.text)?.hasPrefix("5"))! || ((textField.text)?.hasPrefix("6"))!  {
            if cardNumberWithoutSpaces.count > 16 {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                
                self.cvvLength = 3
                self.cardNumLength = 16
                return
            }
            
        }
        
        //        if cardNumberWithoutSpaces.count > 19 {
        //            textField.text = previousTextFieldContent
        //            textField.selectedTextRange = previousSelection
        //            return
        //        }
        
        let cardNumberWithSpaces = self.insertCreditCardSpaces(cardNumberWithoutSpaces, preserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
        
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertCreditCardSpaces(_ string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        let is456 = string.hasPrefix("1")
        
        let is465 = [
            // Amex
            "34", "37",
            
            // Diners Club
            "300", "301", "302", "303", "304", "305", "309", "36", "38", "39"
            ].contains { string.hasPrefix($0) }
        
        let is4444 = !(is456 || is465)
        
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs465Spacing = (is465 && (i == 4 || i == 10 || i == 15))
            let needs456Spacing = (is456 && (i == 4 || i == 9 || i == 15))
            let needs4444Spacing = (is4444 && i > 0 && (i % 4) == 0)
            
            if needs465Spacing || needs456Spacing || needs4444Spacing {
                stringWithAddedSpaces.append(" ")
                
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    
}
