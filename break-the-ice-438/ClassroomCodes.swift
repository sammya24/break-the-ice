//
//  ClassroomCodes.swift
//  break-the-ice-438
//
//  Created by Neziha Aktas on 11/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct Class {
    var className: String
    var classCode: String
    var students: [String: Bool]
}

//class ClassroomCodes: UIViewController {
//
//    @IBOutlet private var classCodeTextField: UITextField!
//
//    private let db = Firestore.firestore()
//    private let auth = Auth.auth()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    @IBAction func joinClassButton(_ sender: Any) {
//        guard let classCode = classCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
//            // Handle the case where classCode is empty or invalid
//            return
//        }
//
//        guard let userID = auth.currentUser?.uid else {
//            // Handle the case where the user is not authenticated
//            return
//        }
//
//        // Query the Firestore to find the class document with the entered classCode
//        let classRef = db.collection("classes").whereField("classCode", isEqualTo: classCode)
//
//        classRef.getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error querying class: \(error.localizedDescription)")
//                // Handle the error appropriately
//                return
//            }
//
//            guard let classDocument = querySnapshot?.documents.first else {
//                print("Class not found for classCode: \(classCode)")
//                // Handle the case where the class with the specified classCode is not found
//                return
//            }
//
//            // Update the students map in the class document
//            let classData = classDocument.data()
//            if var students = classData["students"] as? [String: Bool] {
//                students[userID] = true
//                // Update the Firestore document with the modified students map
//                classRef.document(classDocument.documentID).updateData(["students": students]) { error in
//                    if let error = error {
//                        print("Error updating students map: \(error.localizedDescription)")
//                        // Handle the error appropriately
//                    } else {
//                        print("User added to class successfully.")
//                        // Optionally, navigate to another screen or perform additional actions
//                    }
//                }
//            } else {
//                print("Students map not found in class document.")
//                // Handle the case where the students map is not found
//            }
//        }
//    }

    
//}
