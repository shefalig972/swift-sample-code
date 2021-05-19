
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

protocol GoogleAPIDelegate {
    func getGooleUserDetails(user: GIDGoogleUser)
}

class SocialMediaAPIHelper: NSObject {
    var googleAPIDelegate: GoogleAPIDelegate? = nil
    let fbLoginManager : LoginManager = LoginManager()
    
    func fbLoginManager(vc : UIViewController, completion: @escaping (NSDictionary) -> Void) {
        
                
        fbLoginManager.logIn(permissions: ["email","user_friends","public_profile"], from: vc) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("public_profile"))
                {
                    self.getFBUserData { (fbDetails) in
                        completion(fbDetails)
                    }
                }
            }
        }
    }
    
    func getFBUserData(completion: @escaping (NSDictionary) -> Void){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    // Add API to save the details to server.
                    let dict = result as! NSDictionary
                    completion(dict)
                }
            })
        }
    }
    
    func googleSignIn(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func fbLogout() {
        self.fbLoginManager.logOut()
        
        URLCache.shared.removeAllCachedResponses()

        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
}

extension SocialMediaAPIHelper: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        
        googleAPIDelegate?.getGooleUserDetails(user: user)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
                 withError error: Error!) {
         // Perform any operations when the user disconnects from app here.
         // ...
       }
}
