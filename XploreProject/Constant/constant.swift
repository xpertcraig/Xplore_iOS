//
//  constant.swift
//  SellSwap
//
//  Created by shikha kochar on 08/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let textFieldDefaultColor = UIColor(red: 168.0/255, green: 168.0/255, blue: 168.0/255, alpha: 1.0)
let textFieldActiveColor = UIColor(red: 60.0/255, green: 100.0/255, blue: 210.0/255, alpha: 1.0)

let appThemeColor: UIColor = UIColor(red: 234/255, green: 102/255, blue: 7/255, alpha: 1.0)

//old used key
//let googleApiKey = "AIzaSyCdI3kg1PGvy00zttaoR4NBMgWqeHN-QTA"

//new by sir
let googleApiKey = "AIzaSyBwACZfpIgU47tZP_IeJQSj2ubYERgYciQ"

//by prachi
//let googleApiKey = "AIzaSyDuMxcTE9veBDMS_jjIjHJ0ltUVCyGMn2I"
//let googleApiKey = "AIzaSyDdfUiEN3grZALqX9tRHBD6WcqTaZ57XRc"

var notificationCount: Int = 0

let appName = "Xplorecampsite"
let okBtnTitle = "ok"
let yesBtntitle = "yes"
let noBtnTitle = "no"
let chooseImage = "Choose Image"
let Cancel  = "Cancel"
let Gallery  = "Gallery"
let Camera = "Camera"

let country = "country"
let state = "state"
let city = "city"
let myProfile = "myProfile"
let favouritesCamp = "favouritesCamp"
let addCampsiteComeFrom = "addCampsite"
let savedCamp = "savedCamp"
let draftCamp = "mydraft"
let publishCamp = "publishCamp"
let featuredBased = "fearuredBasedCamps"
let reviewBased = "reviewBasedCamps"
let allCamps = "All Campsites"

//MARK:- payment
let cardNumAlert = "Please enter card number."
let cardNumRangeAlert = "Please enter valid card number."
let cardHolderAlert = "Please enter card holder name."
let cardExpiryAlert = "Please enter card expiry."
let cardExpiryRangeAlert = "Please enter valid card expiry."
let cvvAlert = "Please enter cvv."
let cvvRangeAlert = "Please enter valid cvv."
let paySuccAlert = "Payment successfully done."
var paymentSuccess = false

//MARK:- Login
let yourSubscription = "Your subscription is expire, please pay to countinue using the app."

//MARK:- Filter
let selectOneAlert = "Please select atleast one."
let countryEmptyAlertF = "Please select the country."
let stateEmptyAlertF = "Please select state."
let cityEmptyAlert = "Please select city."
let filter = "filter"
let googleSearch = "googleSearch"
let notFromTabbar = "NotFromTabbar"
let filterPush = "filterPush"


//campsite details
let campSavedAlert = "Campsite is Saved."
let alreadySavedCampAlert = "Camp already saved."
let abuseEmptyALert = "Please enter abuse reason."
let receivedAbouseAlert = "Thank you, we have received your feedback."
let alreadyMarkAbuseAlert = "You have already marked this campsite as abused."
let selfPost = "Sorry, you can not add review to your own post."

let postReviewFirst = "Be the first to post review"

//Add Campsite
let campsiteAddr1Empty = "Please enter campsite address1."
let countryEmpty = "Please select country."
let cityEmpty = "Please select city."
let stateEmpty = "Please select state."
let locationNotFound = "Your location is not found, please select closest location."
let diffClosestLoc = "Please type different closest location."
let campsiteEmptyAlert = "Please enter campsite name."
let typeEmptyAlert = "Please select type."
let campsiteAddressAlert = "Please enter campsite address1."
let countryEmptyAlert = "Please enter country."
let stateEmprtyAlert = "Please enter state."
let descriptionEmptyAlert = "Please enter description."
let elevationEmptyAlert = "Please enter elevation."
let numberOfSitesEmptyAlert = "Please enter number of sites."
let climateEmptyAlert = "Please enter climate."
let bestMonthEmptyAlert = "Please select best month to visit."
let hookupsEmptyalert = "Please select hookups."
let amentiesEmptyAlert = "Please select amenties."
let noPhotoAlert = "Please select photo."
let downloadGoogleMapApp = "Please download google map app to use this feature."
let campsavedasDraft = "Campsite is saved to drafts."

//conatct us alert
let titleEmptyAlert = "Please enter title."
let messageEmptyAlert = "Please enter message."
let submitContactMessageAlert = "Thank you for your message, it is well received."

