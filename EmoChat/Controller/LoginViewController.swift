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

class LoginViewController: EmoChatUIViewController {
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var backgroundAnimated: UIImageView!
	@IBOutlet weak var logIn: UIButton!
	@IBOutlet weak var emailField: CustomTextFieldWithPopOverInfoBox!
	@IBOutlet weak var passwordField: CustomTextFieldWithPopOverInfoBox!
	@IBOutlet weak var hintsLabel: UILabel!
	@IBOutlet weak var transition: UIImageView!
	
	var manager: ManagerFirebase? = nil
	
	var currentEmailIsValid: Bool = false {
		
		didSet {
			
			setButton(button: logIn, duration: 0.4, delay: 0, active: true, setAlpha: 1)
			
		}

	}
	var currentPasswordIsValid: Bool = false {
		
		didSet {
			
			setButton(button: logIn, duration: 0.4, delay: 0, active: true, setAlpha: 1)
			
		}

	}
	
	// MARK: - ViewController lifecycle
	
	override func viewDidLoad() {
		
	// Load varw and set animated background
		super.viewDidLoad()
		backgroundAnimated.loadGif(name: "giphy")
		
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
		setButton(button: logIn, duration: 0, delay: 0, active: true, setAlpha: 1)
		
	// MARK: - Gesture recognizer
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)
		
