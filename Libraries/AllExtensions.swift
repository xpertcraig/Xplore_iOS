//
//  ViewShadow.swift
//  Voip
//
//  Created by iMark_IOS on 22/05/18.
//  Copyright © 2018 iMark_IOS. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreLocation
import SDWebImage

class AllExtensions: UIViewController {
    
}

extension UINavigationController {

    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParentViewController()
        }
    }
}

//MARK:- UiViewController
extension UIViewController {
    func loginAlertFunc(vc: String, viewController: UIViewController) {
        let alert = UIAlertController(title: appName, message: loginRequired, preferredStyle: .alert)
        let yesBtn = UIAlertAction(title: Ok, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
            if vc == "profile" {
                Singleton.sharedInstance.loginComeFrom = fromProfile
                
            } else if vc == "nearByUser" {
                Singleton.sharedInstance.loginComeFrom = fromNearByuser
               
            } else if vc == "addCamps" {
                Singleton.sharedInstance.loginComeFrom = fromAddCamps
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromNoti
                
            } else if vc == "fromNoti" {
                Singleton.sharedInstance.loginComeFrom = fromFavCamps
                
            } else if vc == "viewProfile" {
                Singleton.sharedInstance.loginComeFrom = fromViewProfile
                
            }  else if vc == "campDescription" {
                Singleton.sharedInstance.loginComeFrom = campDescription
               
           }
            self.navigationController?.pushViewController(controller, animated: false)
        })
        
        let noBtn = UIAlertAction(title: cancel, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(yesBtn)
        alert.addAction(noBtn)
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "E d MMM"
        return  dateFormatter.string(from: date!)
        
    }
    
    func convertNotiDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFrom = dateFormatter.date(from: date)
       
        let dateStr = dateFrom?.getElapsedInterval()
        
        return  dateStr!
        
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func getLocationStateName(locationRec: CLLocation) -> String {
        var state: String = ""
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationRec) { (placemarksArray, error) in
            if placemarksArray != nil {
                if (placemarksArray?.count)! > 0 {
                    let placemark = placemarksArray?.first
                    
                    state = (placemark?.addressDictionary!["State"]) as! String
                    
                } else {
                    //                        print(placemark?.addressDictionary)
                    //                        print(placemark?.addressDictionary!["State"])
                    //                        print(placemark?.country)
                    //                        print(placemark?.locality)
                    //                        print(placemark?.location)
                    //                        print(placemark?.region)
                    //                        print(placemark?.subAdministrativeArea)
                    //                        print(placemark?.subLocality)
                    //                        print(placemark?.subThoroughfare)
                    //                        print(placemark?.thoroughfare)
                    //                        print(placemark?.ocean)
                    
                }
            }
        }        
        
        return state
        
        }
    
    func currency(recStr: String) -> String? {
        let firstTwoLtr = String(recStr.prefix(2))
        let code = Locale.currency[firstTwoLtr.uppercased()]
        
        if code == nil {
            let sepStr = recStr.components(separatedBy: " ")
           // print(sepStr)
            if sepStr.count == 2 {
                if sepStr[0] != "" {
                    if sepStr[1] != "" {
                        let code = Locale.currency["\(String(describing: sepStr[0].first!))\(String(describing: sepStr[1].first!))"]
                        
                        return code?.code
                    }
                }
            } else if sepStr.count == 1 {
                if sepStr[0] != "" {
                    let code = Locale.currency["\(String(describing: sepStr[0].first!))"]
                    return code?.code
                   
                }
            } else if sepStr.count == 0 {
                return ""
                
            } else if sepStr.count > 2 {
                if sepStr[0] != "" {
                    if sepStr[1] != "" {
                        if sepStr[2] != "" {
                            let code = Locale.currency["\(String(describing: sepStr[0].first!))\(String(describing: sepStr[1].first!))\(String(describing: sepStr[2].first!))"]
                            
                            return code?.code
                            
                        }
                    }
                }
            }
        }
        
        return code?.code
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-120, width: self.view.frame.width-40, height: 40))
        toastLabel.numberOfLines = 2
        toastLabel.backgroundColor = UIColor.appThemeKesariColor()
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        toastLabel.alpha = 0.5
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 1.0
        }, completion: {(isCompleted) in
            UIView.animate(withDuration: 5.0, delay: 0.4, options: .curveEaseOut, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        })
    }
}


extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInKb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInKb * 1024 //* 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = UIImageJPEGRepresentation(self, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
     //   print(sizeInBytes)
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}

extension Locale {
    static let currency: [String: (code: String?, symbol: String?)] = Locale.isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol)
    }
}

extension Locale {
    func isoCode(for countryName: String) -> String? {
        return Locale.isoRegionCodes.first(where: { (code) -> Bool in
            localizedString(forRegionCode: code)?.compare(countryName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        })
    }
}


//MARK:- Uiimage
extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 1)   // QUALITY min = 0 / max = 1
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

//MARK:- Uiimage View
extension UIImageView{
    func setImageFromURl(stringImageUrl url: String){
        if let url = NSURL(string: url) {
            DispatchQueue.global(qos: .default).async{
                if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data as Data)
                    }
                }
            }
        }
    }
    func loadImageFromUrl(urlString: String, placeHolderImg: String, contenMode: ContentMode, completion: @escaping ( _ rMsg: Bool) -> Void)  {
        if let imageFromCache = Singleton.sharedInstance.imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = imageFromCache
            if imageFromCache != UIImage(named: "PlaceHolder") {
                self.contentMode = contenMode
                completion(true)
            } else {
                completion(false)
            }
            return
        }

        var foodImageURL: NSURL?
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
             let url = URL(string: encoded){
                 print(url)
                 foodImageURL = url as NSURL
         } else {
             foodImageURL = NSURL(string: urlString)
         }
       
        // self.contentMode = .scaleAspectFit
         self.sd_setImage(with: foodImageURL as URL?, placeholderImage: UIImage(named: placeHolderImg),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
          // Perform operation.
            if let imageToCache = self.image{
                Singleton.sharedInstance.imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                self.image = imageToCache
                
                if imageToCache != UIImage(named: "PlaceHolder") {
                    self.contentMode = contenMode
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
         })
    }
}

extension String {
    func isValidEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    func getImageHeightWidth() -> (Double, Double) {
        var imageHeader: [String: Any] = [:]
    
        let imageURL = URL(string: self)!
        let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil)
        imageHeader =  CGImageSourceCopyPropertiesAtIndex(source!, 0, nil)! as! [String : Any]
        print("Image header: \(imageHeader)")
            
        
        let width = Double(String(describing: (imageHeader["PixelWidth"])!))
        let height = Double(String(describing: (imageHeader["PixelHeight"])!))
        
        return (width!, height!)
    }
}

extension Date {
    
    func getElapsedInterval() -> String {
        var interval = Calendar.current.dateComponents([.year], from: self, to: Date()).year!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " year ago" : "\(interval)" + " years ago"
        }
        interval = Calendar.current.dateComponents([.month], from: self, to: Date()).month!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " month ago" : "\(interval)" + " months ago"
        }
        
        interval = Calendar.current.dateComponents([.day], from: self, to: Date()).day!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " day ago" : "\(interval)" + " days ago"
        }
        
        interval = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " hour ago" : "\(interval)" + " hours ago"
        }
        
        interval = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " min ago" : "\(interval)" + " mins ago"
        }
        
        return "a moment ago"
        
    }
    
    func getElapsedInterval(recDate: Date) -> String {
        var interval = Calendar.current.dateComponents([.year], from: self, to: recDate).year!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " year ago" : "\(interval)" + " years ago"
        }
        interval = Calendar.current.dateComponents([.month], from: self, to: recDate).month!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " month ago" : "\(interval)" + " months ago"
        }
        
        interval = Calendar.current.dateComponents([.day], from: self, to: recDate).day!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " day ago" : "\(interval)" + " days ago"
        }
        
        interval = Calendar.current.dateComponents([.hour], from: self, to: recDate).hour!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " hour ago" : "\(interval)" + " hours ago"
        }
        
        interval = Calendar.current.dateComponents([.minute], from: self, to: recDate).minute!
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " minute ago" : "\(interval)" + " minutes ago"
        }
        
        return "a moment ago"
        
    }
    
    func offsetFrom(date : Date) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day > 0 {
            return days
            
        }
        if let hour = difference.hour, hour > 0 {
            return hours
            
        }
        if let minute = difference.minute, minute > 0 {
            return minutes
            
        }
        if let second = difference.second, second > 0 {
            return seconds
            
        }
        return ""
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

