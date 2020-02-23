//
//  CoreDataManager.swift
//  XploreProject
//
//  Created by Dharmendra on 11/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import Foundation

class CoreDataManager: NSObject {
    static let coreDataSharedInstance = CoreDataManager()
    
     private var appDelRef: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        func saveHomeDataCompsites(responseData: JSON) {
//        let featuredCamps = responseData["featuredCampsite"]
//        let reviewCamps = responseData["reviewBased"]
            
       

//        guard let appDelRef = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
        //create context from this container
        let managedContext = appDelRef.persistentContainer.viewContext
        //now create an entity and new user records
        guard let featuredEntity = NSEntityDescription.entity(forEntityName: "FeaturedEntity", in: managedContext) else { return }
        
//        for (_, subJson): (String, JSON) in responseData["featuredCampsite"] {
//            let featuredManagedObject = NSManagedObject(entity: featuredEntity, insertInto: managedContext) as! FeaturedEntity
//
//
//
//        }
        
    }
}
