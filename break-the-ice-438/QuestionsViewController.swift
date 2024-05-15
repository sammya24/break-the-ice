//
//  QuestionsViewController.swift
//  break-the-ice-438
//
//  Created by Sam Hong on 11/13/23.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class QuestionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var currentQ: Question?
    var qID: Int?
    var numOfQs: Int?
    var qNum: Int?
    var currentUserLocal: User?

    @IBOutlet weak var QuestionText: UILabel!
    
    
    @IBOutlet weak var picker: UIPickerView!
    
    
    @IBAction func NextButton(_ sender: Any) {
        let responseIndex = picker.selectedRow(inComponent: 0)

            // Save the user's response
        saveUserResponse(responseIndex: responseIndex) { success, error in
            if success {
                print("User response saved successfully")
            } else {
                print("Error saving user response: \(error?.localizedDescription ?? "Unknown error")")
            }

            // Move to the next question
            self.qID = self.qID! + 1
            self.qNum = self.qNum! + 1

            if self.qNum! < self.numOfQs! {
                self.updateData(for: self.qID!)
            } else {
                self.qID = 0
                self.qNum = 0
                
                // All questions answered, navigate to the homepage or results page
               
                
            }
        }
    }
    
    func saveUserResponse(responseIndex: Int, completion: @escaping (Bool, Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            let userUID = currentUser.uid
            let questionID = "\(qID!)"

            let db = Firestore.firestore()

            db.collection("responses")
                .document(userUID)  // Each user has a document containing their responses
                .collection("questions")
                .document(questionID)  // Store the question number directly
                .setData([
                    "response": responseIndex  // Store the response index as a number
                ]) { error in
                    if let error = error {
                        completion(false, error)
                        return
                    }
                    completion(true, nil)
                }
        } else {
            // Handle the case where the user is not logged in
            completion(false, NSError(domain: "AppDomain", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
        }
    }



    
    func numberOfComponents(in Picker: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ picker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentQ?.answerOptions[row]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numOfQs = 7
        qID = 0
        qNum = 0
        
        //TODO ADD THE BELOW WHEN MAIN PAGE IMPLEMENTED
//        if let currentUser = Auth.auth().currentUser {
//            print("User is authenticated: \(currentUser.uid)")
//            currentUserLocal = User(username: "placeholder", email: currentUser.email!, userUID: currentUser.uid)
//
//
//        } else {
//            print("No user is authenticated")
//            navigateToHomepage()
//        }
        
        updateData(for: qID ?? 0)
        currentUserLocal = User(username: "test2", email:  "test@gmail.com", userUID: "test2") //TODO HARDCODED FOR NOW
        
    }
    
    func updateData(for questionIndex: Int) {
        currentQ = questions[qID!]
        QuestionText.text = questions[qID!].text

        //reload the picker to reflect the updated data
        picker.reloadAllComponents()
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
