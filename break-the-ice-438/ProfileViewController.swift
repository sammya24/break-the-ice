//
//  ProfileViewController.swift
//  break-the-ice-438
//
//  Created by Sam Hong on 12/2/23.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController {
    
    let favColorField = UITextField()
    let db = Firestore.firestore()
    let favColorText = UILabel()
    let favColorTextFrame = CGRect(x: 200, y: 200, width: 100, height: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userLabelFrame = CGRect(x: 80, y: 160, width: 150, height: 30)
        let userLabel = UILabel(frame: userLabelFrame)
        userLabel.text = "User Name"
        userLabel.textAlignment = .center
        self.view.addSubview(userLabel)
        
        let favColorLabelFrame = CGRect(x: 80, y: 200, width: 150, height: 30)
        let favColorLabel = UILabel(frame: favColorLabelFrame)
        favColorLabel.text = "Favorite Color"
        favColorLabel.textAlignment = .center
        self.view.addSubview(favColorLabel)
        
        favColorField.placeholder = "Enter color here"
        favColorField.isHidden = true
        favColorField.frame = CGRect(x: 300, y: 200, width: 70, height: 30)
        view.addSubview(favColorField)
        
        
        favColorText.frame = favColorTextFrame
        favColorText.text = "N/A"
        favColorText.textAlignment = .center
        self.view.addSubview(favColorText)
        
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let db = Firestore.firestore()
            let usersCollection = db.collection("users")
            
            let currentUserDocument = usersCollection.document(uid)
            
            currentUserDocument.getDocument { (document, error) in
                if let error = error {
                    print("Error getting user document: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    // Access the data of the user document
                    let userData = document.data()
                    
                    // Access the username field
                    if let username = userData?["username"] as? String {
                        let userFrame = CGRect(x: 200, y: 160, width: 100, height: 30)
                        let userField = UILabel(frame: userFrame)
                        userField.text = username
                        userField.textAlignment = .center
                        self.view.addSubview(userField)
                        print("Username: \(username)")
                    } else {
                        print("Username field is missing or not a String.")
                    }
                    if let favColor = userData?["favColor"] as? String {
                        self.favColorText.removeFromSuperview()
                        self.favColorText.text = favColor
                        self.favColorText.frame = self.favColorTextFrame
                        self.view.addSubview(self.favColorText)
                        print("Favorite Color: \(favColor)")
                    } else {
                        print("Favorite Color field is missing or not a String.")
                    }
                } else {
                    print("User document does not exist.")
                }
            }
        } else {
            // User is not authenticated
            print("User is not authenticated.")
        }
        
        

        // Do any additional setup after loading the view.
    }
    
//    @objc func editButtonTapped() {
//            // Toggle visibility of the text field
//            favColorField.isHidden.toggle()
//
//            // If the text field is visible, focus on it
//            if !favColorField.isHidden {
//                favColorField.becomeFirstResponder()
//            }
//        }
    
    @IBAction func EditButtonClicked(_ sender: Any) {
        favColorField.isHidden.toggle()

        // If the text field is visible, focus on it
        if !favColorField.isHidden {
            favColorField.becomeFirstResponder()
        } else {
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let db = Firestore.firestore()
                let usersCollection = db.collection("users")
                
                let currentUserDocument = usersCollection.document(uid)
                
                currentUserDocument.getDocument { (document, error) in
                    if let error = error {
                        print("Error getting user document: \(error.localizedDescription)")
                    } else if let document = document, document.exists {
                        
                        document.reference.updateData(["favColor":self.favColorField.text ?? ""])
                    } else {
                        print("Could not edit")
                    }
                }
            } else {
                // User is not authenticated
                print("User is not authenticated.")
            }
        }
    }
    
    @IBAction func RefreshButtonClicked(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let db = Firestore.firestore()
            let usersCollection = db.collection("users")
            
            let currentUserDocument = usersCollection.document(uid)
            
            currentUserDocument.getDocument { (document, error) in
                if let error = error {
                    print("Error getting user document: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    // Access the data of the user document
                    let userData = document.data()
                    
                    if let favColor = userData?["favColor"] as? String {
                        self.favColorText.removeFromSuperview()
                        self.favColorText.text = favColor
                        self.favColorText.frame = self.favColorTextFrame
                        self.view.addSubview(self.favColorText)
                        print("Favorite Color: \(favColor)")
                    } else {
                        print("Favorite Color field is missing or not a String.")
                    }
                } else {
                    print("User document does not exist.")
                }
            }
        } else {
            // User is not authenticated
            print("User is not authenticated.")
        }
        
    }
    
    @IBAction func LogoutButtonClicked(_ sender: Any) {
        print("logging out...")
        AuthService.shared.signOut { [weak self] error in
            guard let self = self else {return}
            if let error = error{
                AlertManager.showLogoutErrorAlert(on: self, with: error)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate{
                sceneDelegate.checkAuthentication()
            }
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
