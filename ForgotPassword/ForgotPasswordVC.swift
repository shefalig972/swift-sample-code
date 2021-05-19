//
//  ForgotPasswordVC.swift
//  SaymDay
//
//  Created by Apple on 19/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var txt_Email: FloatLabelTextField!
    
    let forgotViewModel = ForgotPasswordVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase Event
//        AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_SCREEN.rawValue, LOGEVENTS.FORGOT_PASSWORD_SCREEN.rawValue)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_SignUp(_ sender: Any) {
       if txt_Email.trim() == ""
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_EMPTY_EMAIL.rawValue.localized)
        }
        else if !isValidEmail(testStr: txt_Email.trim())
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_EMAIL.rawValue.localized)
       }else{
        forgotPassword(email: txt_Email.text!)
        }
    }
}

extension ForgotPasswordVC{
    func forgotPassword(email: String) {
        forgotViewModel.forgotPassword(email: email, viewController: self) { (message, status, statusCode) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            
                    if statusCode != "500" {
                        // Firebase Event
//                        AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.FORGOT_PASSWORD.rawValue)
                        
                        let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.VERIFICATION_CODE.rawValue) as! VerificationVC
                        vc.email = self.txt_Email.text!
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
        }
    }
}
