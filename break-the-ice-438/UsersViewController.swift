//
//  UsersViewController.swift
//  break-the-ice-438
//
//  Created by Elaine Choy on 11/13/23.
//
import Foundation
import UIKit
import Firebase
import FirebaseAuth

class UsersViewController: UIViewController, UITableViewDataSource {

    var usernames: [String] = []
    var courseID: String!
    let tableView = UITableView()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        myCell.textLabel?.text = usernames[indexPath.row]
        return myCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tableView.dataSource = self
        tableView.rowHeight = 25
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore()
            let classesCollection = db.collection("classes")
            
            let currentUserDocument = classesCollection.document(courseID)
            
            currentUserDocument.getDocument { [weak self] (document, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting class document: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    let classData = document.data()
                    
                    if let studentUserIDs = classData?["students"] as? [String: Bool] {
                        self.getUsernames(for: studentUserIDs)
                    } else {
                        print("No students.")
                    }
                }
            }
        } else {
            print("User is not authenticated.")
        }
    }

    func getUsernames(for userIDs: [String: Bool]) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")

        for (userID, boolValue) in userIDs {
            let userDocumentReference = usersCollection.document(userID)
            
            userDocumentReference.getDocument { [weak self] (userDocument, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error getting user document: \(error.localizedDescription)")
                } else if let userDocument = userDocument, userDocument.exists {
                    if boolValue {
                        if let username = userDocument["username"] as? String {
                            self.usernames.append(username)
                        }
                    }
                }
                
                if self.usernames.count == userIDs.count {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("Usernames: \(self.usernames)")
                    }
                }
            }
        }
    }
}
