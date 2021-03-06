//
//  ChatViewController.swift
//  NewAppDemo
//
//  Created by OSX on 02/01/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FTIndicator
import Photos
import SDWebImage

class SendCell :UITableViewCell {
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var msgTimeLbl: UILabel!
    
    override func awakeFromNib() {
        view.layer.cornerRadius = 5.0
    }
}

class SendImageCell:UITableViewCell {
    @IBOutlet weak var imgVwSend: UIImageView!
    
    override func awakeFromNib() {
        imgVwSend.layer.cornerRadius = 5.0
        imgVwSend.clipsToBounds = true
    }
}

class ReceiveCell :UITableViewCell {
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var recieveLabel: UILabel!
    @IBOutlet weak var msgRecTimeLbl: UILabel!
    
    
    override func awakeFromNib() {
        view.layer.cornerRadius = 5.0
        
    }
}

class ReceiveImageCell: UITableViewCell {
    @IBOutlet weak var imgVwReceive: UIImageView!
    
    override func awakeFromNib() {
        imgVwReceive.layer.cornerRadius = 5.0
        imgVwReceive.clipsToBounds = true
    }
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK:- IBOutlets
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chatBoxBottom: NSLayoutConstraint!
    @IBOutlet weak var userIMgView: UIImageViewCustomClass!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var notificationCountLbl: UILabel!
    