	// MARK: - Create Firebase manager
		manager = ManagerFirebase()
	}
	
	override func didReceiveMemoryWarning()	{
		
	// MARK: - Dispose of any resources that can be recreated.
		super.didReceiveMemoryWarning()
		
	}

	override func dismissKeyboard() {
		
	// MARK: - Causes the view (or one of its embedded text fields) to resign the first responder status.
		
		view.endEditing(true)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showSignUp"
		{
			let destinationVC = segue.destination as? SignUpFirstViewController

			destinationVC?.posX = backgroundAnimated.frame.origin.x
			destinationVC?.posY = backgroundAnimated.frame.origin.y
			
		}
		
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
	
	func setButton(button: UIButton, duration: Double, delay: Double, active: Bool, setAlpha: CGFloat) {
		
		if active {
			
			let isActive = currentEmailIsValid && currentPasswordIsValid
			
			let isAlpha: CGFloat = isActive ? 1.0 : 0.6
			animateButton(button, duration, delay, isAlpha)
			logIn.isEnabled = isActive
		
		} else {
			
			animateButton(button, duration, delay, setAlpha)
			logIn.isEnabled = setAlpha == 1 ? true : false
		
		}
	}
	
	/* @Deprecated

	func checkColor(textField: CustomTextFieldWithPopOverInfoBox) -> Bool	{
		
	// MARK: - Checks if color is red
		
		if (textField.textColor == UIColor.red) {
			return true
		} else {
			return false
		}
		
	}
	
	
	func checkToCleanError(email: CustomTextFieldWithPopOverInfoBox, password: CustomTextFieldWithPopOverInfoBox) {
		
	// MARK: - Check by color if login button had ended in error and needs to clean error text
		
		if checkColor(textField: email) {
			emailField.text = nil
		}
		if checkColor(textField: password) {
			passwordField.text = nil;
		}
		
	}
	
	@Deprecated */
	
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
	
	@IBAction func textFieldDidBeginEditing(_ textField: CustomTextFieldWithPopOverInfoBox) {

	/* @Deprecated

		// MARK: - By tapping one of text fields the function captures events described below:
		
		// MARK: - Check if need to clear previous error placed in textField placeholder
		
			checkToCleanError(email: emailField, password: passwordField)
		
		// MARK: - Set color of text typing
		
			emailField.textColor = UIColor.black
			passwordField.textColor = UIColor.black
		
		// MARK: - Previous errors may be unencrypted to present it in ASCII. Following action will encrypt input again

			if passwordField.isSecureTextEntry == false {
				passwordField.isSecureTextEntry = true;
			}
		
			// MARK: - Capture textField input and create Responder
		@Deprecated */
		
		switch textField {
			
		case self.emailField:
			
			emailField.becomeFirstResponder()
			
		case self.passwordField:
			
			passwordField.becomeFirstResponder()
			
		default:
			
			emailField.resignFirstResponder()
			passwordField.resignFirstResponder()
			
		}
	}

	// MARK: - Capture any changes of input to invoke real-time alerts of error

	@IBAction func textFieldDidChange(_ textField: CustomTextFieldWithPopOverInfoBox) {
	
		if (emailField.isEditing) {
			
			if (passwordField.imageQuestionShowed) {
				passwordField.shake(myDelay: 0.5)
			}
			
			currentEmailIsValid = isValidEmail(emailField.text!)

			emailField.imageQuestionShowed = !currentEmailIsValid
			emailField.textInfoForQuestionLabel = regexErrorText.LogInError.email.localized

		} else if (passwordField.isEditing) {

			if (emailField.imageQuestionShowed) {
				emailField.shake(myDelay: 0.5)
			}

			currentPasswordIsValid = isValidPassword(passwordField.text!)

			passwordField.imageQuestionShowed = !currentPasswordIsValid
			passwordField.textInfoForQuestionLabel = regexErrorText.LogInError.password.localized

		}

	}
	
	// MARK: - Capture action of login button
	
	@IBAction func loginAction(_ sender: UIButton)	{
		
		/* @Deprecated
		// Capture error again , to clear if login button was pressed again
		
		checkToCleanError(email: emailField, password: passwordField)
		
		let textFields = (emailField.text, passwordField.text)
		
			// Check textFields on empty input in case of login button pressed
		
		switch textFields {
			
		case let(email, password) where email == "" && password == "" :
			
			// Alert to user of email and password inputs
			
			passwordField.isSecureTextEntry = false;
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		case let(email, password) where email != "" && password == "" :
			
			// Alert user of empty password and add shake animation
			
			passwordField.isSecureTextEntry = false;
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		case let(email, password) where email == "" && password != "" :
			
			// Alert user of empty email and add shake animation
			
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15, delay: 0)
			
		default:
			
				// When both fields are not empty - advance to a stage of verification
	
				// Disable logIn button for prevention of additional invokation of the press-button scenario
		
		@Deprecated	*/
		
		
		self.logIn.isEnabled = false;
			
		// Firebase authentication, get both textFields initialized
			
		Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
				
			// Completion closure. Check if user is exist and if his email is verified.
				
			if user != nil && (user?.isEmailVerified)! {
					
				self.hintsLabel.text = ("You have succesfuly logged in")
				self.hintsLabel.textColor = UIColor.green
				self.setButton(button: self.logIn, duration: 0, delay: 0, active: false, setAlpha: 0)
				self.transition.loadGif(name: "transition")
			
			// Slow delay between transition to conversations. Go to conversation through Segue
				
				let when = DispatchTime.now() + 2.5
				DispatchQueue.main.asyncAfter(deadline: when) {
					
					self.performSegue(withIdentifier: "showConversations", sender: self)

				}
					
			} else	{
					
			// Enable logIn button again to allow making amends
					
				self.logIn.isEnabled = true;
					
				if let myError = error?.localizedDescription {
					
					self.hintsLabel.text = myError
					self.hintsLabel.textColor = UIColor.red

				} else {

					self.hintsLabel.text = ("Please confirm your e-mail")
					self.hintsLabel.textColor = UIColor.red

				}
					
				}
			});
		
	// MARK: - In case of button press all previous actions on edit will cease
		
		if self.emailField.isEditing {
			self.emailField.endEditing(true)
		}

		if self.passwordField.isEditing {
			self.passwordField.endEditing(true)
		}
	}
	
	// MARK: - By return button transits to password if currently on email field, and makes password field inactive if pressed in password field
	
	func textFieldShouldReturn(_ textField: CustomTextFieldWithPopOverInfoBox) -> Bool {
		
		if textField == emailField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			passwordField.resignFirstResponder()
		}
		
		return true
		
	}
	
}

