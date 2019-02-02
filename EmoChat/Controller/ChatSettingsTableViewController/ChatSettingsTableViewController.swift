//
//  ChatSettingsTableViewController.swift
//  EmoChat
//
//  Created by Vlad on 18.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Firebase

class ChatSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var logoCell = LogoTableViewCell()
    var addUserCell = UITableViewCell()
    var leaveChatCell = UITableViewCell()
    var userCell = UserTableViewCell()
    
    var storageRef: StorageReference!
    var manager: ManagerFirebase!
    var currentUser: User!
    var conversation: Conversation!
    
    var usersInConversation = [User]()
    var photosArray: [String: UIImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = ManagerFirebase.shared
        tableView.contentInset = UIEdgeInsets.init(top: -20, left: 0, bottom: 0, right: 0)
        self.navigationItem.title = NSLocalizedString("Conversation", comment: "")
        
       sortUsers()

    }
 
    func sortUsers() {
        var usersWithFirstName = [User]()
        var usersWithUsername = [User]()
        
        for users in conversation.usersInConversation {
            
            if (users.firstName != nil) && (users.secondName != nil) {
                usersWithFirstName.append(users)
            } else {
                usersWithUsername.append(users)
            }
        }
        
        usersWithFirstName.sort { (user1, user2) -> Bool in
            if user1.firstName == user2.firstName {
                return user1.secondName! < user2.secondName!
            } else {
                return user1.firstName! < user2.firstName!
            }
        }
        usersWithUsername.sort { $0.username! < $1.username! }
        
        usersInConversation.append(contentsOf: usersWithFirstName)
        usersInConversation.append(contentsOf: usersWithUsername)
        usersInConversation = usersInConversation.filter{$0.username != currentUser.username}
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return usersInConversation.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            logoCell = tableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as! LogoTableViewCell
            
            logoCell.conversTitle.text = conversation.name!
            logoCell.conversLogo.clipsToBounds = true
            logoCell.conversLogo.layer.cornerRadius =  logoCell.conversLogo.frame.size.height / 2
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadNewLogo))
            logoCell.conversLogo.isUserInteractionEnabled = true
            logoCell.conversLogo.addGestureRecognizer(tapGestureRecognizer)
        
        return logoCell
        
        case 1:
            if indexPath.row == 0 {
                addUserCell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath)
                return addUserCell
            } else {
                leaveChatCell = tableView.dequeueReusableCell(withIdentifier: "leave", for: indexPath)
                return leaveChatCell
            }
            
        default:
            userCell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! UserTableViewCell
            
            userCell.userPic.clipsToBounds = true
            userCell.userPic.layer.cornerRadius =  22
            let userByIndexPath = usersInConversation[indexPath.row]

            if (userByIndexPath.firstName != nil) && (userByIndexPath.secondName != nil) {
                userCell.userName.text = userByIndexPath.firstName! + " " + userByIndexPath.secondName!
            } else if (userByIndexPath.firstName != nil) {
                 userCell.userName.text = userByIndexPath.firstName!
            } else {
                userCell.userName.text = "@" + userByIndexPath.username

            }
            userCell.userPic.image = self.photosArray[userByIndexPath.uid]
           
            return userCell
        }
    }                                                                                   

    
    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
       return 5
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("CONVERSATION SETTINGS", comment: "")
        case 2:
            return NSLocalizedString("USERS IN CONVERSATION", comment: "")
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        switch indexPath.section {
        case 0:
            return 75
        case 1:
            return 40
        default:
            return 50
        }
    
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
        if indexPath.section == 0 {
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow

        if segue.identifier == "showUserInfo" {
            let userInfoVC: UserInfoTableViewController = segue.destination as! UserInfoTableViewController
            userInfoVC.selectedUser = usersInConversation[(indexPath?.row)!]
            userInfoVC.selectedUserPhoto = photosArray[usersInConversation[(indexPath?.row)!].uid]
            let backItem = UIBarButtonItem()
            backItem.title = NSLocalizedString("Back", comment: "Back button")
            navigationItem.backBarButtonItem = backItem
        }
    }

    // MARK: Loading New Photo
    @objc func loadNewLogo(tapGestureRecognizer: UITapGestureRecognizer) {
    
        let imagePicker = UIImagePickerController()
    
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    
        let alert = UIAlertController(title: NSLocalizedString("Image Source", comment: "Image Source") , message: NSLocalizedString("Choose new conversation logo", comment: "Choose new conversation logo") , preferredStyle: .actionSheet)
    
        alert.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Photo Library"), style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            }
        }
            )
        )
    
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
    
        self.present(alert, animated: true, completion: nil)
        self.present(imagePicker, animated: true, completion: nil)
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

    
        guard let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else { return }
    
        logoCell.conversLogo.clipsToBounds = true
        logoCell.conversLogo.image = chosenImage
        
        
        //Add image to firebase
     
        manager?.loadLogo(chosenImage, conversationID: conversation.uuid, result: { (result) in
            switch result {
            case .success:
                print("photo save")
                break
            case .failure(let error):
                print("\(error) fail saving photo")
            default:
                break
            }

        })
 
        self.dismiss(animated:true, completion: nil)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