    //MARK:- Variables
    var chatArray : NSMutableArray = []
    var filename:String!
    var comeFrom = ""
    var receiverId: String = ""
    let imagePicker = UIImagePickerController()
    var uploadImage = UIImage()
    var chatUnitId:String = ""
    var userInfoDict: NSDictionary = [:]
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(userInfoDict)
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
             UIApplication.shared.statusBarView?.backgroundColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)
            
        }
        
       
        
        if self.comeFrom == "UserProfile" {
            if let name = (userInfoDict.value(forKey: "name") as? String) {
                self.userNameLbl.text! = name
                
            } else {
                if let name = (userInfoDict.value(forKey: "authorName") as? String) {
                    self.userNameLbl.text! = name
                    
                } else {
                    self.userNameLbl.text! = ""
                    
                }
            }
            
            self.userIMgView.sd_setShowActivityIndicatorView(true)
            self.userIMgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
            self.userIMgView.sd_setImage(with: URL(string: String(describing: (userInfoDict.value(forKey: "profileImage") as! String))), placeholderImage: UIImage(named: ""))
            
        } else if self.comeFrom == "Notification" {
            self.getUserInfo(userId: String(describing: (userInfoDict.value(forKey: "othersUserId"))!))
        } else {
            if String(describing: (DataManager.userId)) == (userInfoDict.value(forKey: "userId") as? String) {
                self.getUserInfo(userId: String(describing: (userInfoDict.value(forKey: "othersUserId"))!))

            } else {
                self.getUserInfo(userId: String(describing: (userInfoDict.value(forKey: "userId"))!))

            }
        }
        
        if String(describing: (DataManager.userId)) < receiverId {
            chatUnitId = receiverId + "-" + String(describing: (DataManager.userId))
            
        } else {
            chatUnitId = String(describing: (DataManager.userId)) + "-" + receiverId
            
        }
        IQKeyboardManager.shared.enable = false
      //  IQKeyboardManager.sharedManager().enable = false
        
        chatTextView.layer.cornerRadius = 5.0
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        chatTableView.register(UINib(nibName:"ReceiveCell", bundle : nil), forCellReuseIdentifier: "ReceiveCell")
        chatTableView.register(UINib(nibName:"ReceiveImageCell", bundle : nil), forCellReuseIdentifier: "ReceiveImageCell")
        chatTableView.register(UINib(nibName:"SendCell", bundle : nil), forCellReuseIdentifier: "SendCell")
        chatTableView.register(UINib(nibName:"SendImageCell", bundle : nil), forCellReuseIdentifier: "SendImageCell")
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 1000
        
        chatTableView.separatorStyle = .none
        
        chatTableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        applicationDelegate.startProgressView(view: self.view)
        observeChannels()
        observeChannelsToRemove()
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.handleLongPress))
//        chatTableView.addGestureRecognizer(longPress)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        self.notificationCountLbl.text! = String(describing: (notificationCount))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.chatArray.count == 0 {
            let ref = Database.database().reference()
            ref.child("Users").child(chatUnitId).removeValue()
        } else {
            //update message and time in user database
            Database.database().reference().child("Users").child(chatUnitId).child("last_msg").setValue(((chatArray.lastObject as! NSDictionary)["message"]))
            Database.database().reference().child("Users").child(chatUnitId).child("last_msgTime").setValue((Double(String(describing: ((chatArray.lastObject as! NSDictionary)["postDate"])!))!))
            
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
//        
//    }
    
    //MARK: - Status Color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
        
    }
    
    var longPressIndex:Int!
    
    //MARK:- Delete cell on long press
    @objc func handleLongPress(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.began
        {
            let touchPoint = sender.location(in: chatTableView)
            if let indexPath = chatTableView.indexPathForRow(at: touchPoint)
            {
                longPressIndex = indexPath.row
                let nodeId = (self.chatArray[indexPath.row] as! NSDictionary)["nodeId"]
               // print(nodeId!)
                
                let updateRef  = Database.database().reference().child("Messages").child(chatUnitId).child(nodeId as! String)
                
                if (self.chatArray[indexPath.row] as! NSDictionary)["sender_id"] as! String == String(describing: (DataManager.userId))
                {
                    let alert = UIAlertController(title: "Delete message", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let deleteMyMsg = UIAlertAction(title: "From My side", style: .default, handler: { (action) in
                        
                        updateRef.updateChildValues(["myMsg":"1"])
                        
                        FTIndicator.showToastMessage("Message deleted from my side")
                    })
                    
                    let deleteOtherMsg = UIAlertAction(title: "From Other side", style: .default, handler: { (action) in
                        
                        updateRef.updateChildValues(["otherMsg":"1"])
                        
                        FTIndicator.showToastMessage("Message deleted from other side")
                    })
                    
                    let deleteBothMsg = UIAlertAction(title: "From Both side", style: .default, handler: { (action) in
                        
                        updateRef.updateChildValues(["myMsg":"1"])
                        
                        updateRef.updateChildValues(["otherMsg":"1"])
                        
                        FTIndicator.showToastMessage("Message deleted from both side")
                    })
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(deleteMyMsg)
                    alert.addAction(deleteOtherMsg)
                    alert.addAction(deleteBothMsg)
                    alert.addAction(cancel)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //MARK:- Save data to the firebase
    func getUserInfo(userId: String) {
        let ref = Database.database().reference().child("UsersProfile")
        ref.child(userId).observe(.value, with: { (shot) in
            
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                print(postDict)
                self.userNameLbl.text! = String(describing: postDict["username"]!)
                
                self.userIMgView.sd_setShowActivityIndicatorView(true)
                self.userIMgView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                self.userIMgView.sd_setImage(with: URL(string: String(describing: postDict["userProfileImage"]!)), placeholderImage: UIImage(named: ""))
                
            }
        })
    }
    
    func sendMessageData() {
        
        let ref = Database.database().reference().child("Messages").child(chatUnitId)
        let childRef = ref.childByAutoId()
        
        let dictMessage = ["sender_id": String(describing: (DataManager.userId)),"receiver_id":receiverId,"message": self.chatTextView.text!, "postDate":  ServerValue.timestamp(), "messageType":"","nodeId":"\(String(describing: (childRef.key)!))","myMsg":"0","otherMsg":"0"] as [String : Any]
        
        childRef.updateChildValues(dictMessage)
        
        //update message and time in user database
        Database.database().reference().child("Users").child(chatUnitId).child("last_msg").setValue(self.chatTextView.text!)
        Database.database().reference().child("Users").child(chatUnitId).child("last_msgTime").setValue(ServerValue.timestamp())
        
        let sender = PushNotificationSender()
        let refU = Database.database().reference().child("UsersProfile")
        refU.child(receiverId).observe(.value, with: { (shot) in
            
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                print(postDict)
                if let deviceToken = postDict["deviceToken"] as? String {
                    sender.sendPushNotification(to: "\(String(describing: postDict["deviceToken"]!))", title: "\(String(describing: (DataManager.name))) sent you a message", body: self.chatTextView.text!, userId: DataManager.userId as! String)
                }
                self.chatTextView.text = ""
                self.chatTextViewHeight.constant = 33.0
            }
        })
    }
    
    //MARK:- Fetch data from the firebase
    func observeChannels() {
        let ref = Database.database().reference()
        ref.child("Messages").child(chatUnitId).observe(.value) { (snapShot) in
            if snapShot.value as? Dictionary<String, AnyObject> == nil {
                applicationDelegate.dismissProgressView(view: self.view)
            }
        }
        ref.child("Messages").child(chatUnitId).observe(.childAdded, with: { (shot) in
            applicationDelegate.dismissProgressView(view: self.view)
            if let postDict = shot.value as? Dictionary<String, AnyObject> {
                
                if postDict["sender_id"] as? String == String(describing: (DataManager.userId)) && postDict["receiver_id"] as? String == self.receiverId {
                    let myMsgStatus = postDict["myMsg"] as! String
                    
                    if myMsgStatus != "1" {
                        self.chatArray.add(postDict as [String : Any])
                        self.chatTableView.reloadData()
                        
                    }
                    
                    if self.chatArray.count > 0 {
                      //  print(self.chatArray)
                        self.chatTableView.scrollToRow(at: IndexPath(item:self.chatArray.count-1, section: 0), at: .bottom, animated: false)
                        
                    }
                } else if (postDict["sender_id"] as? String)! == self.receiverId && postDict["receiver_id"] as? String == String(describing: (DataManager.userId)) {
                    let otherMsgStatus = postDict["otherMsg"] as! String
                    if otherMsgStatus != "1" {
                        self.chatArray.add(postDict as [String : Any])
                        self.chatTableView.reloadData()
                        
                    }
                    if self.chatArray.count > 0 {
                     //   print(self.chatArray)
                        self.chatTableView.scrollToRow(at: IndexPath(item:self.chatArray.count-1, section: 0), at: .bottom, animated: false)
                        
                    }
                }
            }
        })
    }
    
    //MARK:- Changed data in firebase
    func observeChannelsToRemove() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        
        ref.child("Messages").child(chatUnitId).observe(.childChanged, with: { (shot) in
            if var postDict = shot.value as? Dictionary<String, AnyObject> {
                if postDict["sender_id"] as? String == String(describing: (DataManager.userId)) && postDict["receiver_id"] as? String == self.receiverId {
                    if postDict["myMsg"] as! String == "1" {
                       // print(self.chatArray)
                        postDict["myMsg"] = "0" as AnyObject?
                        if postDict["otherMsg"] as! String == "1" {
                            self.chatArray.remove(postDict)
                        }
                        if postDict["otherMsg"] as! String == "1" {
                            postDict["otherMsg"] = "0" as AnyObject?
                            self.chatArray.remove(postDict)
                        }
                        self.chatArray.remove(postDict)
                        self.chatTableView.reloadData()
                    }
                    
                    if self.chatArray.count > 0 {
                      //  print(self.chatArray)
                        self.chatTableView.scrollToRow(at: IndexPath(item:self.chatArray.count-1, section: 0), at: .bottom, animated: false)
                    }
                    
                }
                    
                if (postDict["sender_id"] as? String)! == self.receiverId && postDict["receiver_id"] as? String == String(describing: (DataManager.userId)) {
                    if postDict["otherMsg"] as! String == "1" {
                      //  print(self.chatArray)
                        postDict["otherMsg"] = "0" as AnyObject?
                        if postDict["myMsg"] as! String == "1" {
                            self.chatArray.remove(postDict)
                        }
                        if postDict["myMsg"] as! String == "1" {
                            postDict["myMsg"] = "0" as AnyObject?
                            self.chatArray.remove(postDict)
                        }
                        self.chatArray.remove(postDict)
                        self.chatTableView.reloadData()
                    }
                    
                    if self.chatArray.count > 0 {
                       // print(self.chatArray)
                        self.chatTableView.scrollToRow(at: IndexPath(item:self.chatArray.count-1, section: 0), at: .bottom, animated: false)
                    }
                }
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            applicationDelegate.dismissProgressView(view: self.view)
            
        }
    }
    
    //MARK:- Keyboard will show
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            chatBoxBottom.constant = keyboardRectangle.height
        }
    }
    
    //MARK:- Keyboard will hide
    @objc func keyboardWillHide(_ notification: NSNotification) {
        chatBoxBottom.constant = 8
    }
    
    //MARK:- TextView Delegate Methods
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height <= 120 {
            chatTextViewHeight.constant = newSize.height
        }
        else {
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Your Message" || textView.text == "" {
            textView.text = ""
            textView.textColor = UIColor.darkGray
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Your Message"
            textView.textColor = UIColor.lightGray
            
        }
    }
    
    //MARK:- Open Camera
    func openCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBtnTap(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        
    }
    //MARK:- Open Photo Gallery
    func openPhotoLibraryButton() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- Resize the image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //MARK:- ImagePicker Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        FTIndicator.showProgress(withMessage: "Loading...")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL as URL], options: nil)
                filename = result.firstObject?.value(forKey: "filename") as! String
             //   print(filename)
            }
            
            uploadImage = resizeImage(image: image, newWidth: 200)
        }
        else {
            print("Something went wrong")
        }
        dismiss(animated:true, completion: nil)
        
        WebServices.uploadMedia(filename: filename, uploadImage: uploadImage) { url in
            if url != nil {
                FTIndicator.dismissProgress()
                
                let ref = Database.database().reference().child("Messages").child(self.chatUnitId)
                let childRef = ref.childByAutoId()
                
                let dictMessage = ["sender_id": String(describing: (DataManager.userId)),"receiver_id":self.receiverId,"message":"","messageType":url!,"nodeId":"\(String(describing: childRef.key))","myMsg":"0","otherMsg":"0"]
                
                childRef.updateChildValues(dictMessage)
            }
        }
    }
    
    //MARK:- IBActions
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
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func sendImages(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Select an option to get the Image", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAlert = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCameraButton()
        }
        let photoGalleryAlert = UIAlertAction(title: "Photo Gallery", style: .default) { (action) in
            self.openPhotoLibraryButton()
        }
        
        alert.addAction(cameraAlert)
        alert.addAction(photoGalleryAlert)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sendBtnActn(_ sender: Any) {
        let myString:String = chatTextView.text!
        chatTextView.text = myString.trimmingCharacters(in: .whitespacesAndNewlines)
       // print(chatTextView.text)
        
        if chatTextView.text! != "" {
            sendMessageData()
            
        }
    }
    
    //MARK:- TableViewDataSources
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (chatArray[indexPath.row] as! NSDictionary).value(forKey: "sender_id") as? String == String(describing: (DataManager.userId)) {
            
            if (chatArray[indexPath.row] as! NSDictionary)["message"] as! String != "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendCell") as! SendCell
                cell.sendLabel.text = (chatArray[indexPath.row]as! NSDictionary)["message"] as? String
              
                cell.msgTimeLbl.text! = CommonFunctions.changeUNXTimeStampToTIme(recUnxTimeStamp: (Double(String(describing: ((chatArray[indexPath.row] as! NSDictionary)["postDate"])!))!))
                
                //update message and time in user database
               // Database.database().reference().child("Users").child(chatUnitId).child("last_msg").setValue(cell.sendLabel.text)
                //Database.database().reference().child("Users").child(chatUnitId).child("last_msgTime").setValue((Double(String(describing: ((chatArray[indexPath.row] as! NSDictionary)["postDate"])!))!))
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendImageCell") as! SendImageCell
                
                let imageUrl = URL(string: ((chatArray[indexPath.row] as! NSDictionary)["messageType"] as! String))
                
                cell.imgVwSend.sd_setShowActivityIndicatorView(true)
                cell.imgVwSend.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.imgVwSend.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
                return cell
            }
        } else {
            if (chatArray[indexPath.row]as! NSDictionary)["message"] as! String != "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveCell") as! ReceiveCell
                cell.isUserInteractionEnabled = false
                cell.recieveLabel.text = (chatArray[indexPath.row] as! NSDictionary)["message"] as? String
                
                cell.msgRecTimeLbl.text! = CommonFunctions.changeUNXTimeStampToTIme(recUnxTimeStamp: (Double(String(describing: ((chatArray[indexPath.row] as! NSDictionary)["postDate"])!))!))
                
                //update message and time in user database
            //    Database.database().reference().child("Users").child(chatUnitId).child("last_msg").setValue(cell.recieveLabel.text)
                //Database.database().reference().child("Users").child(chatUnitId).child("last_msgTime").setValue((Double(String(describing: ((chatArray[indexPath.row] as! NSDictionary)["postDate"])!))!))
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveImageCell") as! ReceiveImageCell
                cell.isUserInteractionEnabled = false
                let imageUrl = URL(string: ((chatArray[indexPath.row] as! NSDictionary)["messageType"] as! String))
                
                cell.imgVwReceive.sd_setShowActivityIndicatorView(true)
                cell.imgVwReceive.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
                cell.imgVwReceive.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder.png"))
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
        
    }
}
