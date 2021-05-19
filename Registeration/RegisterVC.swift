//
//  RegisterVCViewController.swift
//  SaymDay
//
//  Created by Apple on 18/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import SwiftKeychainWrapper

class RegisterVC: UIViewController {
    
    @IBOutlet weak var txt_Name: FloatLabelTextField!
    @IBOutlet weak var txt_Email: FloatLabelTextField!
    @IBOutlet weak var txt_Password: FloatLabelTextField!
    @IBOutlet weak var txt_ReenterPassword: FloatLabelTextField!
    @IBOutlet weak var txt_referralCode: FloatLabelTextField!
    @IBOutlet weak var btn_AppleSignIn: UIButton!
    @IBOutlet weak var btn_TermsAndCondition: UIButton!
    
    let registerViewModel = RegisterVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.btn_AppleSignIn.isHidden = false
        } else {
            self.btn_AppleSignIn.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    @IBAction func btn_TermsAndCondition_Tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btn_TermsAndCondition_Tappoed(_ sender: UIButton) {
        let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.TERMS_AND_CONDITIONS.rawValue) as! TermsViewController
        vc.tag = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_SignUp(_ sender: Any) {
        if txt_Name.trim() == ""
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.FULL_NAME.rawValue.localized)
        }
        else if txt_Name.trim().count < 2 {
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_FULLNAME_LENGTH.rawValue.localized)
        }
        else if !isValidFirstname(testStr: txt_Name.trim()){
            self.showToastOnWindow(text: VALIDATION_STRINGS.INVALID_FULLNAME_CHARACTERS.rawValue.localized)
        }
        else if txt_Email.trim() == ""
        {
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
        else if txt_Password.trim() != txt_ReenterPassword.trim()
        {
            self.showToastOnWindow(text: VALIDATION_STRINGS.PASSWORD_NOT_MATCHED.rawValue.localized)
        }   else if !btn_TermsAndCondition.isSelected{
            self.showToastOnWindow(text: VALIDATION_STRINGS.TERMS_CONDITION.rawValue.localized)
        }else{
            self.register(name: txt_Name.text!, email: txt_Email.text!, password: txt_Password.text!)
        }
    }
    
    @IBAction func btn_GoogleSignUp(_ sender: Any) {
        socialMediaAPI.googleAPIDelegate = self
        socialMediaAPI.googleSignIn()
    }
    
    @IBAction func btn_Apple_Login_Tapped(_ sender: Any) {
        if #available(iOS 13.0, *) {
            self.handleAuthorizationAppleIDButtonPress()
        } else {
            
        }
    }
    
    @IBAction func btn_FacebookSignUp(_ sender: Any) {
        socialMediaAPI.fbLoginManager(vc: self) { (fbDetails) in
            let dict = fbDetails
            
            let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.PERSONAL_DETAILS.rawValue) as! PersonelDetailVC
            vc.fbLogin = true
            vc.fbDetails = dict
            vc.delegate = self
            
            vc.modalPresentationStyle = .overCurrentContext
            
            self.present(vc, animated: true, completion: nil)
            
        }
    }
}

extension RegisterVC : SocialLoginDelegate{
    func socialLogin(name: String, email: String, fbLogin: Bool, fbID : String, googleLogin: Bool, googleId: String, AppleLogin: Bool, AppleId: String) {
        self.socialRegister(name: name, email: email, facebookLogin: fbLogin, facebookId: fbID, googleLogin: googleLogin, googleId: googleId, AppleLogin: AppleLogin, AppleId: AppleId)
    }
}

extension RegisterVC : GoogleAPIDelegate{
    func getGooleUserDetails(user: GIDGoogleUser) {
        
        let vc = STORYBOARD.AUTHENTICATION.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.PERSONAL_DETAILS.rawValue) as! PersonelDetailVC
        vc.googleLogin = true
        vc.googleDetails = user
        vc.delegate = self
        
        vc.modalPresentationStyle = .overCurrentContext
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func socialRegister(name: String, email: String, facebookLogin: Bool, facebookId: String, googleLogin: Bool, googleId: String, AppleLogin: Bool, AppleId: String) {
        registerViewModel.socialRegister(name: name, email: email, facebookLogin: facebookLogin, facebookId: facebookId, googleLogin: googleLogin, googleId: googleId,AppleLogin: AppleLogin, AppleId: AppleId, viewController: self) { (loginModel,message,status) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            
            if status != "500" {
                // Firebase Event
                AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.SOCIAL_SIGNUP.rawValue)
                
                self.registerViewModel.setDefaultValues(loginModel)
                
                let vc = STORYBOARD.DASHBOARD.rawValue.instantiateViewController(withIdentifier: IDENTIFIRES.DASHBOARD.rawValue) as! DashBoardVC
                
                CommonMethods.setIsSocialLogin(value: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func register(name: String, email: String, password: String) {
        
        registerViewModel.register(name: name, email: email, password: password, referralCode: txt_referralCode.text ?? "", viewController: self) { (loginModel, message, status) in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showSuccessMessage(message)
            
            if status != "500" {
                // Firebase Event
                AppDelegate().setEvent(LOGEVENTS.FIREBASE_EVENT_LOGGED.rawValue, LOGEVENTS.APP_SIGNUP.rawValue)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

@available(iOS 13.0, *)
extension RegisterVC : ASAuthorizationControllerDelegate{
    
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
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
            
            self.socialLogin(name: name, email: email, fbLogin: false, fbID: "", googleLogin: false, googleId: "", AppleLogin: true, AppleId: userIdentifier)
            
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
extension RegisterVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
