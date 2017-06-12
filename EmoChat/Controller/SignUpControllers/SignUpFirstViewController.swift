//
//  SignUpFirstViewController.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/6/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SignUpFirstViewController: UIViewController, UITextFieldDelegate, RegexCheckProtocol {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmation: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var theScrollView: UIScrollView!

    var usernameValid = false {
        didSet {
            if !usernameValid {
                usernameLabel.printError(errorText: "Enter valid name")
                username.redBorder()
            } else {
                usernameLabel.printOK(okText: "User name")
                username.whiteBorder()
            }
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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide keyboard by tap
        self.hideKeyboard()
        
        //Scroll when keyboard is up
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.theScrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.theScrollView.contentInset = contentInset
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
            usernameLabel.printError(errorText: "Enter username")
            success = false
        }
        if email.text == "" {
            emailLabel.printError(errorText: "Enter email")
            success = false
        }
        if password.text != confirmation.text {
            confirmationLabel.printError(errorText: "Passwords do not match")
            success = false
        }
        if password.text == "" {
            passwordLabel.printError(errorText: "Enter password")
        }
        if success
            && (usernameValid
                && emailValid
                && passwordValid
                && passwordConfirmationValid) {

            performSegue(withIdentifier: "additional", sender: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == username {
            email.becomeFirstResponder()
        } else if textField == email {
            password.becomeFirstResponder()
        } else if textField == password {
            confirmation.becomeFirstResponder()
        } else {
            confirmation.resignFirstResponder()
        }
        return true
    }
    
}
