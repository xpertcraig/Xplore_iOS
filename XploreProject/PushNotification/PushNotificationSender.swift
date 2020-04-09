//
//  PushNotificationSender.swift
//  XploreProject
//
//  Created by Dharmendra on 07/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, userId: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token, "priority": "high",  "notification" : ["title" : title, "body" : body, "type": "chatMessage"], "data" : ["user" : userId]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //request.setValue("key=AAAApGSLQJc:APA91bG-ibWUznAImUmsdmJG6NsZVXy8KgGazESfVwSRXx3xT9Zw060Jdp6wOlB7konATcugJX2Oje1PaELf3HplGf1SsQE-QiAw0Gl4VnPCfwzT0woK3P_RzT3ehGSFbgafJUw-RYG3", forHTTPHeaderField: "Authorization")
        
        request.setValue("key=AAAAWyaoAvY:APA91bFWqrqKhzUx6d6ds_wWO6akwVoiw2xW0atky-f9pKe-DWixbohx6ZgvQXaq6vDm2rQ941KchwRE503CDml-Er5WzLIPo-Dcb3p3iIFz3PFCs67ehAplAdZbJNtfajvzL3oHlbRC", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