extension UIImage {

    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(self)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image)! as NSData
        return data1.isEqual(data2)
    }

}

extension UIView {
    
    func animShow(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}

extension UIColor{
    class func appThemeKesariColor() -> UIColor {
        return UIColor(red:234/255 , green:102/255 ,blue:7/255 , alpha:1.00)
    }
    class func appThemeGreenColor() -> UIColor {
        return UIColor(red:0/255 , green:109/255 ,blue:105/255 , alpha:1.00)
    }
    
    class func lightBlackColor() -> UIColor {
        return UIColor(red:223/255 , green:223/255 ,blue:223/255 , alpha:1.0)
    }
    
    class func darkBlackColor() -> UIColor {
        return UIColor(red:46/255 , green:46/255 ,blue:46/255 , alpha:1.0)
    }
}


extension UIView{
func customActivityIndicator(view: UIView, widthView: CGFloat?,backgroundColor: UIColor?, textColor:UIColor?, message: String?) -> UIView{

    //Config UIView
    self.backgroundColor = backgroundColor //Background color of your view which you want to set

    var selfWidth = view.frame.width
    if widthView != nil{
        selfWidth = widthView ?? selfWidth
    }

    let selfHeigh = view.frame.height
    let loopImages = UIImageView()

    let imageListArray = [UIImage(named: "Logo")!, UIImage(named: "Nearby")!] // Put your desired array of images in a specific order the way you want to display animation.

    loopImages.animationImages = imageListArray
    loopImages.animationDuration = TimeInterval(0.8)
    loopImages.startAnimating()

    let imageFrameX = (selfWidth / 2) - 60
    let imageFrameY = (selfHeigh / 2) - 60
    var imageWidth = CGFloat(120)
    var imageHeight = CGFloat(62)

    if widthView != nil{
        imageWidth = widthView ?? imageWidth
        imageHeight = widthView ?? imageHeight
    }

    //ConfigureLabel
    let label = UILabel()
    label.textAlignment = .center
    label.textColor = .gray
    label.font = UIFont(name: "Nunito-Regular", size: 17.0)! // Your Desired UIFont Style and Size
    label.numberOfLines = 0
    label.text = message ?? ""
    label.textColor = textColor ?? UIColor.clear

    //Config frame of label
    let labelFrameX = (selfWidth / 2) - 60
    let labelFrameY = (selfHeigh / 2) + 10
    let labelWidth = CGFloat(120)
    let labelHeight = CGFloat(21)

    // Define UIView frame
    //self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)

    self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height)

    //ImageFrame
    loopImages.frame = CGRect(x: imageFrameX, y: imageFrameY, width: imageWidth, height: imageHeight)

    loopImages.backgroundColor = UIColor.white
    //LabelFrame
    label.frame = CGRect(x: labelFrameX, y: labelFrameY, width: labelWidth, height: labelHeight)

    label.backgroundColor = UIColor.white
    //add loading and label to customView
    self.addSubview(loopImages)
    self.addSubview(label)
    return self
    
    }
}

enum GradientDirection {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}

extension UIView {
    func gradientBackground(from color1: UIColor, to color2: UIColor, to color3: UIColor, to color4: UIColor,to color5: UIColor  , direction: GradientDirection) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.frame.size.width  = self.frame.size.width + 50
       // gradient.frame.size.height  = self.frame.size.height + 20
        
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor, color4.cgColor,color5.cgColor]

        switch direction {
            case .topToBottom:
                gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .bottomToTop:
            gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
            
        default:
            break
        }

        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
