//
//  WebkitVC.swift
//  Maknow
//
//  Created by Dharmendra on 12/07/20.
//  Copyright © 2020 Maknow. All rights reserved.
//

import UIKit
import WebKit

class WebkitVC: UIViewController, WKNavigationDelegate {

    //MARK:- Iboutlets
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var showWkWebView: WKWebView!
    
    //MARK:- Variable Declaraions
    var urlString: String = webViewUrlString.privacyPolicy.rawValue
    
    //MARK:- Inbuilt Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTitle()
        applicationDelegate.startProgressView(view: self.view)
        
        self.showWkWebView.navigationDelegate = self
        let url:URL = URL(string: urlString)!
        let urlRequest:URLRequest = URLRequest(url: url)
        self.showWkWebView.load(urlRequest)
    }

    //MARK:- Function Definitions
    func setTitle() {
        if urlString == webViewUrlString.privacyPolicy.rawValue {
            self.titleLbl.text! = webViewTitleString.privacyPolicy.rawValue
        } else if urlString == webViewUrlString.terms.rawValue {
            self.titleLbl.text! = webViewTitleString.terms.rawValue
        } else {
            self.titleLbl.text! = webViewTitleString.aboutUs.rawValue
        }
    }
    
    //MARK:- Button Action
    @IBAction func tapBackBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension WebkitVC {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
        applicationDelegate.dismissProgressView(view: self.view)
        CommonFunctions.showAlert(self, message: error.localizedDescription, title: appName)
    }


    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
       // applicationDelegate.startProgressView(view: self.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        applicationDelegate.dismissProgressView(view: self.view)
    }
    
    func webView(_ webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("finish to load")
        applicationDelegate.dismissProgressView(view: self.view)
    }
}
