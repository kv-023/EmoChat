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

extension UITextField {
	
	// MARK: - Shake animation inplementation
	
	func shake(count : Float? = nil, for duration : TimeInterval? = nil, withTranslation translation : Float? = nil) {
		let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		animation.repeatCount = count ?? 2
		animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
		animation.autoreverses = true
		animation.byValue = translation ?? -5
		layer.add(animation, forKey: "shake")
	}
}

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var backgroundAnimated: UIImageView!
	@IBOutlet weak var logIn: UIButton!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var hintsLabel: UILabel!
	var manager: ManagerFirebase? = nil
	
	// MARK: - ViewController lifecycle
	
	override func viewDidLoad() {
		
	// MARK: - Load view and set background
		super.viewDidLoad()
		backgroundAnimated.loadGif(name: "giphy")
		
	//set delegate
		emailField.delegate = self
		passwordField.delegate = self
		
	// MARK: - Circular Get Started Button
		logIn.layer.cornerRadius = 15
		logIn.layer.masksToBounds = true
		
	// MARK: - Setting textFields and LogIn button styles
		emailField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		passwordField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		logIn.backgroundColor = UIColor.black.withAlphaComponent(0.9)
		logIn.layer.cornerRadius = 7
		logIn.layer.borderWidth = 1
		logIn.layer.borderColor = UIColor.black.cgColor
		
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
	
	
	func checkColor(textField: UITextField) -> Bool	{
		
	// MARK: - Checks if color is red
		
		if (textField.textColor == UIColor.red) {
			return true
		} else {
			return false
		}
		
	}
	
	func checkToCleanError(email: UITextField, password: UITextField) {
		
	// MARK: - Check by color if login button had ended in error and needs to clean error text
		
		if checkColor(textField: email) {
			emailField.text = nil
		}
		if checkColor(textField: password) {
			passwordField.text = nil;
		}
		
	}
	
	func isValidEmail(_ testStr: String) -> Bool {
		
	// MARK: - Checks if email is valid by RegExp
		
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: testStr)
	}
	
	@IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
		
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

	// MARK: - Capture any changes of input to invoke real-time alerts of error
	
	@IBAction func textFieldDidChange(_ textField: UITextField) {
		
		if (!isValidEmail(emailField.text!)){
			animateButton(self.logIn, 0.7, 0, 0.6)
			self.logIn.isEnabled = false
		} else {
			animateButton(self.logIn, 0.7, 1, 1)
			self.logIn.isEnabled = true
		}
		
	}
	
	
	// MARK: - Capture action of login button
	
	@IBAction func loginAction(_ sender: UIButton)	{
		
	// MARK: - Capture error again , to clear if login button was pressed again
		
		checkToCleanError(email: emailField, password: passwordField)
		
		let textFields = (emailField.text, passwordField.text)
		
	// MARK: - Check textFields on empty input in case of login button pressed
		
		switch textFields {
			
		case let(email, password) where email == "" && password == "" :
			
	// MARK: - Alert to user of email and password inputs
			
			passwordField.isSecureTextEntry = false;
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15)
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15)
			
		case let(email, password) where email != "" && password == "" :
			
	// MARK: - Alert user of empty password and add shake animation
			
			passwordField.isSecureTextEntry = false;
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15)
			
		case let(email, password) where email == "" && password != "" :
			
	// MARK: - Alert user of empty email and add shake animation
			
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15)
			
		default:
			
	// MARK: - When both fields are not empty - advance to a stage of verification
			
	// MARK: - Disable logIn button for prevention of additional invokation of the press-button scenario
			
			self.logIn.isEnabled = false;
			
	// MARK: - Firebase authentication, get both textFields initialized
			
			Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
				
	// MARK: - Completion closure. Check if user is exist and if his email is verified.
				
				if user != nil && (user?.isEmailVerified)! {
					
					self.hintsLabel.text = ("You have succesfuly logged in")
					self.hintsLabel.textColor = UIColor.green
					
					// MARK: - Slow delay between transition to conversations. Go to conversation through Segue
					
					let when = DispatchTime.now() + 0.5
					DispatchQueue.main.asyncAfter(deadline: when) {
						self.performSegue(withIdentifier: "showConversations", sender: self)
					}
					
				} else	{
					
	// MARK: - Enable logIn button again to allow making amends
					
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
		}
		
	// MARK: - In case of button press all previous actions on edit will cease
		
		if self.emailField.isEditing {
			self.emailField.endEditing(true)
		}
		if self.passwordField.isEditing {
			self.passwordField.endEditing(true)
		}
	}
	
	// MARK: By return button transits to password if currently on email field, and makes password field inactive if pressed in password field
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		if textField == emailField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			passwordField.resignFirstResponder()
		}
		
		return true
		
	}
	
}

