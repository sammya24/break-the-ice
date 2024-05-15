
import UIKit
import Firebase

struct JoinedClasses{
    var className: String
    var classCode: String
    var isUserInstructor: Bool
}

class HomescreenViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var classCodeTextField: UITextField!
    @IBOutlet weak var classesTableView: UITableView!
    
    var joinedClasses: [JoinedClasses] = []
    var selectedClassCode: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinedClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = classesTableView.dequeueReusableCell(withIdentifier: "JoinedClasses", for: indexPath) as? JoinedClassesCell else {
            fatalError("cell dq error")
        }
        cell.createGroupsButton.isHidden = true
        cell.classNameLabel.text = joinedClasses[indexPath.row].className
        cell.createGroupsButton.addTarget(self, action: #selector(createGroupsButtonTapped(_:)), for: .touchUpInside)
        
        if let user_id = Auth.auth().currentUser?.uid {
            let classCode = joinedClasses[indexPath.row].classCode
            let classRef = Firestore.firestore().collection("classes").document(classCode)
            
            classRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Check if the user is an instructor or a student
                    if let instructors = data?["instructors"] as? [String: Bool],
                       let isUserInstructor = instructors[user_id], isUserInstructor {
                        cell.createGroupsButton.isHidden = false
                    }
                    
                    if let students = data?["students"] as? [String: Bool],
                       let isUserStudent = students[user_id], isUserStudent {
                        cell.createGroupsButton.isHidden = true
                    }
                } else {
                    print("class doc null")
                }
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let classCodeToDelete = joinedClasses[indexPath.row].classCode
            deleteClass(withCode: classCodeToDelete, atIndexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userViewController = UsersViewController()
        userViewController.courseID = joinedClasses[indexPath.row].classCode
        navigationController?.pushViewController(userViewController, animated: true)
    }
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classesTableView.dataSource = self
        
        classesTableView.delegate = self
        fetchJoinedClasses()
    }
    

    
    func updateUserJoinedChats(user_id: String, classCode: String) {
        let userRef = db.collection("users").document(user_id)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            
            guard let userData = document?.data() else {
                print("doc null")
                return
            }
            
            // init the 'joined_classes' array if it doesnt exist
            var joinedClasses = userData["joined_chats"] as? [String] ?? []
            
            // check if the class code is not already in the array
            if !joinedClasses.contains(classCode) {
                joinedClasses.append(classCode)
                
                userRef.updateData(["joined_chats": joinedClasses]) { error in
                    if let error = error {
                        print("joined_chats error: \(error.localizedDescription)")
                    } else {
                        print("joined_chats success")
                    }
                }
            } else {
                print("user chat repeat")
            }
        }
    }

    @IBAction func joinClassButton(_ sender: Any) {
        guard let classCode = classCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        guard let user_id = auth.currentUser?.uid else {
            return
        }
        
        let classRef = db.collection("classes").document(classCode)
        
        classRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            
            guard let classDocument = document, classDocument.exists else {
                print("classCode null: \(classCode)")
                return
            }
            
            if var classData = classDocument.data() {
                
                if let instructors = classData["instructors"] as? [String: Bool], instructors[user_id] == nil {
                    
                    // make sure user is not alrdy student
                    var students = classData["students"] as? [String: Bool] ?? [:]
                    if students[user_id] == nil {
                        students[user_id] = true
                        classData["students"] = students
                        
                        classRef.setData(classData) { [weak self] error in
                            guard let self = self else { return }
                            
                            if let error = error {
                                print("error: \(error.localizedDescription)")
                            } else {
                                print("success")
                                
                                // call function to update the user's joined_classes
                                self.updateUserJoinedChats(user_id: user_id, classCode: classCode)
                                
                                // add the joined class to the local data
                                let joinedClass = JoinedClasses(className: classData["className"] as? String ?? "",
                                                                classCode: classCode,
                                                                isUserInstructor: false)
                                self.joinedClasses.append(joinedClass)
                                
                                self.classesTableView.reloadData()
                            }
                        }
                    } else {
                        print("user class repeat")
                    }
                }
            }
        }
    }

    
    
    func fetchJoinedClasses() {
        guard let user_id = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let userStudentClassesRef = Firestore.firestore().collection("classes").whereField("students.\(user_id)", isEqualTo: true)
        let userInstructorClassesRef = Firestore.firestore().collection("classes").whereField("instructors.\(user_id)", isEqualTo: true)
        
        var studentClasses: [JoinedClasses] = []
        var instructorClasses: [JoinedClasses] = []
        
        userStudentClassesRef.getDocuments { [weak self] (studentQuerySnapshot, studentError) in
            guard let self = self else { return }
            
            if let studentError = studentError {
                print("error: \(studentError.localizedDescription)")
                return
            }
            
            studentClasses = studentQuerySnapshot?.documents.compactMap { document in
                let data = document.data()
                guard let className = data["className"] as? String,
                      let classCode = data["classCode"] as? String
                else {
                    return nil
                }
                
                
                return JoinedClasses(className: className, classCode: classCode, isUserInstructor: false)
            } ?? []
            
            userInstructorClassesRef.getDocuments { (instructorQuerySnapshot, instructorError) in
                if let instructorError = instructorError {
                    print("error: \(instructorError.localizedDescription)")
                    return
                }
                
                instructorClasses = instructorQuerySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let className = data["className"] as? String,
                          let classCode = data["classCode"] as? String
                    else {
                        return nil
                    }
                    
                    return JoinedClasses(className: className, classCode: classCode, isUserInstructor: true)
                } ?? []
                
                self.joinedClasses = studentClasses + instructorClasses
                self.classesTableView.reloadData()
            }
        }
    }
    
    
    func addNewClass(className: String, classCode: String) {
        guard let user_id = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newClassData: [String: Any] = [
            "className": className,
            "classCode": classCode,
            //"students": [user_id: true], instructor should not be added as a student in the class to be paired
            "instructors": [user_id: true]
        ]
        
        let db = Firestore.firestore()
        
        // add the new class document in the "classes" collection
        db.collection("classes").document(classCode).setData(newClassData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("error adding: \(error.localizedDescription)")
            } else {
                print("successfully added")
              
                self.fetchJoinedClasses()
                
                // create a new doc in the "chats" collection
                let chatData: [String: Any] = [
                    "num_of_messages": 1,
                    "classCode": classCode,
                    "className": className
                ]
                
                db.collection("chats").document(classCode).setData(chatData) { error in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                    } else {
                        print("success")
                        
                        // create a subcollection named 'chat-log' within the chat document
                        let chatLogData: [String: Any] = [
                            "Text": "Welcome",
                            "Username": "System"
                        ]
                        
                        db.collection("chats").document(classCode).collection("chat-log").document("0").setData(chatLogData) { error in
                            if let error = error {
                                print("error: \(error.localizedDescription)")
                            } else {
                                print("success")
                            }
                        }
                    }
                }
            }
        }
    }


    
    @IBAction func createClass(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add a New Class", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Class Name:"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Class Code:"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let className = alertController.textFields?.first?.text,
               let classCode = alertController.textFields?.last?.text {
                self.addNewClass(className: className, classCode: classCode)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteClass(withCode classCode: String, atIndexPath indexPath: IndexPath) {
        guard let user_id = Auth.auth().currentUser?.uid else {
            return
        }
        let classRef = Firestore.firestore().collection("classes").document(classCode)
        
        classRef.updateData(["students.\(user_id)": false]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error updating students map: \(error.localizedDescription)")
            } else {
                print("Class deleted successfully.")
                self.joinedClasses.remove(at: indexPath.row)
                self.classesTableView.deleteRows(at: [indexPath], with: .fade)
                self.classesTableView.reloadData()
            }
        }
        
    }
    
    @IBAction func logoutButton(_ sender: Any) {
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
    
    @IBAction func createGroupsButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? JoinedClassesCell,
                  let indexPath = classesTableView.indexPath(for: cell) else {
                return
            }
            selectedClassCode = joinedClasses[indexPath.row].classCode

            // Show an alert to input the number of students per group
            let alertController = UIAlertController(title: "Create Groups", message: "Enter the number of students per group:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Number of students per group"
                textField.keyboardType = .numberPad
            }

            let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
                guard let self = self,
                      let textField = alertController.textFields?.first,
                      let numberOfStudentsPerGroupString = textField.text,
                      let numberOfStudentsPerGroup = Int(numberOfStudentsPerGroupString) else {
                    return
                }

                self.createGroups(forClass: self.selectedClassCode!, numberOfStudentsPerGroup: numberOfStudentsPerGroup)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alertController.addAction(createAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
    }
    
    func createGroups(forClass classCode: String, numberOfStudentsPerGroup: Int) {
        let classRef = Firestore.firestore().collection("classes").document(classCode)
        
        classRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            if let studentIDs = data?["students"] as? [String: Bool] {
                self.fetchResponses(forClass: classCode, studentIDs: Array(studentIDs.keys), numberOfStudentsPerGroup: numberOfStudentsPerGroup)
            }
        }
    }
    
    func fetchResponses(forClass classCode: String, studentIDs: [String], numberOfStudentsPerGroup: Int) {
        var responses: [String: [String: Int]] = [:]
        
        let group = DispatchGroup()
        
        for studentID in studentIDs {
            group.enter()
            
            Firestore.firestore().collection("responses").document(studentID).collection("questions").getDocuments { (querySnapshot, error) in
                defer {
                    group.leave()
                }
                
                if let error = error {
                    print("error fetching responses \(studentID): \(error.localizedDescription)")
                    return
                }
                
                var studentResponses: [String: Int] = [:]
                for document in querySnapshot?.documents ?? [] {
                    if let response = document["response"] as? Int {
                        studentResponses[document.documentID] = response
                    }
                }
                
                responses[studentID] = studentResponses
            }
        }
        
        group.notify(queue: .main) {
            print(responses)
            let groups = self.formGroupsBasedOnSimilarity(classCode: classCode, responses: responses, students: studentIDs, numStudentsInGroup: numberOfStudentsPerGroup)
            
            print("Groups: \(groups)")
            
            self.storeGroupsInFirestore(forClass: classCode, groups: groups)
        }
    }
    
    
    func formGroupsBasedOnSimilarity(classCode: String, responses: [String: [String: Int]], students: [String], numStudentsInGroup: Int) -> [Group] {
        var groups: [Group] = []

        let responseArray = responses.map { (studentID, studentResponses) in
            return (studentID, studentResponses)
        }

        let sortedResponseArray = responseArray.sorted { (lhs, rhs) in
            let lhsScore = lhs.1.values.reduce(0, +)
            let rhsScore = rhs.1.values.reduce(0, +)
            return lhsScore < rhsScore
        }

        var currentIndex = 0
        while currentIndex < sortedResponseArray.count {
            let remainingStudents = sortedResponseArray.count - currentIndex
            let groupSize = min(remainingStudents, numStudentsInGroup)
            let groupMembers = sortedResponseArray[currentIndex..<currentIndex + groupSize].map { $0.0 }
            let group = Group(members: Array(groupMembers))
            groups.append(group)
            currentIndex += groupSize
        }
        print (groups)
        return groups
    }
    

    func storeGroupsInFirestore(forClass classCode: String, groups: [Group]) {
        let classDocumentRef = Firestore.firestore().collection("classes").document(classCode)
        
        var groupDocumentRefs: [DocumentReference] = []
        
        for (index, group) in groups.enumerated() {
            let groupData: [String: Any] = [
                "groupNumber": index + 1,
                "members": group.members
            ]
            
            let groupCollectionRef = classDocumentRef.collection("groups")
            
            print("Group Data \(index + 1): \(groupData)")
            
            groupCollectionRef.addDocument(data: groupData) { error in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    let groupDocumentRef = groupCollectionRef.document("\(index + 1)")
                    groupDocumentRefs.append(groupDocumentRef)
                    print("success")
                    
                    if groupDocumentRefs.count == groups.count {
                        for (groupIndex, group) in groups.enumerated() {
                            let groupName = "\(classCode)_group\(groupIndex + 1)"
                            self.createGroupChat(forClass: classCode, groupNumber: groupIndex + 1)
                            
                            for member in group.members {
                                self.updateUserJoinedChats(user_id: member, classCode: groupName)
                            }
                        }
                    }
                }
            }
        }
    }



    func createGroupChat(forClass classCode: String, groupNumber: Int) {
        let groupName = "\(classCode)_group\(groupNumber)"
        let db = Firestore.firestore()
        
        let chatData: [String: Any] = [
            "num_of_messages": 1,
            "classCode": classCode,
            "groupNumber": groupNumber
        ]
        
        db.collection("chats").document(groupName).setData(chatData) { error in
            if let error = error {
                print("error: \(error.localizedDescription)")
            } else {
                print("group chat document created successfully for \(groupName).")
                
                let chatLogData: [String: Any] = [
                    "Text": "Welcome",
                    "Username": "System"
                ]
                
                db.collection("chats").document(groupName).collection("chat-log").document("0").setData(chatLogData) { error in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                    } else {
                        print("chat-log document created successfully for \(groupName).")
                    }
                }
            }
        }
    }

}