//MARK:- Select Option
var typeArr: NSArray = []
var amentiesArr: NSArray = []
var hookupArr: NSArray = []
let myDraft = "MySavedDraft"
let mySavesCamps = "SavedCamps"

let ChangePassword = "Change Password"
let payHistory = "Payment History"
let Help = "Help"
let PushNotification = "Push Notification"
let About = "About"
let Guidlines = "Guidelines"
let TermsConditions = "Terms & Conditions"
let PrivacyPolicy = "Privacy Policy"
let ContactUs = "Contact Us"
let validWebUrl = "Please enter valid weburl"
let mismatchPass = "Password does not match."

let verifyEmail = "Please verify your email to continue."
let LogoutMessage = "Are you sure want to logout?"
let loginRequired = "We are sorry please login to continue"
let videoNotSaved = "Video can not be saved in drafts. would you still wanted to save site without video?"

let emailFieldEmptyAlertMessage = "Please enter your email address."
let passwordFieldEmptyAlertMessage = "Please enter your password."
let invalidEmailAlertMessage = "Invalid email address."
let nameFieldEmptyAlertMessage = "Please enter your Name."
let confirmPasswordEmptyAlert = "Please enter confirm password."
let previousPasswordMatchAlert = "Please enter previous password."
let newPasswordMatchAlert = "Please enter new password."
let locationAlertMessage = "Please enter new location."
let PreviouspasswordFieldEmptyAlertMessage = "Please enter previous password."

let prePasswordLengthAlert = "Previous password length must be greater than 8."
let newPasswordLengthAlert = "New password length must be greater than 8."

let notificationDeleteMessage = " Are you want to delete message."

let apiNoRecordMsg = "No Record Found"
let msgToShowIfNoRecord = "We are unable to find records, please try search campsites"
let noCampAtLoc = "We are unable to find any camps on your location, please try search campsites"
let passMismatch = "Password Mismatch"
let showOnPassMismatch = "Please check the password and try again"

//MARK:- Add review alert messages
let dateOfStayAlert = "Please select date of stay."
let lenghtOfStay = "Please enter length of days of stay."
let scenicAlert = "please rate scenic beauty."
let locationAlert1 = "please rate location."
let familyFriendAlert = "please rate family friendly."
let privacyAlert = "please rate privacy."
let cleanlinessAlert = "Please rate cleanliness."
let bugFactorAlert = "please rate bug factor."
let descriptionAlert1 = "please enter description."
let addtipAlert = "please enter tip."
let reviewAdded = "Your review added successfully."



//MARK:- Publish
let emptyPublishFieldAlert = "We are sorry, seems some field are empty."

// MARK: appDelegate reference
let applicationDelegate = UIApplication.shared.delegate as! (AppDelegate)

//App Delegate Class
let userDefault = UserDefaults.standard

//MARK:- MyLongi latti
var userLocation: CLLocation!
var myCurrentLongitude: Double = 0.0
var myCurrentLatitude: Double = 0.0
var countryOnMyCurrentLatLong: String = ""

// MARK: showAlert Function
struct login
{
    static let USER_DEFAULT_LOGIN_CHECK_Key = "islogin"
}

func showAlert (_ reference:UIViewController, message:String, title:String){
    var alert = UIAlertController()
    if title == "" {
        alert = UIAlertController(title: nil, message: message,preferredStyle: UIAlertControllerStyle.alert)
    }
    else{
        alert = UIAlertController(title: title, message: message,preferredStyle: UIAlertControllerStyle.alert)
    }
    
    alert.addAction(UIAlertAction(title: okBtnTitle, style: UIAlertActionStyle.default, handler: nil))
    reference.present(alert, animated: true, completion: nil)
}

let tableViewSwipeButtonBlock1 = { (button: UIButton!,subview: UIView?) -> Void in

    let deleteButtonView: UIView? = (subview)
    var buttonFrame: CGRect? = deleteButtonView?.frame
    deleteButtonView?.backgroundColor = UIColor.white
    deleteButtonView?.layer.cornerRadius = 6
    buttonFrame?.origin.x = (deleteButtonView?.frame.origin.x)!
    buttonFrame?.origin.y = ((deleteButtonView?.frame.origin.y)!+CGFloat(5))
    buttonFrame?.size.width = (deleteButtonView?.frame.size.width)! + 10
    buttonFrame?.size.height = (deleteButtonView?.frame.size.height)!-CGFloat(10)
    button.backgroundColor = UIColor.clear
    button.setImage(UIImage(named: "DelteButton"), for: .normal)
    button?.frame = buttonFrame!
}

