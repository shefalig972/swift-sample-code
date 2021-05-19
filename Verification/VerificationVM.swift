//
//  VerificationVM.swift
//  picndrop
//
//  Created by Apple on 02/03/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class VerificationVM {
    func resendVerifyNumberOTP(vc: UIViewController, completion: @escaping (String,String) -> Void) {
        vc.showIndicator()
        
        api.updatePhoneNumber(url: API_ENDPOINTS.METHOD_RESEND_MOBILE_OTP.rawValue, parameters: [:], viewController: vc) { (message,status) in
            vc.hideIndicator()
            
            completion(message,status)
        }
    }
    
    func resendEmailOTP(vc: UIViewController, completion: @escaping (String,String) -> Void){
        vc.showIndicator()

        api.updateEmail(url: API_ENDPOINTS.METHOD_RESEND_EMAIL_OTP.rawValue, parameters: [:], viewController: vc) { (message,status) in
            print(message)
            vc.hideIndicator()
            completion(message,status)
        }
    }
    
    func resendForgotPasswordOTP(email: String, vc: UIViewController, completion: @escaping (String,String,String) -> Void) {
        vc.showIndicator()
        
        let params = [
            "email" : email
            ] as [String : Any]
        
        api.forgotPassword(url: API_ENDPOINTS.METHOD_FORGOT_PASSWORD.rawValue, parameters: params, viewController: vc) { (message, status, statusCode) in
            vc.hideIndicator()
            completion(message,status,statusCode)
        }
    }
    
    
    func verifyOTP(email: String, otp: String, vc: UIViewController, completion: @escaping (String,String) -> Void) {
        vc.showIndicator()
        
        let params = [
            "email" : email,
            "otp" : otp,
            "user_role_id":3
            ] as [String : Any]
        
        api.verifyOTP(url: API_ENDPOINTS.METHOD_VERIFY_OTP.rawValue, parameters: params, viewController: vc) { (message, status) in
            vc.hideIndicator()
            completion(message,status)
        }
    }
    
    func verifyEditProfileOTP(otp: String, vc: UIViewController, completion: @escaping (String,String) -> Void) {
        vc.showIndicator()
        let params = [
            "otp" : otp
            ] as [String : Any]
        api.emailOTPVerification(url: API_ENDPOINTS.METHOD_EMAIL_OTP_VERIFICATION.rawValue, parameters: params, viewController: vc) { (message,status) in
            vc.hideIndicator()
            completion(message,status)
        }
    }
    
    func verifyMobile(otp: String, vc: UIViewController, completion: @escaping (String,String) -> Void) {
        vc.showIndicator()
        let params = [
            "otp" : otp
            ] as [String : Any]
        api.phoneOTPVerification(url: API_ENDPOINTS.METHOD_MOBILE_VERIFICATION.rawValue, parameters: params, viewController: vc) { (message,status) in
            print(message)
            vc.hideIndicator()
            completion(message,status)
        }
    }
}
