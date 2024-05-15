//
//  Validator.swift
//  break-the-ice-438
//
//  Created by Reaggy Liu on 11/20/23.
//

import Foundation

class Validator{
    
    static func isValidEmail(for email: String) -> Bool{
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z]{2,}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidUsername(for username: String) -> Bool{
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameRegEx = "\\w{4,24}"
        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: username)
    }
    
    static func isValidPassword(for password: String) -> Bool{
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordRegEx = ".{6,}"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
}
