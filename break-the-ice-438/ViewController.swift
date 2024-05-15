//
//  ViewController.swift
//  break-the-ice-438
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let launchScreenTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLaunchScreenTap))
        self.view.addGestureRecognizer(launchScreenTapGesture)
    }
    
    // Transition to Login Screen when clicked anywhere on the Launch Screen
    @objc func handleLaunchScreenTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }


}

