//
//  SplashVC.swift
//  XploreProject
//
//  Created by Dharmendra on 05/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SplashVC: UIViewController {

    let sing = Singleton.sharedInstance
    private let commonDataViewModel = CommonUseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Singleton.sharedInstance.interstitial = createAndLoadInterstitial()
        self.initializeTimer()
        
    }
    
    func initializeTimer() {
        Singleton.sharedInstance.timerAdd = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkAddsIsReady), userInfo: nil, repeats: true)
    }
    
    @objc func checkAddsIsReady() {
        CheckAndShowAdds(vc: self)
    }
    
    func checkLogin() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MytabbarControllerVc") as! MytabbarControllerVc
        self.navigationController?.pushViewController(vc, animated: false)
     }
}

extension SplashVC: GADInterstitialDelegate {
    func createAndLoadInterstitial() -> GADInterstitial {
        Singleton.sharedInstance.interstitial = GADInterstitial(adUnitID: GADAdsUnitIdInterstitial)
        Singleton.sharedInstance.interstitial.delegate = self
        Singleton.sharedInstance.interstitial.load(GADRequest())
        return Singleton.sharedInstance.interstitial
        
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
        self.checkLogin()
    }
   
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        self.checkLogin()
        Singleton.sharedInstance.interstitial = createAndLoadInterstitial()
        
    }
}
