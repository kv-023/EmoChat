//
//  OptionsChangeUserNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeUsernameTableViewController: UITableViewController, UITextFieldDelegate,
RegexCheckProtocol {
    
    @IBOutlet weak var changeUsernameTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    var currentUser: User!
    var manager: ManagerFirebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Manager firebase
        manager = ManagerFirebase.shared
        
        
        //Init rigth button item
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveUserName))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        //Hide keybord ot tap
        self.hideKeyboard()
        
        
        //Show current username in textfield
        changeUsernameTextField.text = currentUser.username
    }
    
    // MARK: - Actions
    @IBAction func usernameEdited(_ sender: UITextField) {
        
        if usernameIsValid(userName: sender.text) {
            infoLabel.text = NSLocalizedString("Username is valid", comment: "Username is valid")
            infoLabel.textColor = UIColor.darkGray
        } else {
            infoLabel.printError(errorText: "Enter valid username")
        }
        
    }
    
    // MARK: - Save to firebase
    func saveUserName(sender: UIBarButtonItem) {
        if  usernameIsValid(userName: changeUsernameTextField.text){
            manager.changeUsername(newUsername: changeUsernameTextField.text!) {
                result in
                switch result {
                case .success:
                    print ("success change username")
                    //back to previous vc
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                case .failure(let error):
                    print(error)
                    self.infoLabel.text = error
                default:
                    break
                }
            }
        }
    }
}

