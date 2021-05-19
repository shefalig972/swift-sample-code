//
//  ForgotPasswordVM.swift
//  picndrop
//
//  Created by Apple on 02/03/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordVM {
    func forgotPassword(email: String, viewController: UIViewController, completion: @escaping (String,String,String) -> Void) {
        viewController.showIndicator()
        
        let params = [
            "email" : email.trimmingCharacters(in: .whitespaces),
            "user_role_id" : 3
            ] as [String : Any]
        
        api.forgotPassword(url: API_ENDPOINTS.METHOD_FORGOT_PASSWORD.rawValue, parameters: params, viewController: viewController) { (message, status, statusCode) in
            viewController.hideIndicator()
            completion(message, status, statusCode)
        }
    }
}
