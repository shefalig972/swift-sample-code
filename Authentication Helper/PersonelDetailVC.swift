//
//  PersonelDetailVC.swift
//  SaymDay
//
//  Created by Apple on 19/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol SocialLoginDelegate {
    func socialLogin(name: String, email: String, fbLogin: Bool, fbID : String, googleLogin: Bool, googleId: String, AppleLogin: Bool, AppleId: String)
}
class PersonelDetailVC: UIViewController {

    @IBOutlet weak var txt_Name: FloatLabelTextField!
    @IBOutlet weak var txt_Email: FloatLabelTextField!
    
    var fbDetails = NSDictionary()
    var fbLogin = false
    var googleDetails = GIDGoogleUser()
    var googleLogin = false
    
    var delegate : SocialLoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if fbLogin {
            self.txt_Name.text = (fbDetails.value(forKey: "name") as! String)
            self.txt_Email.text = (fbDetails.value(forKey: "email") as! String)
        }
        
        if googleLogin {
            self.txt_Name.text = googleDetails.profile.name
            self.txt_Email.text = googleDetails.profile.email
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func btn_DoneTapped(_ sender: Any) {
        if fbLogin {
            delegate?.socialLogin(name: fbDetails.value(forKey: "name") as! String, email: fbDetails.value(forKey: "email") as! String, fbLogin: true, fbID: fbDetails.value(forKey: "id") as! String, googleLogin: false, googleId: "", AppleLogin: false, AppleId: "")
        }
        
        if googleLogin {
            delegate?.socialLogin(name: googleDetails.profile.name, email: googleDetails.profile.email, fbLogin: false, fbID: "", googleLogin: true, googleId: googleDetails.userID, AppleLogin: false, AppleId: "")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
