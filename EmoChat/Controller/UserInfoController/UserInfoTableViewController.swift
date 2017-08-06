//
//  UserInfoTableViewController.swift
//  EmoChat
//
//  Created by Vlad on 25.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserInfoTableViewController: UITableViewController {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var selectedUser: User!
    var selectedUserPhoto: UIImage!
    var currentUser: User!
    
    let managerFirebase = ManagerFirebase.shared
    let sendMessageReuseIdentifier = "sendMessageCell"
    let requiredNumberOfCharachters = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInfo()
       
    }

    func configureUserInfo() {
        
        userPic.image = selectedUserPhoto
        
        if let name = selectedUser.firstName, let second = selectedUser.secondName {
            nameLabel.text = name + " " + second
        } else {
            nameLabel.text = selectedUser.username
        }
        
        if let phone = selectedUser.phoneNumber {
            phoneNumber.text = phone
        } else {
            phoneNumber.text = NSLocalizedString("Unknown", comment: "")
            phoneNumber.textColor = .gray
        }
        if let name = selectedUser.firstName {
            navigationItem.title = name
        }
        
        usernameLabel.text = "@" + selectedUser.username
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == sendMessageReuseIdentifier {
            var conversationName = "\(selectedUser.firstName ?? "") \(selectedUser.secondName ?? "")"
            if conversationName.characters.count < requiredNumberOfCharachters {
                conversationName = selectedUser.username
            }
            let users = [selectedUser!, currentUser!]
            managerFirebase.createConversation(users, withName: conversationName, completion: { [weak self] (result) in
                switch result {
                case let .successSingleConversation(conversation):
                    self?.performSegue(withIdentifier: "showConversation", sender: conversation)
                default:
                    break
                }
            })
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConversation" {
            let conversationVC = segue.destination as? SingleConversationViewController
            conversationVC?.currentConversation = sender as? Conversation
            conversationVC?.currentUser = currentUser
        }
    }
}
