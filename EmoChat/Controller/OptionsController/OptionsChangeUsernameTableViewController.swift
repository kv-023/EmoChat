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
    var currentUser: CurrentUser!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = CurrentUser.shared
        
        //Init rigth button item
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveUserName))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        //Hide keybord ot tap
        self.hideKeyboard()
        
        //Show current username in textfield
        changeUsernameTextField.text = currentUser.currentUser?.username
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
            currentUser.changeUsername(newUsername: changeUsernameTextField.text!)
        }
        
        //Back to previous vc
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
            
        }
    }
}

