//
//  SignUpFirstViewController.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/6/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SignUpFirstViewController: EmoChatUIViewController, UITextFieldDelegate, RegexCheckProtocol {

    @IBOutlet weak var username: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var email: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var password: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var confirmation: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var theScrollView: UIScrollView!
    var manager: ManagerFirebase?
    var enteredEmail: String?
    var enteredUsername: String?
    var enteredPassword: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var image: UIImage?
    var returned: Bool?
    var edited = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var usernameValid = false {
        didSet {
            if !usernameValid {
                usernameLabel.printError(errorText: NSLocalizedString("Enter valid name", comment: "Valid name warning"))

            } else {
                usernameLabel.printOK(okText: NSLocalizedString("Username", comment: "Username without warning"))
            }

            username.imageQuestionShowed = !usernameValid
            username.textInfoForQuestionLabel = regexErrorText.SignUpError.userName.localized
        }
    }

    var emailValid = false {
        didSet {
            if !emailValid {
                emailLabel.printError(errorText: NSLocalizedString("Enter valid email", comment: "Valid email warning"))
            } else {
                emailLabel.printOK(okText: NSLocalizedString("Email", comment: "Email without warning"))
            }

            email.imageQuestionShowed = !emailValid
            email.textInfoForQuestionLabel = regexErrorText.SignUpError.email.localized
        }
    }
    var passwordValid = false {
        didSet {
            if !passwordValid {
                passwordLabel.printError(errorText: NSLocalizedString("Enter valid password", comment: "Valid password warning"))
            } else {
                passwordLabel.printOK(okText: NSLocalizedString("Password", comment: "Password without warning"))
            }

            password.imageQuestionShowed = !passwordValid
            password.textInfoForQuestionLabel = regexErrorText.SignUpError.password.localized
        }
    }
    var passwordConfirmationValid = false {
        didSet {
            if !passwordConfirmationValid {
                confirmationLabel.printError(errorText: NSLocalizedString("Enter valid confirmation", comment: "Valid confirmation warning"))
            } else {
                confirmationLabel.printOK(okText: NSLocalizedString("Confirmation", comment: "Confirmation without warning"))
            }

            confirmation.imageQuestionShowed = !passwordConfirmationValid
            confirmation.textInfoForQuestionLabel = regexErrorText.SignUpError.passwordConfirmation.localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.isHidden = true
        email.text = enteredEmail
        password.text = enteredPassword
        confirmation.text = enteredPassword
        username.text = enteredUsername
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide keyboard by tap
        self.hideKeyboard()
        
        //Scroll when keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Create Firebase manager
        manager = ManagerFirebase.shared
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
        edited = true
    }

    @IBAction func emailEdited(_ sender: UITextField) {
        emailValid = emailIsValid(userEmail: sender.text)
        edited = true
    }

    @IBAction func passwordEdited(_ sender: UITextField) {
        passwordValid = passwordIsValid(userPassword: sender.text)
        edited = true
    }

    @IBAction func confirmationEdited(_ sender: UITextField) {
        passwordConfirmationValid = passwordIsValid(userPassword: sender.text)
        edited = true
    }

    @IBAction func nextIsPressed(_ sender: UIButton) {
        usernameValid = usernameIsValid(userName: username.text)
        emailValid = emailIsValid(userEmail: email.text)
        passwordValid = passwordIsValid(userPassword: password.text)
        passwordConfirmationValid = passwordIsValid(userPassword: confirmation.text)
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
            success = false
        }
        if success
            && (usernameValid
                && emailValid
                && passwordValid
                && passwordConfirmationValid) {
            var reuse = false
            if let check = returned {
                if check {
                    reuse = true
                }
                if check && edited {
                    manager?.deleteAccount {
                        result in
                        switch result {
                        default:
                            break
                        }
                    }
                    returned = false
                }
            }
            if reuse && (!edited) {
                performSegue(withIdentifier: "additional", sender: self)
            } else {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                manager?.checkUserNameUniqness(self.username.text!) {
                    result in
                    switch result {
                    case .success:
                        self.manager?.signUp(email: self.email.text!, password: self.password.text!) {
                            result in
                            switch result {
                            case .success:
                                self.performSegue(withIdentifier: "additional", sender: self)
                            case .failure(let error):
                                self.email.imageQuestionShowed = true
                                self.email.textInfoForQuestionLabel = error
                                self.email.redBorder()
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                            default:
                                break
                            }
                        }
                    case .failure(let error):
                        self.username.redBorder()
                        self.username.imageQuestionShowed = true
                        self.username.textInfoForQuestionLabel = error
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    default:
                        break
                    }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "additional" {
            let destination:AdditionalViewController = segue.destination as! AdditionalViewController
            destination.username = username.text
            destination.email = email.text
            destination.password = password.text
            destination.firstName = firstName
            destination.lastName = lastName
            destination.phoneNumber = phoneNumber
            destination.image = image
        }
    }
    
}
