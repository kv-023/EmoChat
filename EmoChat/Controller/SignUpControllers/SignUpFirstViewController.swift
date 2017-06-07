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

    var usernameValid = false {
        didSet {
            if !usernameValid {
                usernameWarning.printError(errorText: "Enter valid name")
                username.redBorder()
            } else {
                usernameWarning.printOK(okText: "User name")
                username.whiteBorder()
            }
            usernameWarning.isHidden = !usernameValid
        }
    }

    var emailValid = false {
        didSet {
            if !emailValid {
                emailWarning.printError(errorText: "Enter valid email")
                email.redBorder()
            } else {
                emailWarning.printOK(okText: "Email")
                email.whiteBorder()
            }
            emailWarning.isHidden = !emailValid
        }
    }
    var passwordValid = false {
        didSet {
            if !passwordValid {
                passwordWarning.printError(errorText: "Enter valid password")
                password.redBorder()
            } else {
                passwordWarning.printOK(okText: "Password")
                password.whiteBorder()
            }
            passwordWarning.isHidden = !passwordValid
        }
    }
    var passwordConfirmationValid = false {
        didSet {
            if !passwordConfirmationValid {
                confirmationWarning.printError(errorText: "Enter valid password confirmation")
                confirmation.redBorder()
            } else {
                confirmationWarning.printOK(okText: "Confirmation")
                confirmation.whiteBorder()
            }
            confirmationWarning.isHidden = !passwordConfirmationValid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
            && (usernameValid
                && emailValid
                && passwordValid
                && passwordConfirmationValid) {

            performSegue(withIdentifier: "additional", sender: self)
        }
    }
    
}
