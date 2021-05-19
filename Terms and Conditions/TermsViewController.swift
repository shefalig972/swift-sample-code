//
//  TermsViewController.swift
//  itryte
//
//  Created by apple on 24/04/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var ad_height: NSLayoutConstraint!
    
    var tag:Int = 0
    var titleStr = "Terms & Conditions"
    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        self.title = titleStr
        self.showIndicator()
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string:"https://www.picndrop.com/terms-and-conditions/")!))

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if tag == 1{
            self.navigationController?.navigationBar.isHidden = true
        }
    }
}
extension TermsViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideIndicator()
    }
}
