//
//  CommenFunc.swift
//  Sona Circle
//
//  Created by Apple on 28/08/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MediaPlayer

class CommonFunctions: NSObject {
    
    //MARK: - Show alert
    class func showAlert (_ reference:UIViewController, message:String, title:String){
        var alert = UIAlertController()
        if title == "" {
            alert = UIAlertController(title: nil, message: message,preferredStyle: UIAlertControllerStyle.alert)
        }
        else{
            alert = UIAlertController(title: title, message: message,preferredStyle: UIAlertControllerStyle.alert)
        }
        
        alert.addAction(UIAlertAction(title: Ok, style: UIAlertActionStyle.default, handler: nil))
        reference.present(alert, animated: true, completion: nil)
        
    }
    
    class func showAlert(_ reference:UIViewController, message: String?, title:String? , otherButtons:[String:((UIAlertAction)-> ())]? = nil, cancelTitle: String = "OK", cancelAction: ((UIAlertAction)-> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction))
        
        if otherButtons != nil {
            for key in otherButtons!.keys {
                alert.addAction(UIAlertAction(title: key, style: .default, handler: otherButtons![key]))
            }
        }
        reference.present(alert, animated: true, completion: nil)
    }
  //  changeUNXTimeStampToTIme
    class func currentChangeUNXTimeStampToTIme(recUnxTimeStamp: Double, currentTimeStamp: Double) -> String {
        let unixTimestamp = recUnxTimeStamp/1000
        
        let currentTime = currentTimeStamp
        let date = Date(timeIntervalSince1970: unixTimestamp)
        
        let date1 = Date(timeIntervalSince1970: currentTime)

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = Locale(identifier: "en_US")        
      //  dateFormatter.locale = NSLocale.current

        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss z" //Specify your format that you want
        let recDateInMomentAgo = date.getElapsedInterval(recDate: date1)

        return recDateInMomentAgo
        
       // return dateFormatter.string(from: date)
        
    }
    
    class func changeUNXTimeStampToTIme(recUnxTimeStamp: Double) -> String {
        let unixTimestamp = recUnxTimeStamp/1000
        let date = Date(timeIntervalSince1970: unixTimestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = Locale(identifier: "en_US")
        //  dateFormatter.locale = NSLocale.current
        
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss z" //Specify your format that you want
        let recDateInMomentAgo = date.getElapsedInterval()
        
       // let recDateInMomentAgo = dateFormatter.string(from: date)
        
        return recDateInMomentAgo
        
    }
    
    
    class func removeAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        //print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        
    }   
}
