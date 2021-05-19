//
//  LoginVM.swift
//  picndrop
//
//  Created by Apple on 02/03/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class LoginVM {
    
    func setSignUpButtonAttributtedTitle() -> NSAttributedString{
        let accountStr = "Don't have an account?"
        let accountAttrs = [NSAttributedString.Key.font : UIFont(name: "Sansation-Regular", size: 18), NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)]
        
        let accountAttributedString = NSMutableAttributedString(string:"\(accountStr)", attributes:accountAttrs as [NSAttributedString.Key : Any])
        
        let signUpStr = " Sign Up"
        let signUpAttrs = [NSAttributedString.Key.font : UIFont(name: "Sansation-Bold", size: 18), NSAttributedString.Key.foregroundColor : UIColor.init(red: 15.0/255.0, green: 144.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
        
        let signUpAttributedString = NSMutableAttributedString(string:"\(signUpStr)", attributes:signUpAttrs as [NSAttributedString.Key : Any])
        
        accountAttributedString.append(signUpAttributedString)
        
        return accountAttributedString
    }
    
    func login(password: String, email: String, viewController: UIViewController, completion: @escaping (LoginModel,String,String) -> Void) {
        viewController.showIndicator()
        
        let params = [
            "user_role_id" : 3,
            "email" : email.trimmingCharacters(in: .whitespaces),
            "password" : password
            ] as [String : Any]
        
        api.login(url: API_ENDPOINTS.METHOD_LOGIN.rawValue, parameters: params, viewController: viewController) { (loginModel,message,status) in
            viewController.hideIndicator()
            completion(loginModel,message,status)
        }
    }
    
    func socialLogin(name: String, email: String, facebookLogin: Bool, facebookId: String, googleLogin: Bool, googleId: String, AppleLogin: Bool, AppleId: String, viewController: UIViewController, completion: @escaping (LoginModel,String,String) -> Void) {
        viewController.showIndicator()
        
        let params = [
            "user_role_id" : 3,
            "name" : name,
            "email" : email.trimmingCharacters(in: .whitespaces),
            "facebook_login" : facebookLogin,
            "facebook_id" : facebookId,
            "google_login" : googleLogin,
            "google_id" : googleId,
            "apple_login":AppleLogin,
            "apple_id":AppleId
            ] as [String : Any]
        
        api.socialLogin(url: API_ENDPOINTS.METHOD_SOCIAL_LOGIN.rawValue, parameters: params, viewController: viewController) { (loginModel,message,status) in
            viewController.hideIndicator()
            
            completion(loginModel,message,status)
        }
    }
    
    func setDefaultValues(_ loginModel:LoginModel) {
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.API_TOKEN.rawValue, value: loginModel.api_token!)
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_EMAIL.rawValue, value: loginModel.email ?? "")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_ID.rawValue, value: "\(loginModel.id!)")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_PHONE_NUMBER.rawValue, value: loginModel.phone ?? "")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_AREA_CODE.rawValue, value: loginModel.area_code ?? "")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_NAME.rawValue, value: loginModel.name ?? "")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_PROFILE_PIC.rawValue, value: loginModel.profile_pic ?? "")
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_TOKEN_ID.rawValue, value: "\(loginModel.user_tokens_id ?? 0)")
        
        CommonMethods.setUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_REFERRAL_CODE.rawValue, value: "\(loginModel.referral_code ?? "")")
        
        if CommonMethods.getUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_PHONE_NUMBER.rawValue) == "" || CommonMethods.getUserDefaultValue(key: USER_DEFAULTS_KEYs.USER_PHONE_NUMBER.rawValue) == nil{
            CommonMethods.setPhoneNumberPopUpShown(value: false)
        }else{
            CommonMethods.setPhoneNumberPopUpShown(value: true)
        }
    }
}
