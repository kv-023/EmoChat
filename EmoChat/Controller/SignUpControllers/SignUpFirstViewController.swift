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
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmation: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!

    var usernameValid = false {
        didSet {
            if !usernameValid {
                usernameLabel.printError(errorText: "Enter valid name")
                username.redBorder()
            } else {
                usernameLabel.printOK(okText: "User name")
                username.whiteBorder()
            }
            usernameLabel.isHidden = usernameValid
        }
    }

    var emailValid = false {
        didSet {
            if !emailValid {
                emailLabel.printError(errorText: "Enter valid email")
                email.redBorder()
            } else {
                emailLabel.printOK(okText: "Email")
                email.whiteBorder()
            }
            emailLabel.isHidden = emailValid
        }
    }
    var passwordValid = false {
        didSet {
            if !passwordValid {
                passwordLabel.printError(errorText: "Enter valid password")
                password.redBorder()
            } else {
                passwordLabel.printOK(okText: "Password")
                password.whiteBorder()
            }
            passwordLabel.isHidden = passwordValid
        }
    }
    var passwordConfirmationValid = false {
        didSet {
            if !passwordConfirmationValid {
                confirmationLabel.printError(errorText: "Enter valid password confirmation")
                confirmation.redBorder()
            } else {
                confirmationLabel.printOK(okText: "Confirmation")
                confirmation.whiteBorder()
            }
            confirmationLabel.isHidden = passwordConfirmationValid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide keyboard by tap
        self.hideKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func usernameEdited(_ sender: UITextField) {
        usernameValid = usernameIsValid(userName: sender.text)
    }

    @IBAction func emailEdited(_ sender: UITextField) {
        emailValid = emailIsValid(userEmail: sender.text)
    }

    @IBAction func passwordEdited(_ sender: UITextField) {
        passwordValid = passwordIsValid(userPassword: sender.text)
    }

    @IBAction func confirmationEdited(_ sender: UITextField) {
        passwordConfirmationValid = passwordIsValid(userPassword: sender.text)
    }

    @IBAction func nextIsPressed(_ sender: UIButton) {
        var success = true
        if username.text == "" {
            usernameLabel.text = "Enter username"
            success = false
        }
        if email.text == "" {
            emailLabel.text = "Enter email"
            success = false
        }
        if password.text != confirmation.text {
            confirmationLabel.text = "Passwords do not match"
            success = false
        }

        if success
            && (usernameValid
                && emailValid
                && passwordValid
                && passwordConfirmationValid) {

            performSegue(withIdentifier: "additional", sender: self)
        }
    }
    
}
