//
//  ViewController.swift
//  SaymDay
//
//  Created by Apple on 14/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import SwiftMessages
import AuthenticationServices
import SwiftKeychainWrapper

class LoginVC: UIViewController {
    
    @IBOutlet weak var btn_SignUp: UIButton!
     @IBOutlet weak var btn_AppleSignIn: UIButton!
    @IBOutlet weak var txt_Email: CustomTextField!
    @IBOutlet weak var txt_Password: CustomTextField!
    
    var loginViewModel = LoginVM()
    
    override func viewDidLoad() {

        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.btn_AppleSignIn.isHidden = false
        } else {
            self.btn_AppleSignIn.isHidden = true
        }
        
        self.btn_SignUp.setAttributedTitle(loginViewModel.setSignUpButtonAttributtedTitle(), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBar.isHidden = true
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    @IBAction func btn_Login(_ sender: Any) {
        self.view.endEditing(true)
        
        if txt_Email.trim() == "" {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_EMPTY_EMAIL.rawValue.localized)
        }
        else if !isValidEmail(testStr: txt_Email.trim())
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_EMAIL.rawValue.localized)
        }
        else if txt_Password.trim() == ""
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.EMPTY_PASSWORD.rawValue.localized)
        }
        else if txt_Password.trim().count < 6
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_PASSWORD.rawValue.localized)
        }
        else
        {
            self.login(password: txt_Password.text!, email: txt_Email.text!)
        }
    }
    
    @IBAction func btn_FacebookLogin(_ sender: Any) {
        socialMediaAPI.fbLoginManager(vc: self) { (fbDetails) in
            let dict = fbDetails
            
            self.socialLogin(name: dict.value(forKey: "name") as! String, email: dict.value(forKey: "email") as! String, facebookLogin: true, facebookId: dict.value(forKey: "id") as! String, googleLogin: false, googleId: "", AppleLogin: false, AppleId: "")
        }
    }
    
    @IBAction func btn_GoogleLogin(_ sender: Any) {
        socialMediaAPI.googleAPIDelegate = self
        socialMediaAPI.googleSignIn()
    }
    
     @IBAction func btn_Apple_Login_Tapped(_ sender: Any) {
            if #available(iOS 13.0, *) {
    //            performExistingAccountSetupFlows()
                self.handleAuthorizationAppleIDButtonPress()
            } else {
                // Fallback on earlier versions
            }
        }
    
    @IBAction func btn_SignUp(_ sender: Any) {
        let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.REGISTER.rawValue) as! RegisterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_ForgotPassword(_ sender: Any) {
        let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.FORGOT_PASSWORD.rawValue) as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginVC: GoogleAPIDelegate{
    func getGooleUserDetails(user: GIDGoogleUser) {
        
        self.socialLogin(name: user.profile.name!, email: user.profile.email!, facebookLogin: false, facebookId: "", googleLogin: true, googleId: user.userID!, AppleLogin: false, AppleId: "")
    }
    
    
}

// Mark - Login APIs
extension LoginVC {
    func socialLogin(name: String, email: String, facebookLogin: Bool, facebookId: String, googleLogin: Bool, googleId: String, AppleLogin: Bool, AppleId: String) {
        
        loginViewModel.socialLogin(name: name, email: email, facebookLogin: facebookLogin, facebookId: "", googleLogin: googleLogin, googleId: googleId, AppleLogin: AppleLogin, AppleId: AppleId, viewController: self) { (loginModel,message,status) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            if status != "500" {
                
                // Firebase Event
//                AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.SOCIAL_LOGIN.rawValue)
                
                self.loginViewModel.setDefaultValues(loginModel)
                
                let vc = STORYBOARD.DASHBOARD.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.DASHBOARD.rawValue) as! DashBoardVC
                CommonMethods.setIsSocialLogin(value: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func login(password: String, email: String) {
        loginViewModel.login(password:password, email:email, viewController: self){ (loginModel,message,status) in
           
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            
                    if status != "500" {
                                                
                        self.loginViewModel.setDefaultValues(loginModel)
                        
                        let vc = STORYBOARD.DASHBOARD.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.DASHBOARD.rawValue) as! DashBoardVC
                        CommonMethods.setIsSocialLogin(value: false)
                        self.navigationController?.pushViewController(vc, animated: true)
                  
            }
        }
    }
}

@available(iOS 13.0, *)
extension LoginVC : ASAuthorizationControllerDelegate{
    
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email,.fullName]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
//        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
//                        ASAuthorizationPasswordProvider().createRequest()]
//
//        // Create an authorization controller with the given requests.
//        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
           let emailResult = KeychainWrapper.standard.string(forKey: "PicndropCustomerAppleEmail") ?? ""
            let nameResult = KeychainWrapper.standard.string(forKey: "PicndropCustomerAppleName") ?? ""
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email ?? emailResult
           let name = appleIDCredential.fullName?.givenName ?? nameResult
           
            if email != ""{
                KeychainWrapper.standard.set(email, forKey: "PicndropCustomerAppleEmail")
            }
            
           if name != ""{
               KeychainWrapper.standard.set(email, forKey: "PicndropCustomerAppleName")
           }
           
            self.socialLogin(name: name, email: email, facebookLogin: false, facebookId: "", googleLogin: false, googleId: "", AppleLogin: true, AppleId: userIdentifier)

        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
           let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
           let alertController = UIAlertController(title: "Keychain Credential Received",
                                                   message: message,
                                                   preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
           self.present(alertController, animated: true, completion: nil)
       }
       
       /// - Tag: did_complete_error
       func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
           // Handle error.
       }
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
