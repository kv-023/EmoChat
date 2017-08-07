//
//  LoginViewController.swift
//  EmoChat
//
//  Created by Igor Demchenko on 5/29/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: EmoChatUIViewController, UITextFieldDelegate {

	// MARK: - IBOutlets

	@IBOutlet weak var backgroundAnimated: UIImageView!
	@IBOutlet weak var logIn: UIButton!
	@IBOutlet weak var emailField: CustomTextFieldWithPopOverInfoBox!
	@IBOutlet weak var passwordField: CustomTextFieldWithPopOverInfoBox!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var manager: ManagerFirebase? = nil
	let gifManager = SwiftyGifManager.defaultManager
	let backgroundGif = UIImage(gifName: "giphy.gif", levelOfIntegrity: 1.2)

	var currentEmailIsValid: Bool = false
	var currentPasswordIsValid: Bool = false

	// MARK: - ViewController lifecycle

	override func viewDidLoad() {
		
		// Set animated background
		super.viewDidLoad()
		self.backgroundAnimated.setGifImage(backgroundGif, manager: gifManager)
		activityIndicator.isHidden = true
		
		// TextField Delegate
		emailField.delegate = self
		passwordField.delegate = self
		
		// Circular Get Started Button
		logIn.layer.cornerRadius = 15
		logIn.layer.masksToBounds = true
		
		// Setting textFields and LogIn button styles
		emailField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		passwordField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		logIn.backgroundColor = UIColor.black.withAlphaComponent(0.9)
		logIn.layer.cornerRadius = 7
		logIn.layer.borderWidth = 1
		logIn.layer.borderColor = UIColor.black.cgColor
		
		// Gesture recognizer for tap capture
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		//Set Firebase manager
		manager = ManagerFirebase.shared
	}
	
	// MARK: - Dispose of any resources that can be recreated.
	
	override func didReceiveMemoryWarning()	{

		super.didReceiveMemoryWarning()
		
	}
	
	// MARK: - Causes the view (or one of its embedded text fields) to resign the first responder status.
	
	override func dismissKeyboard() {
		
		view.endEditing(true)
		
	}
	
	// MARK: - Animate button fade in
	
	func animateButton(_ button: UIButton, _ duration: Double, _ delay: Double, _ alpha: CGFloat)
	{

		UIView.animate(withDuration: duration,
		               delay: delay,
		               options: UIViewAnimationOptions.curveLinear,
		               animations: {
						button.alpha = alpha
		}, completion: nil)

	}
	
	// MARK: - Disable or Enable Button
	
	func setButton(button: UIButton, duration: Double, delay: Double, enable: Bool) {

		let isAlpha: CGFloat = enable ? 1.0 : 0.6
		animateButton(button, duration, delay, isAlpha)
		logIn.isEnabled = enable
	}

	func isValidEmail(_ email: String) -> Bool {
		
		// MARK: - Checks if email is valid by RegExp
		
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: email)

	}
	
	func isValidPassword(_ password: String) -> Bool {
		
		// MARK: - Checks if password is valid by RegExp
		
		let passwordRegEx = "^.{6,}$"
		let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
		
		return passwordTest.evaluate(with: password)
	}
	
	@IBAction func textFieldDidBeginEditing(_ textField: UITextField) {

		errorLabel.text = nil

		self.setButton(button: self.logIn, duration: 0, delay: 0, enable: true)
		
		switch textField {
			
		case self.emailField:
			
			emailField.becomeFirstResponder()
			emailField.imageQuestionShowed = false
			
		case self.passwordField:
			
			passwordField.becomeFirstResponder()
			passwordField.imageQuestionShowed = false
			
		default:
			
			emailField.resignFirstResponder()
			passwordField.resignFirstResponder()
			
		}
	}
	
	// MARK: - Capture any changes of input to invoke real-time alerts of error
	
	@IBAction func textFieldDidChange(_ textField: CustomTextFieldWithPopOverInfoBox) {

		if (emailField.isEditing) {
			
			currentEmailIsValid = isValidEmail(emailField.text!)
			
			emailField.imageQuestionShowed = emailField.text != "" ? !currentEmailIsValid : false
			emailField.textInfoForQuestionLabel = regexErrorText.LogInError.email.localized
			
		} else if (passwordField.isEditing) {
			
			currentPasswordIsValid = isValidPassword(passwordField.text!)
			
			passwordField.imageQuestionShowed = passwordField.text != "" ? !currentPasswordIsValid : false
			passwordField.textInfoForQuestionLabel = regexErrorText.LogInError.password.localized
		}
		
	}
	
	// MARK: - Capture action of login button
	
	@IBAction func loginAction(_ sender: UIButton)	{
		
		// Capture error again , to clear if login button was pressed again
		
		let textFields = (emailField, passwordField)
		
		// Check textFields on empty input in case of login button pressed
		
		switch textFields {
			
		case let(email, password) where (email.imageQuestionShowed || email.text == "") && (password.imageQuestionShowed || password.text == "") :
			
			// Alert to user of email and password input

			if emailField.text == "" {
	
				emailField.imageQuestionShowed = true
				emailField.textInfoForQuestionLabel = NSLocalizedString("Email must not be empty", comment: "") 

			}

			if passwordField.text == "" {

				passwordField.imageQuestionShowed = true
				passwordField.textInfoForQuestionLabel = NSLocalizedString("Password must not be empty", comment: "")

			}

			emailField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		case let(email, password) where (email.imageQuestionShowed || email.text == "") && !password.imageQuestionShowed :
			
			// Alert user of empty password and add shake animation
			
			if emailField.text == "" {

				emailField.imageQuestionShowed = true
				emailField.textInfoForQuestionLabel = "Email must not be empty"

			}

			emailField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		case let(email, password) where !email.imageQuestionShowed && (password.imageQuestionShowed || password.text == "") :
			
			// Alert user of empty email and add shake animation
			
			if passwordField.text == "" {

				passwordField.imageQuestionShowed = true
				passwordField.textInfoForQuestionLabel = "Password must not be empty"
	
			}
			
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		default:
			
			// When both fields are not empty - advance to a stage of verification
			
			// Disable logIn button for prevention of additional invokation of the press-button scenari
			
			// Firebase authentication, get both textFields initialized
			setButton(button: logIn, duration: 0, delay: 0, enable: false)
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()

			Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
				
				// Completion closure. Check if user is exist and if his email is verified.
				
				if user != nil && (user?.isEmailVerified)! {
					
					self.activityIndicator.startAnimating()
					self.errorLabel.text =  NSLocalizedString("You have succesfuly logged in", comment: "")
					self.errorLabel.textColor = UIColor.green
					
					// Slow delay between transition to conversations. Go to conversation through Segue
					
					let when = DispatchTime.now() + 1.5
					DispatchQueue.main.asyncAfter(deadline: when) {

						self.backgroundAnimated = nil
						self.performSegue(withIdentifier: "showConversations", sender: self)
						
					}
					
				} else	{
					
					// Enable logIn button again to allow making amends
					
					self.setButton(button: self.logIn, duration: 0, delay: 0, enable: true)
					self.activityIndicator.stopAnimating()
					self.activityIndicator.isHidden = true
					if let myError = error?.localizedDescription {
						
						self.errorLabel.text = myError
						self.errorLabel.textColor = UIColor.red
						
					} else {
						
						self.errorLabel.text = NSLocalizedString("Please confirm your e-mail", comment: "")
						self.errorLabel.textColor = UIColor.red
						
					}
					
				}
			});
		}
			// MARK: - In case of button press all previous actions on edit will cease
			self.emailField.endEditing(true)
			self.passwordField.endEditing(true)
		}
		
		// MARK: - By return button transits to password if currently on email field, and makes password field inactive if pressed in password field
		
		func textFieldShouldReturn(_ textField: UITextField) -> Bool {
			
			if textField == emailField {
				
				passwordField.becomeFirstResponder()
				
			} else if textField == passwordField {
				
				passwordField.resignFirstResponder()
				
			}
			
			return true
			
		}		
}

