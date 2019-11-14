//
//  Singleton.swift
//  XploreProject
//
//  Created by Dharmendra on 17/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

final class Singleton {
    private init() {}
    static let sharedInstance: Singleton = Singleton()
    
    var homeFeaturesCampsArr: NSArray = []
    var homeReviewBasedCampsArr: NSArray = []
    var myCurrentLocDict: [String: Any] = [:]
    
    var favouritesCampArr: NSArray = []
    var myCampsArr: NSArray = []
    var myProfileDict: NSDictionary = [:]
    
    var notificationListingArr: NSArray = []
    var chatListArr: [[String: Any]] = []
    
}
