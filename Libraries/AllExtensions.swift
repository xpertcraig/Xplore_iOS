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
        animation.duration = 0.4
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
