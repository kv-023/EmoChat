//
//  OptionsChangeUserNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeUserNameTableViewController: UITableViewController, UITextFieldDelegate, RegexCheckProtocol  {
    
    @IBOutlet weak var changeUserNameTextField: UITextField!
    
    @IBOutlet weak var footerLabel: UILabel!
    
    var manager: ManagerFirebase?
    
    var usernameValid = false {
        didSet {
            if !usernameValid {
                footerLabel.printError(errorText: NSLocalizedString("Enter valid name", comment: "Valid name warning"))
                changeUserNameTextField.redBorder()
            } else {
                footerLabel.printOK(okText: NSLocalizedString("Username", comment: "Username without warning"))
                changeUserNameTextField.whiteBorder()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Create a right save button and add it to vc
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveUserName))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        //Hide keyboard by tap
        
        
        //Create manager
        manager = ManagerFirebase()
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

