//
//  VerificationVC.swift
//  SaymDay
//
//  Created by Apple on 20/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VerificationVC: UIViewController {
    
    @IBOutlet var lbl_Code: [UILabel]!
    var lastLblTag = 0
    var otp = ""
    var email = ""
    var phoneNumber = ""
    var password = ""
    var areaCode = ""
    
    var isEditingProfile = false
    var isVerifyingMobile = false
    
    let viewModel = VerificationVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase Event
//        AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_SCREEN.rawValue, LOGEVENTS.VERIFY_PHONE_NUMBER_SCREEN.rawValue)
        
    }
    
    @IBAction func resendCode_TApped(_ sender: Any) {
        if isVerifyingMobile{
            self.resendVerifyNumberOTP()
        }else{
            if isEditingProfile{
                self.resendEmailOTP()
            }else {
                self.resendForgotPasswordOTP()
            }
        }
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_KeyBoard(_ sender: UIButton) {
        switch sender.tag {
        case 1,2,3,4,5,6,7,8,9,0:
            for label in lbl_Code {
                if label.text == "-"{
                    label.text = "\(sender.tag)"
                    self.lastLblTag = label.tag
                    if label.text != "-"{
                        otp.append(label.text!)
                        print("OTP generating = \(otp)")
                    }
                    
                    if label.tag == 6{
                        if isVerifyingMobile{
                            self.verifyMobile()
                        }else{
                            if isEditingProfile{
                                self.verifyEditProfileOTP()
                            }else {
                                self.verifyOTP()
                            }
                        }
                    }
                    break
                }
            }
        case 10:
            for label in lbl_Code {
                if label.tag == self.lastLblTag && label.text != "-"{
                    otp = String(otp.dropLast())
                    label.text = "-"
                    self.lastLblTag -= 1
                    print("OTP removing = \(otp)")
                    break
                }
            }
            break
        default:
            break
        }
    }
}

extension VerificationVC{
    func verifyOTP() {
        viewModel.verifyOTP(email: email.trimmingCharacters(in: .whitespaces), otp: otp, vc: self) { (message, status) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
                if  status == "200"{
                    
                    // Firebase Event
//                    AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.VERIFY_EMAIL_OTP.rawValue)
                    
                    let vc = STORYBOARD.PROFILE.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.CHANGE_PASSWORD.rawValue) as! ChangePasswordVC
                    vc.email = self.email
                    self.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
    
    func verifyEditProfileOTP() {
        viewModel.verifyEditProfileOTP(otp: otp, vc: self) { (message,status) in
            self.hideIndicator()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
                if  status != "500"{
                    
                    // Firebase Event
//                    AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.VERIFY_PROFILE_OTP.rawValue)
                    
                        api.gotoLogin()
                }
        }
    }
    
    func verifyMobile() {
        viewModel.verifyMobile(otp: otp, vc: self) { (message,status) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            
                if status != "500"{
                    // Firebase Event
//                    AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.VERIFY_MOBILE_OTP.rawValue)
                    
                        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_PHONE_NUMBER.rawValue, value: self.phoneNumber)
                    CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_AREA_CODE.rawValue, value: self.areaCode )
                        let vc = STORYBOARD.DASHBOARD.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.DASHBOARD.rawValue) as! DashBoardVC
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                }
        }
    }
}

extension VerificationVC {
    func resendEmailOTP(){
        viewModel.resendEmailOTP(vc: self) { (message,status) in
            self.showSuccessToastOnWindow(message: message) { (_) in
            }
        }
    }
    
    func resendForgotPasswordOTP() {
        viewModel.resendForgotPasswordOTP(email: email.trimmingCharacters(in: .whitespaces), vc: self) { (message, status, statusCode) in
            
            // Firebase Event
//            AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.RESEND_PASSWORD_OTP.rawValue)
            
            self.showSuccessToastOnWindow(message: message) { (_) in
            }
        }
    }
    
    func resendVerifyNumberOTP() {
        
        viewModel.resendVerifyNumberOTP(vc: self) { (message,status) in
            // Firebase Event
//            AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.RESEND_PHONE_NUMBER_OTP.rawValue)
            
            self.showSuccessToastOnWindow(message: message) { (_) in
               
            }
        }
    }
}
