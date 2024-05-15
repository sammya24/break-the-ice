//
//  SignupViewController.swift
//  break-the-ice-438
//
//  Created by Reaggy Liu on 11/11/23.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        passwordTextField.delegate = self
        confirmPasswordTF.delegate = self
        signupButton.isEnabled = false

    }
    @IBAction func signupClicked(_ sender: UIButton) {

        let registerUserRequest = RegisterUserRequest(
            username: usernameTextField.text ?? "",
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        if !Validator.isValidEmail(for: registerUserRequest.email){
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        if !Validator.isValidUsername(for: registerUserRequest.username){
            AlertManager.showInvalidUsernameAlert(on: self)
            return
            
        }
        if !Validator.isValidPassword(for: registerUserRequest.password){
            AlertManager.showInvalidPasswordAlert(on: self)
            return
            
        }
        AuthService.shared.registerUser(with: registerUserRequest) { [weak self] wasRegistered, error in
            guard let self = self else {return}
            
            if let error = error {
                AlertManager.showSignUpErrorAlert(on: self, with: error)
                return
            }
            
            if wasRegistered {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            }
            else{
                AlertManager.showSignUpErrorAlert(on: self)
            }
        }
    }
    
    @IBAction func transitionToLogin(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    

    private func updateSignUpButtonState() {
            let isPasswordNotEmpty = !(passwordTextField.text?.isEmpty ?? true)
            let doPasswordsMatch = passwordTextField.text == confirmPasswordTF.text
            signupButton.isEnabled = isPasswordNotEmpty && doPasswordsMatch
        }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateSignUpButtonState()
    }

}
