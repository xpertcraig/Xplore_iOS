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
    @IBOutlet weak var logoImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Singleton.sharedInstance.interstitial = createAndLoadInterstitial()
        self.initializeTimer()
        
    }
    
    func animateImgae() {
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.logoImg?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.logoImg?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        })
    }
    
    func initializeTimer() {
        Singleton.sharedInstance.timerAdd = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkAddsIsReady), userInfo: nil, repeats: true)
    }
    
    @objc func checkAddsIsReady() {
        self.animateImgae()
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
