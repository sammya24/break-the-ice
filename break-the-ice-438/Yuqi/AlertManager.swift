//
//  AlertManager.swift
//  break-the-ice-438
//
//  Created by Reaggy Liu on 11/20/23.
//

import UIKit

class AlertManager{
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String?){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}

// MARK: - Invalid Input Error
extension AlertManager{
    public static func showInvalidEmailAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Invalid Email", message: "Please enter a valid email.")
    }
    
    public static func showInvalidPasswordAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Invalid Password", message: "Please enter a valid password.")
    }
    
    public static func showInvalidUsernameAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Invalid Username", message: "Please enter a valid username.")
    }
}

// MARK: - SignUP Error
extension AlertManager{
    public static func showSignUpErrorAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Error Signing Up", message: nil)
    }
    
    public static func showSignUpErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Signing Up", message: "\(error.localizedDescription)")
    }

}

// MARK: - SignIN Error
extension AlertManager{
    public static func showSignInErrorAlert(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Error Signing In", message: nil)
    }
    
    public static func showSignInErrorAlert(on vc: UIViewController, with error: Error){
        var errorMessage = error.localizedDescription

            if let error = error as NSError? {
                // Check for underlying error
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    // Check for deserialized response
                    if let deserializedResponse = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any] {
                        // Extract the custom error message
                        if let customMessage = deserializedResponse["message"] as? String {
                            errorMessage = customMessage
                        }
                    }
                }
            }

            self.showBasicAlert(on: vc, title: "Error Signing In", message: errorMessage)
            print(errorMessage)
    }

}

// MARK: - Logout Error
extension AlertManager{
    public static func showLogoutErrorAlert(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Log Out Error", message: "\(error.localizedDescription)")
    }

}

// MARK: - Fetching User Error
extension AlertManager{
    public static func showUnknownFetchingUserError(on vc: UIViewController){
        self.showBasicAlert(on: vc, title: "Unknown Error Fetching User", message: nil)
    }
    
    public static func showFetchingUserError(on vc: UIViewController, with error: Error){
        self.showBasicAlert(on: vc, title: "Error Fetching User", message: "\(error.localizedDescription)")
    }
}