//////////////////////////////////////////////
//baseUrl
//let baseURL: String = "https://clientstagingdev.com/explorecampsite/api/"
//https://mobapps.explorecampsites.com/api
let baseURL: String = "https://mobapps.explorecampsites.com/api/"

let objUser = UserData()

let Storyboard = UIStoryboard(name: "Main", bundle: nil)

//ap delecgate
let facbookLogin = "FacbookLogin"
let gmailLogin = "GmailLogin"
let appleLogin = "AppleLogin"

//apple String
let appleUserId: String = "apple user id"
let appleuserName: String = "apple user name"
let appleUserEmail: String = "apple user email"

//messages
let addChangesAlert = "Please add changes."
let NoImageAlert = "Please select Image to add."
let areYouSure = "Are you sure?"
let Ok = "Ok"
let logoutbtn = "Logout"
let Update = "Update"
let Add = "ADD"

let oneVidOnly = "You can upload one video for each campsite."
let upoadOnly5 = "You can post only 5 images for each review."
let upoadOnly5Camp = "You can post only 5 images for each campsite."
let logoutAlert = "Are you sure want to logout from the app?"

let cancel = "Cancel"
let ChooseImage = "Choose Image"
let noCamera = "You don't have camera."
let sureALert = "Are you sure you want to delete?"

let sureClearSingleNoti = "Are you sure you want to clear the notification?"
let sureClearNoti = "Are you sure you want to clear the notifications?"
let delete: String = "Delete"

let updatedAlert = "Info updated successfully."
let success: String = "Success"

//store image locally
var userChosenImage : UIImage?

/////
var unreadMessageCount: Int = 0
var fromNotification: Bool = false
var backBtnPressedForPublished: Bool = false

//let noInternet = "Your internet connection seems to be offline, please check"

let noInternet = "You seems to be offline, please check your internet connection."
let serverError = "Somthing went wrong, please try again in sometimes."
let DeleteAlert = "Are you sure you want to delete?"
let errorInAppleLigin = "Error in getting AppleId."
let NoEmailinAppleId = "Unable to login, your AppleId does not have email"

let deviceType = "iOS"
let facebookEmailNotExist = "Email-Id not found."
let yesBtnTitle = "Yes"

//edit profile
let dobDayAlert = "Please 2222 valid day."
let dobMonthAlert = "Please enter your month between 01 to 12."
let dobYearAlert = "Please enter your year of your birth."
let locationAlert = "Please enter your location."
let mobileAlert = "Please enter your phone number."
let descriptionAlert = "Please enter description."
let ProfileUpdateAlert = "Profile updated successfully."

//MARK:- Reset Password
let changeSuccessfully = "Your password has been changed successfully."
let enteredPreviousPasswordNotMatched = "Your entered previous password not matched."

//MARK:- Forgot pass
let passwordSendToEmail = "Your request processed successfully, please check your email."

//MARK:- Userdefault
let XPIsUserLoggedIn = "IsUserLoggedIn"
let XPemailAddress = "userEmail"
let XPname = "name"
let XPprofileImage = "profileImage"
let XPcontactNum = "ContactNum"
let XPuserId = "userId"
let XPisPushNotificationsEnabled = "isPushNotificationsEnabled"
let XPisPaid = "isPaid"
let XPLoginStatus = "loginStatus"

var fromSaveDraft: Bool = false
var fromFavourites: Bool = false



//////////////Data persistence///////////////
let homeFeaturesStr = "homeFeatureCampStr"
let homeReviewBasedStr = "homeReviewBasedCampStr"
let myCurrentLocStr = "currentLocStr"

let featuredViewAll = "featuredViewAll"
let reviewViewAllStr = "reviewViewAllStr"
let viewAllCamps = "viewAllCamps"

let fromProfile = "loginFromProfile"
let fromNearByuser = "loginFromNearByUser"
let fromTopBar = "loginFromTopBar"
let fromAddCamps = "loginFromAddCamps"
let fromNoti = "loginFromNotifications"
let fromSearch = "loginFromSearch"
let fromFavCamps = "loginFromMakeFav"
let fromRevFavCamp = "loginFromMakeRevFav"
let favIndex = "favIndexVal"
let fromCampDes = "ForCampDescription"
let fromViewProfile = "ForViewProfile"
let campDescription = "ForCampDescription"
let featuredCamp = "ForFeaturedCamp"

let favouritesCampsStr = "featuredCampStr"
let myCampsStr = "myCampsStr"
let myProfileStr = "myProfileStr"
let settingStr = "settings"
let notificationListingStr = "notificationListingStr"
let chatListStr = "chatListStr"

//google ads
let GADAdsUnitIdInterstitial = "ca-app-pub-3940256099942544/4411468910"
