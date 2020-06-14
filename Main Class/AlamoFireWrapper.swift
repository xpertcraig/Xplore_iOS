//
//  AlamofireWrapper.swift
//  AlamofireDemo2
//
//  Created by iMark_IOS on 31/05/18.
//  Copyright © 2018 iMark_IOS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseStorage
class WebServices: NSObject
{
    //MARK:- Upload Media on FireBase
    class func uploadMedia(filename:String, uploadImage: UIImage, completion: @escaping (_ url: String?) -> Void)
    {
        
        let storageRef = Storage.storage().reference().child(filename)
        if let uploadData = UIImagePNGRepresentation(uploadImage)
        {
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil
                {
                  //  print((error?.localizedDescription)!)
                    completion(nil)
                }
                else
                {
                    //completion(metaData.abs)
                   // completion(metaData?.downloadURL()?.absoluteString)
                }
            })
        }
    }
}
protocol LoginServiceAlamofire:class {
    func LoginResults(receivedDict: NSDictionary)
    func LoginError()
}

protocol quickBloxRegisterServiceAlamofire {
    func quickBloxRegisterResult(_ result:AnyObject)
    func quickBloxRegisterError()
}
protocol getQuickBloxUserServiceAlamofire {
    func getQuickBloxUserResult(dictionaryContent:AnyObject)
    func getQuickBloxUserError()
}

class connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
        
    }
}

let timeOutInterval:Double = 60
var quickBloxRegisterDelegate:quickBloxRegisterServiceAlamofire?

class AlamoFireWrapper: NSObject {
    class var sharedInstance: AlamoFireWrapper{
        struct Singleton{
            static let instance = AlamoFireWrapper()
        }
        return Singleton.instance
    }
    
    let customManager = Alamofire.SessionManager.default
    let setIndicatorTimeInterval:Double = 60
    
    //MARK:- get Api
    func getOnlyApi(action:String, onSuccess: @escaping(DataResponse<Any>) -> Void, onFailure: @escaping(Error) -> Void){
        
        let url : String = baseURL + action
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    //   print("response = ",response.result.value!)
                    onSuccess(response)
                    
                }
                break
            case .failure(_):
                onFailure(response.result.error!)
                   print("error",response.result.error!)
                break
                
            }
        }
    }
    
    func getOnlyApiForGooglePlace(action:String, onSuccess: @escaping(DataResponse<Any>) -> Void, onFailure: @escaping(Error) -> Void){
        
        let url : String =  action
        
        print(url)
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        print(url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    //   print("response = ",response.result.value!)
                    onSuccess(response)
                    
                }
                break
            case .failure(_):
                onFailure(response.result.error!)
                //   print("error",response.result.error!)
                break
                
            }
        }
    }
    
    //MARK:- Post Api
    func getPost(action:String,param: [String:Any], onSuccess: @escaping(DataResponse<Any>) -> Void, onFailure: @escaping(Error) -> Void){
        
        let url : String = baseURL + action
        print(url)
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    //   print("response = ",response.result.value!)
                    onSuccess(response)
                    
                }
                break
            case .failure(_):
                onFailure(response.result.error!)
                //    print("error",response.result.error!)
                break
                
            }
        }
    }
    
    //MARK: MULTIPART API
    func getPostMultipart(action:String,param: [String:Any],imageData: Data?, onSuccess: @escaping(DataResponse<Any>) -> Void, onFailure: @escaping(Error) -> Void){
        
        print(baseURL+action)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                
            }
            if imageData != nil {
                if let data = imageData{
                    multipartFormData.append(data, withName: "profilePic", fileName: "profile_pic.jpeg", mimeType: "image/png")
                                        
                }
            }
            
        }, to: baseURL+action)
            
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //  print(progress)
                })
                upload.responseJSON { DataResponse in
                    
                    if DataResponse.result.value != nil {
                        onSuccess(DataResponse)
                    }
                    else
                    {
                        onFailure(DataResponse.result.error!)
                        
                        print(DataResponse.result.error!)
                        
                    }
                }
            case .failure(_):
                //onFailure(result as! Error)
                break
            }
        }
    }
    
    //MARK:- Upload document
    func getPostMultipartForUploadMultipleImages(action:String,param: [String:Any],ImageArr: NSArray, videoData: Data?, videoIndex: Int , onSuccess: @escaping(DataResponse<Any>) -> Void, onFailure: @escaping(Error) -> Void){
        print(baseURL + action)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                
            }
            for i in 0..<ImageArr.count {
                if i != videoIndex {
                    if let imageData = (ImageArr.object(at: i) as? UIImage)?.jpeg(.lowest) {
                        multipartFormData.append(imageData, withName: "image" + String(describing: (i)), fileName: "image.jpeg", mimeType: "image/png")
                        
                    }
                }
            }
            
            if videoData != nil {
                multipartFormData.append(videoData!, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
                
            }
        }, to: baseURL+action)
            
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
           //          print(progress)
                })
                upload.responseJSON { DataResponse in
                    upload.validate(contentType: ["application/json"])
                    if DataResponse.result.value != nil {
                       // print(DataResponse.result.value)
                        onSuccess(DataResponse)
                    }
                    else
                    {
                        print(DataResponse.result.error)
                        onFailure(DataResponse.result.error!)
                    }
                }
            case .failure(_):
                //onFailure(result as! Error)
                print(result as! Error)
                break
            }
        }
    }
    
    //Mark- resigter quickblox
    func registerQuickBloxUser(_ parameters:[String : Any]) {
    //    print(parameters)
        customManager.session.configuration.timeoutIntervalForRequest = timeOutInterval
        customManager.request(baseURL+"updateBloxId.php", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            if response.result.isFailure{
                quickBloxRegisterDelegate?.quickBloxRegisterError()
            }
            else{
                if let JSON = response.result.value {
          //          print(JSON)
                    quickBloxRegisterDelegate?.quickBloxRegisterResult(JSON as AnyObject)
                }
                else {
                    quickBloxRegisterDelegate?.quickBloxRegisterError()
                }
            }
        }
    }
    
    var getQuickBloxUserDelegate:getQuickBloxUserServiceAlamofire?
    
    //Mark- QuickBlox Api
    func getQuickbloxUser(_ parameters:[String : Any]){
      //  print(parameters)
        
        customManager.session.configuration.timeoutIntervalForRequest = timeOutInterval
        customManager.request(baseURL+"getObUser", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result){
            case .success(_):
                if response.result.value != nil{
              //      print("get QB user response = ",response.result.value!)
                    let dataDict: NSDictionary = response.result.value as! NSDictionary
                    
                    self.getQuickBloxUserDelegate?.getQuickBloxUserResult(dictionaryContent: dataDict)
                }
                else {
                    self.getQuickBloxUserDelegate?.getQuickBloxUserError()
                }
                break
            case .failure(_):
                self.getQuickBloxUserDelegate?.getQuickBloxUserError()
                print("Get QB user error",response.result.error!)
                break
            }
        }
    }
    
    
}
