//
//  OptionsChangeEmailTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeEmailTableViewController: UITableViewController, UITextFieldDelegate, RegexCheckProtocol {
    
    @IBOutlet weak var changeEmailTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    var currentUser: CurrentUser!
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //Add current user email in textfield
        changeEmailTextField.text = currentUser.email
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = CurrentUser.shared
        
        //Add right button item "Save"
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveEmail))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        
        //Hide keybord on tap
        self.hideKeyboard()
    }
    
    // MARK: - Action
    @IBAction func emailEdited(_ sender: UITextField) {
        if emailIsValid(userEmail: changeEmailTextField.text) {
            infoLabel.text = NSLocalizedString("Email is valid", comment: "Email is valid")
            infoLabel.textColor = UIColor.darkGray
        } else {
            infoLabel.printError(errorText: "Enter valid Email")
        }
    }
    
    // MARK: - Save to firebase
    func saveEmail(sender: UIBarButtonItem) {
        if emailIsValid(userEmail: changeEmailTextField.text){
            currentUser.changeEmail(newEmail: changeEmailTextField.text!)
        }
        
        //Back to previous vc
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}




















