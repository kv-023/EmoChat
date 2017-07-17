//
//  SignUpFirstViewController.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/6/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SignUpFirstViewController: EmoChatUIViewController, UITextFieldDelegate, RegexCheckProtocol {
	
	@IBOutlet weak var backgroundAnimated: UIImageView!
    @IBOutlet weak var username: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var email: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var password: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var confirmation: CustomTextFieldWithPopOverInfoBox!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	let backgroundManager = SwiftyGifManager.defaultManager
	let backgroundGif = UIImage(gifName: "giphy.gif", levelOfIntegrity: 1.2)
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
	
    var usernameValid = false {
		
		didSet {
	
            username.imageQuestionShowed = !usernameValid && username.text != ""
            username.textInfoForQuestionLabel = regexErrorText.SignUpError.userName.localized
        }

    }

    var emailValid = false {
		
        didSet {
            email.imageQuestionShowed = !emailValid && email.text != ""
            email.textInfoForQuestionLabel = regexErrorText.SignUpError.email.localized
        }
	
    }
    var passwordValid = false {
		
        didSet {

            password.imageQuestionShowed = !passwordValid && password.text != ""
            password.textInfoForQuestionLabel = regexErrorText.SignUpError.password.localized
        }
	
    }
    var passwordConfirmationValid = false {
		
		didSet {
            confirmation.imageQuestionShowed = !passwordConfirmationValid && confirmation.text != ""
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
		self.backgroundAnimated.setGifImage(backgroundGif, manager: backgroundManager)
        
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

	@IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
		
		if textField.text == "" {
			(textField as! CustomTextFieldWithPopOverInfoBox).imageQuestionShowed = false;
		}
	}

    @IBAction func usernameEdited(_ sender: UITextField) {

		usernameValid = sender.text != "" ? usernameIsValid(userName: sender.text) : true;
        edited = true

    }

    @IBAction func emailEdited(_ sender: UITextField) {
		
		emailValid = sender.text != "" ? emailIsValid(userEmail: sender.text) : true;
        edited = true
		
    }

    @IBAction func passwordEdited(_ sender: UITextField) {

		passwordValid = sender.text != "" ? passwordIsValid(userPassword: sender.text) : true;
        edited = true

    }

    @IBAction func confirmationEdited(_ sender: UITextField) {

		passwordConfirmationValid = sender.text != "" ? passwordIsValid(userPassword: sender.text): true
        edited = true

    }

    @IBAction func nextIsPressed(_ sender: UIButton) {

        usernameValid = usernameIsValid(userName: username.text)
        emailValid = emailIsValid(userEmail: email.text)
        passwordValid = passwordIsValid(userPassword: password.text)
        passwordConfirmationValid = passwordIsValid(userPassword: confirmation.text)
		username.resignFirstResponder()
		email.resignFirstResponder()
		password.resignFirstResponder()
		confirmation.resignFirstResponder()

        var success = true
		
		if username.text == "" {
			username.imageQuestionShowed = true
			username.textInfoForQuestionLabel = NSLocalizedString("Username field must not be empty!", comment: "")
			username.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
            success = false
        }
		
		if email.text == "" {
			email.imageQuestionShowed = true
			email.textInfoForQuestionLabel = NSLocalizedString("Email field must not be empty!", comment: "")
			email.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
            success = false
        }
		
		if confirmation.text == "" {
			confirmation.imageQuestionShowed = true
			confirmation.textInfoForQuestionLabel = NSLocalizedString("Confirmation field must not be empty!", comment: "")
		} else if password.text != confirmation.text {
			confirmation.imageQuestionShowed = true
			confirmation.textInfoForQuestionLabel = NSLocalizedString("Password doesn't match with your previous input", comment: "")
			confirmation.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
            success = false
        }

		if password.text == "" {
			password.imageQuestionShowed = true
			password.textInfoForQuestionLabel = NSLocalizedString("Password field must not be empty!", comment: "")
			password.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
            success = false
        }

        if success
			&& usernameValid
			&& emailValid
			&& passwordValid
			&& passwordConfirmationValid {

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
			
			if reuse && !edited {
				
                performSegue(withIdentifier: "additional", sender: self)
	
            } else {
	
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                manager?.checkUserNameUniqness(self.username.text!) { result in

                    switch result {
						
					case .success:

                        self.manager?.signUp(email: self.email.text!, password: self.password.text!) { result in
							
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
	
		} else {

			let textFields: [CustomTextFieldWithPopOverInfoBox : Bool] = [username: usernameValid, email: emailValid, password: passwordValid, confirmation: passwordConfirmationValid]
			
			for (key, value) in textFields {
			
				switch value {
				
				case false:
					
					key.shake()
					
				default:
					break;
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
