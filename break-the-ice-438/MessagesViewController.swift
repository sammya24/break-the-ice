import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textBarOutlet: UITextField!
    
    @IBOutlet weak var sendButtonOutlet: UIButton!
        
    
    @IBAction func sendMessage(_ sender: Any) {
            guard let currentUsername = currentUsername else {
                print("username not retrieved")
                return
            }
        
            guard let messageText = textBarOutlet.text, !messageText.isEmpty else {
                return
            }
            let currentMessageCount = chatMessages.count

            let newMessageDocumentID = "\(currentMessageCount)"

            guard let messageText = textBarOutlet.text, !messageText.isEmpty else {
                print("message text empty")
                return
            }

            guard let chatName = chatName else {
                print("chat not found")
                return
            }

            let db = Firestore.firestore()
            let chatRef = db.collection("chats").document(chatName)
            let chatLogRef = chatRef.collection("chat-log").document(newMessageDocumentID)

            let messageData: [String: Any] = [
                "Username": currentUsername,
                "Text": messageText
            ]

            chatLogRef.setData(messageData) { [weak self] (error) in
                guard let self = self else { return }

                if let error = error {
                    print("error sending message: \(error.localizedDescription)")
                } else {
                    let newChatMessage = ChatMessage(username: currentUsername, messageText: messageText)
                    self.chatMessages.append(newChatMessage)
                    self.tableView.reloadData()
                    
                    // scroll to the bottom of the table view
                    if self.chatMessages.count > 0 {
                        let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    textBarOutlet.text = ""
                    
                }
            }

        }

    
    var chatName: String?
    var chatMessages: [ChatMessage] = []
    var currentUsername: String?

    struct ChatMessage {
        let username: String
        let messageText: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = chatName
        setupTableView()
        retrieveChatMessages()
        retrieveCurrentUserUsername()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.chatMessages.count > 0 {
            let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func retrieveCurrentUserUsername() {
        // get the current users user_id
        guard let user_id = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user_id)

        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }

            //  check if the document exists and contains the 'username' field
            if let userData = document?.data(), let username = userData["username"] as? String {
                print("username: \(username)")
                currentUsername = username
            } else {
                print("document error")
            }
        }
    }

    func retrieveChatMessages() {
        guard let chatName = chatName else {
            return
        }

        let db = Firestore.firestore()

        db.collection("chats")
            .document(chatName)
            .collection("chat-log")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents {
                    self.chatMessages = documents.compactMap { document in
                        if let username = document["Username"] as? String,
                           let messageText = document["Text"] as? String {
                            return ChatMessage(username: username, messageText: messageText)
                        }
                        return nil
                    }

                    self.tableView.reloadData()
                } else {
                    print("no msgs")
                }
            }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell

        let chatMessage = chatMessages[indexPath.row]

        cell.usernameLabel.text = chatMessage.username
        cell.messageTextLabel.text = chatMessage.messageText

        let gapHeight: CGFloat = 12.0
        let cellHeight = cell.frame.height
        cell.greenBoxOutlet.frame.size.height = cellHeight - gapHeight

        return cell
    }


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chatMessage = chatMessages[indexPath.row]
        let messageText = chatMessage.messageText

        let cellPadding: CGFloat = 24
        let messageTextLabelWidth = tableView.frame.width - (2 * cellPadding)
        let messageTextLabelFont = UIFont.systemFont(ofSize: 16.0)
        let messageTextLabelSize = (messageText as NSString).boundingRect(
            with: CGSize(width: messageTextLabelWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: messageTextLabelFont],
            context: nil
        ).size

        let usernameLabelHeight: CGFloat = 20.0
        let totalCellHeight = cellPadding + usernameLabelHeight + messageTextLabelSize.height + cellPadding

        return totalCellHeight
    }

}
