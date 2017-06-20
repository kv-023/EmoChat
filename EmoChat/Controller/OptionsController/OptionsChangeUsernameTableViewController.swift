//
//  OptionsChangeUserNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeUsernameTableViewController: UITableViewController, UITextFieldDelegate, RegexCheckProtocol  {
    
    @IBOutlet weak var changeUsernameTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    var currentUser: User!
    var manager: ManagerFirebase!
    
    var usernameValid = false {
        didSet {
            if !usernameValid {
                infoLabel.printError(errorText: NSLocalizedString("Enter valid name", comment: "Valid name warning"))
            } else {
                infoLabel.printOK(okText: NSLocalizedString("Username", comment: "Username without warning"))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Init mamager firebase
        manager = ManagerFirebase.shared
        
        //Create a right save button and add it to vc
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveUserName))
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    // MARK: - Actions
    @IBAction func usernameEdited(_ sender: UITextField) {
        usernameValid = usernameIsValid(userName: sender.text)
        
    }
        // MARK: - Saving to firebase
        func saveUserName(sender: UIBarButtonItem) {
            
            print("nihao chiba username")
            
            
        }
        
        
        
}

