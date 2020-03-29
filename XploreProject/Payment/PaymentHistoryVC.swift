//
//  PaymentHistoryVC.swift
//  XploreProject
//
//  Created by Dharmendra on 13/08/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class PaymentHistoryVC: UIViewController, PayPalPaymentDelegate {

    @IBOutlet weak var payHistoryTblView: UITableView!
    
    var payCharges: String = ""
    var payhistoryArr: [[String: Any]] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.payHistoryTblView.tableFooterView = UIView()
        
        self.subscriptionCargesAPIHit()
        self.setUpPaypal()
        self.payHistoryAPIHit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    //MARK:- Function Definitions
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
    
    
    //MARK:- Button Actions
    @IBAction func tapAddUpdateCardBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.payPalButtonPressed()
        
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK:- Paypal Button Pressed
    //By Palpal
    func payPalButtonPressed() {
        //these are items which are being sold by merchant
        //if there is no amount in "NSDecimalNumber" paypal gives message "Payment not processalbe" and amount sholud be what the user enter reward for help request
        // NSDecimalNumber(string: "\(bidamount)")
        
        let amnt: String = self.payCharges
        
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
            //
            //            self.paypalTransaction_id = String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!)
            //
            //            print(self.paypalTransaction_id)
            
            self.paymentDoneSendToBackendAPI(transactionId: String(describing: ((completedPayment.confirmation as NSDictionary).value(forKey: "response") as! NSDictionary).value(forKey: "id")!))
            
            // self.postHelpRequestWeb()
            
        })
    }
}

extension PaymentHistoryVC {
    //MARK:- Api's Hit
    func payHistoryAPIHit() {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "paymentHistory.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                //    print(dict)
                    
                    self.payhistoryArr = dict["result"] as! [[String: Any]]
                    
                    self.payHistoryTblView.delegate = self
                    self.payHistoryTblView.dataSource = self
                    self.payHistoryTblView.reloadData()
                    
                } else {
                    //CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
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
    
    func subscriptionCargesAPIHit() {
        // applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "subscriptioncharges.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            //  applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    //  print(dict)
                    self.payCharges = String(describing: ((dict["result"] as! NSDictionary).value(forKey: "charges"))!)
                    
                } else {
                    // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            //   applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
                CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
    
    func paymentDoneSendToBackendAPI(transactionId: String) {
        applicationDelegate.startProgressView(view: self.view)
        
        let param: NSDictionary = ["userId": DataManager.userId, "transactionId": transactionId, "transactionAmount": self.payCharges]
        
        //   print(param)
        
        AlamoFireWrapper.sharedInstance.getPost(action: "paypalpayment.php", param: param as! [String : Any], onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:[String:Any] = responseData.result.value as? [String : Any] {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    let alert = UIAlertController(title: appName, message: paySuccAlert, preferredStyle: .alert)
                    let okBtn = UIAlertAction(title: okBtnTitle, style: .default, handler: { (UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                        
                        self.payHistoryAPIHit()
                        
                    })
                    
                    alert.addAction(okBtn)
                    
                    self.present(alert, animated: true, completion: nil)
                    
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
}

extension PaymentHistoryVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.payhistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.payHistoryTblView.dequeueReusableCell(withIdentifier: "PaymentHistoryTableViewCell", for: indexPath) as! PaymentHistoryTableViewCell
        
        let indexVal = self.payhistoryArr[indexPath.row]
        cell.transactionId.text! = String(describing: (indexVal["transactionId"])!)
        cell.transactionDate.text! = String(describing: (indexVal["transactionDate"])!)
        cell.transactionAmount.text! = "$\(String(describing: (indexVal["transactionAmount"])!))"
        
        return cell
    }
}
