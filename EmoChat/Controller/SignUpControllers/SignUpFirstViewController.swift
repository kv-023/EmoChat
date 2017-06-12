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
    var manager: ManagerFirebase?

    var usernameValid = false {
        didSet {
            if !usernameValid {
                usernameLabel.printError(errorText: NSLocalizedString("Enter valid name", comment: "Valid name warning"))
                username.redBorder()
            } else {
                usernameLabel.printOK(okText: NSLocalizedString("Username", comment: "Username without warning"))
                username.whiteBorder()
            }
        }
    }

    var emailValid = false {
        didSet {
            if !emailValid {
                emailLabel.printError(errorText: NSLocalizedString("Enter valid email", comment: "Valid email warning"))
                email.redBorder()
            } else {
                emailLabel.printOK(okText: NSLocalizedString("Email", comment: "Email without warning"))
                email.whiteBorder()
            }
        }
    }
    var passwordValid = false {
        didSet {
            if !passwordValid {
                passwordLabel.printError(errorText: NSLocalizedString("Enter valid password", comment: "Valid password warning"))
                password.redBorder()
            } else {
                passwordLabel.printOK(okText: NSLocalizedString("Password", comment: "Password without warning"))
                password.whiteBorder()
            }
        }
    }
    var passwordConfirmationValid = false {
        didSet {
            if !passwordConfirmationValid {
                confirmationLabel.printError(errorText: NSLocalizedString("Passwords do not match", comment: "Confirmation does not match warning"))
                confirmation.redBorder()
            } else {
                confirmationLabel.printOK(okText: NSLocalizedString("Confirmation", comment: "Confirmation without warning"))
                confirmation.whiteBorder()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide keyboard by tap
        self.hideKeyboard()
        
        //Scroll when keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Create Firebase manager
        manager = ManagerFirebase()
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
            usernameLabel.printError(errorText: NSLocalizedString("Enter username", comment: "Empty username"))
            username.redBorder()
            success = false
        }
        if email.text == "" {
            emailLabel.printError(errorText: NSLocalizedString("Enter email", comment: "Empty email"))
            email.redBorder()
            success = false
        }
        if password.text != confirmation.text {
            confirmationLabel.printError(errorText: NSLocalizedString("Passwords do not match", comment: "Confirmation is not as password"))
            confirmation.redBorder()
            success = false
        }
        if password.text == "" {
            passwordLabel.printError(errorText: NSLocalizedString("Enter password", comment: "Empty password"))
            password.redBorder()
        }
        if success
            && (usernameValid
                && emailValid
                && passwordValid
                && passwordConfirmationValid) {
            manager?.signUp(email: email.text!, password: password.text!) {
                resultString in
                if resultString == "Success" {
                    self.performSegue(withIdentifier: "additional", sender: self)
                } else {
                    self.emailLabel.printError(errorText: resultString)
                    self.email.redBorder()
                }
            }
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
