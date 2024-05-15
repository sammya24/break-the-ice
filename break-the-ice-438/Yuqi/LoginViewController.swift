//
//  LoginViewController.swift
//  break-the-ice-438
//
//  Created by Reaggy Liu on 11/11/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var viewQuestionsButton: UIButton! //temporary
    
    @IBOutlet weak var ViewUsersButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
//        guard let email = emailTextField.text else {return}
//        guard let password = passwordTextField.text else {return}
//        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
//            if let e = error{
//                print("error")
//            }
//            else{
//                self.performSegue(withIdentifier: "goToNext", sender: self)
//            }
//        }
        let loginRequest = LoginUserRequest(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
        
        if !Validator.isValidEmail(for: loginRequest.email){
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        if !Validator.isValidPassword(for: loginRequest.password){
            AlertManager.showInvalidPasswordAlert(on: self)
            return
            
        }
        
        AuthService.shared.signIn(with: loginRequest) { error in
//            guard let self = self else {return}
            
            if let error = error {
                AlertManager.showSignInErrorAlert(on: self, with: error)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
            else{
                AlertManager.showSignInErrorAlert(on: self)
            }
        }
    }
    
    @IBAction func transitionToSignUp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signupViewController = storyboard.instantiateViewController(withIdentifier: "SignupViewController")
        signupViewController.modalPresentationStyle = .fullScreen
        self.present(signupViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickViewQuestions(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let questionViewController = storyboard.instantiateViewController(withIdentifier: "QuestionsViewController")
        questionViewController.modalPresentationStyle = .fullScreen
        self.present(questionViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func clickViewDatabase(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let databaseViewController = storyboard.instantiateViewController(withIdentifier: "UsersViewController")
        databaseViewController.modalPresentationStyle = .fullScreen
        self.present(databaseViewController, animated: true, completion: nil)
    }
    
    @IBAction func clickViewUsers(_ sender: Any) {
        do {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let GroupsViewController = storyboard.instantiateViewController(withIdentifier: "GroupsViewController")
            GroupsViewController.modalPresentationStyle = .fullScreen
            self.present(GroupsViewController, animated: true, completion: nil)
        }
    }
    
}
