//
//  SignUpFirstViewController.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/6/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SignUpFirstViewController: UIViewController, RegexCheckProtocol {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var usernameWarning: UILabel!
    @IBOutlet weak var emailWarning: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmation: UITextField!
    @IBOutlet weak var passwordWarning: UILabel!
    @IBOutlet weak var confirmationWarning: UILabel!

    var usernameValid = false
    var emailValid = false
    var passwordValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func usernameEdited(_ sender: UITextField) {
        usernameValid = usernameIsValid(userName: username.text)
    }
    
    @IBAction func emailEdited(_ sender: UITextField) {
        emailValid = emailIsValid()
    }
    
    @IBAction func passwordEdited(_ sender: UITextField) {
        passwordValid = passwordIsValid()
    }
    
    @IBAction func confirmationEdited(_ sender: Any) {
    }
    
    @IBAction func nextIsPressed(_ sender: UIButton) {
        var success = true
        if username.text == "" {
            usernameWarning.text = "Enter username"
            usernameWarning.isHidden = false
            success = false
        }
        if email.text == "" {
            emailWarning.text = "Enter email"
            emailWarning.isHidden = false
            success = false
        }
        if password.text != confirmation.text {
            confirmationWarning.text = "Passwords do not match"
            confirmationWarning.isHidden = false
            success = false
        }

        if success
            && (usernameValid && emailValid && passwordValid) {

            performSegue(withIdentifier: "additional", sender: self)
        }
    }

}
