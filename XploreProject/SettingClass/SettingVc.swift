
import UIKit

class SettingVc: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    //MARK:- Iboutlets
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var notificationCountLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- Variable Declarations
    var tableViewArray = NSArray()
    var hasLoaded = Bool()
    var shownIndexes : [IndexPath] = []
    
    //MARK:- Inbuild functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataManager.isUserLoggedIn! {
            self.startFunc()
            self.containerView.isHidden = true
            
        } else {
            Singleton.sharedInstance.loginComeFrom = settingStr
            self.containerView.isHidden = false
            
        }
    }
    
    //MARK:- Function definitions
    func startFunc() {
        settingTableView.tableFooterView = UIView()
        tableViewArray = [ChangePassword/*,Help*/,PushNotification, payHistory, About/*,Guidlines*/,TermsConditions,PrivacyPolicy,ContactUs]
        
//        self.hasLoaded = true
       // self.settingTableView.reloadWithAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.hasLoaded = true
            self.settingTableView.reloadWithAnimation()

        }
        if connectivity.isConnectedToInternet() {
            self.notificationONOffStatus()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        
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
    
    @IBAction func switchAction(_ sender: Any) {
        applicationDelegate.dismissProgressView(view: self.view)
        if connectivity.isConnectedToInternet() {
            self.notificationONOff()
            
        } else {
            CommonFunctions.showAlert(self, message: noInternet, title: appName)
            
        }
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        let alert = UIAlertController(title: appName, message: LogoutMessage, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: yesBtntitle, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            self.hitLogoutApi()
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- API
    func notificationONOff() {
        applicationDelegate.startProgressView(view: self.view)
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "enablePushNotifications.php/?userId="+String(describing: (DataManager.userId)), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    DataManager.pushNotification = Int(String(describing: (dict["result"])!)) as AnyObject
                    
                   // self.settingTableView.reloadWithAnimation()
                    
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
    
    func notificationONOffStatus() {
      //  applicationDelegate.startProgressView(view: self.view)
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "settings.php/?userId="+String(describing: (DataManager.userId)), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    
                    DataManager.pushNotification = Int(String(describing: (dict["result"])!)) as AnyObject
                    self.hasLoaded = true
                    
                    let indexPath = IndexPath(item: 2, section: 0)
                    self.settingTableView.reloadRows(at: [indexPath], with: .none)
                    
                    //self.settingTableView.reloadWithAnimation()
                    
                } else {
                    // CommonFunctions.showAlert(self, message: (String(describing: (dict["error"])!)), title: appName)
                    
                }
            }
        }) { (error) in
            applicationDelegate.dismissProgressView(view: self.view)
            if connectivity.isConnectedToInternet() {
             //   CommonFunctions.showAlert(self, message: serverError, title: appName)
                
            } else {
                CommonFunctions.showAlert(self, message: noInternet, title: appName)
                
            }
        }
    }
}

extension SettingVc: UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasLoaded ? self.tableViewArray.count : 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! MenuTableViewCell
        cell.settingTitleLabel.text = tableViewArray[indexPath.row] as? String
        cell.settingSwitchBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        if  cell.settingTitleLabel.text == PushNotification {
            cell.settingArrowImg.isHidden = true
            cell.settingSwitchBtn.isHidden = false
            
            if  String(describing: (DataManager.pushNotification)) == "1" {
                cell.settingSwitchBtn.isOn = true
                cell.settingSwitchBtn.onImage = #imageLiteral(resourceName: "Onswitch")
                
            } else {                
                cell.settingSwitchBtn.isOn = false
                cell.settingSwitchBtn.offImage = #imageLiteral(resourceName: "OffSwitch")
                
            }
        } else {
            cell.settingArrowImg.isHidden = false
            cell.settingSwitchBtn.isHidden = true

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let indexPath = indexPath.row
        switch (indexPath){
        case 0:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVc") as! ResetPasswordVc
            navigationController? .pushViewController(vc, animated: true)
            
        case 2:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryVC
            navigationController? .pushViewController(vc, animated: true)
            
            
        case 3:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            navigationController? .pushViewController(vc, animated: true)
            
//        case 4:
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuidelinesVC") as! GuidelinesVC
//            navigationController? .pushViewController(vc, animated: true)
//
        case 4:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsVc") as! TermsVc
            navigationController? .pushViewController(vc, animated: true)
            
        case 5:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVc") as! PrivacyVc
            navigationController? .pushViewController(vc, animated: true)
            
        case 6:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
            navigationController? .pushViewController(vc, animated: true)
        
        default:
            print("Home Button clicked")
        }
    }
}

extension SettingVc {
    func hitLogoutApi() {
        applicationDelegate.startProgressView(view: self.view)
        
        AlamoFireWrapper.sharedInstance.getOnlyApi(action: "unRegisterFirebaseToken.php?userId=" + (DataManager.userId as! String), onSuccess: { (responseData) in
            applicationDelegate.dismissProgressView(view: self.view)
            
            if let dict:NSDictionary = responseData.result.value as? NSDictionary {
                if (String(describing: (dict["success"])!)) == "1" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    DataManager.isUserLoggedIn = false
                    
                    notificationCount = 0
                    
//                    let revealViewControllerVcObj = storyboard.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
//                    self.navigationController!.pushViewController(revealViewControllerVcObj, animated: false)
                    
                    
                       userDefault.set(false,forKey: login.USER_DEFAULT_LOGIN_CHECK_Key)
                    let homeVc = storyboard.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
                    var vcArray = (applicationDelegate.window?.rootViewController as! UINavigationController).viewControllers
                    vcArray.removeAll()
                    vcArray.append(homeVc)
                    self.removeDataonLogout()
                    (applicationDelegate.window?.rootViewController as! UINavigationController).setViewControllers(vcArray, animated: false)
                    
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
    
    func removeDataonLogout() {
        let deviceToken = userDefault.value(forKey: "DeviceToken")!
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefault.set(deviceToken, forKey: "DeviceToken")
        
        let sing = Singleton.sharedInstance
        sing.homeFeaturesCampsArr = []
        sing.homeReviewBasedCampsArr = []
        sing.myCurrentLocDict = [:]
        sing.favouritesCampArr = []
        sing.myCampsArr = []
        sing.myProfileDict = [:]
        sing.notificationListingArr = []
        sing.chatListArr = []
        sing.loginComeFrom = ""
        
    }
}

extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.6, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}

