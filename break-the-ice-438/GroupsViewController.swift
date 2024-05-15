//
//  GroupsViewController.swift
//  break-the-ice-438
//


import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

struct TestStruct: Decodable {
    let array: [String]
}

struct Group {
    var members: [String]
 
}


class GroupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var myArray: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90
        tableView.dataSource = self
        tableView.delegate = self

        retrieveJoinedChatsForUser()
        
        navigationItem.title = "Chats"
    }

    func retrieveJoinedChatsForUser() {
        guard let user_id = Auth.auth().currentUser?.uid else {
            return
        }
        
        print(user_id)
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user_id)

        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }

            guard let userData = document?.data(),
                  let joinedChats = userData["joined_chats"] as? [String] else {
                print("error")
                return
            }

            self.myArray = joinedChats
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let messagesViewController = storyboard.instantiateViewController(withIdentifier: "MessagesViewControllerID") as? MessagesViewController {
            messagesViewController.chatName = myArray[indexPath.row]
            
            navigationController?.pushViewController(messagesViewController, animated: true)
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        myCell.textLabel!.text = myArray[indexPath.row]
        
        return myCell
    }
    
    // Function to retrieve chat messages for a specific chat
    func retrieveChatMessagesForChat(_ chatName: String) {
        let db = Firestore.firestore()
        
        db.collection("chats")
            .document(chatName)
            .collection("chat-log")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let username = data["Username"] as? String,
                           let messageText = data["Text"] as? String {
                            print("Username: \(username)")
                            print("Message: \(messageText)")
                        }
                    }
                } else {
                    print("no msgs")
                }
            }
    }


    
    
    @IBAction func sendMsgButton(_ sender: Any) {
        if let text = textBox.text, !text.isEmpty {
            myArray.append(text)
            tableView.reloadData()
            textBox.text = ""
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        do {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            LoginViewController.modalPresentationStyle = .fullScreen
            self.present(LoginViewController, animated: true, completion: nil)
        }
    }
    
    
    
    func retrieveChatMessagesForClass(classID: String, completion: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("classes")
            .document(classID)
            .collection("chat-log")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                if let documents = snapshot?.documents {
                    completion(documents, nil)
                } else {
                    completion(nil, NSError(domain: "AppDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "no msgs"]))
                }
            }
    }
    
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        
        let classDocumentID = "cse438"

        retrieveChatMessagesForClass(classID: classDocumentID) { (documents, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let documents = documents {
                    for document in documents {
                        let data = document.data()
                        // Access and print the message data (e.g., data["Username"] for the username)
                        if let username = data["Username"] as? String,
                           let messageText = data["message_text"] as? String,
                           let timestamp = data["Time"] as? Timestamp {
                            let date = timestamp.dateValue()
                            print("Username: \(username)")
                            print("Message: \(messageText)")
                            print("Timestamp: \(date)")
                        }
                    }
                }
            }
        }
    }
    

}
