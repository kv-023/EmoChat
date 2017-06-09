//
//  ViewController.swift
//  Test
//
//  Created by Vladyslav Tsykhmystro on 31.05.17.
//  Copyright © 2017 Vladyslav Tsykhmystro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

extension UITextField {

	// Shake function inplementation

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

    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
		backgroundAnimated.loadGif(name: "giphy")
        super.viewDidLoad()
        //set delegate
        emailField.delegate = self
        passwordField.delegate = self
		
        //circular Get Started Button
        logIn.layer.cornerRadius = 15
        logIn.layer.masksToBounds = true
        
//        logIn.layer.borderWidth = 2
//        logIn.layer.borderColor = UIColor.white.cgColor
		
		//Gesture recognizer
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)
    }

	func dismissKeyboard() {

		//Causes the view (or one of its embedded text fields) to resign the first responder status.

		view.endEditing(true)

	}
    
    override func didReceiveMemoryWarning()	{
		
		// Dispose of any resources that can be recreated.
        super.didReceiveMemoryWarning()
		
    }
	
	func checkColor(textField: UITextField) -> Bool	{
		
		if (textField.textColor == UIColor.red) {
			return true
		} else {
			return false
		}
	
	}
	
	func checkError(email: UITextField, password: UITextField) {
		
		if checkColor(textField: email) {
			emailField.text = nil
		}
		if checkColor(textField: password) {
			passwordField.text = nil;
		}

	}
	
	@IBAction func textFieldDidBeginEditing(_ textField: UITextField) {

		checkError(email: emailField, password: passwordField)
		emailField.textColor = UIColor.black
		passwordField.textColor = UIColor.black
		if passwordField.isSecureTextEntry == false {
			passwordField.isSecureTextEntry = true;
		}
		
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

    @IBAction func loginAction(_ sender: UIButton)	{
		
		checkError(email: emailField, password: passwordField)
		
		let textFields = (emailField.text, passwordField.text)
		
		switch textFields {
		case let(email, password) where email == "" && password == "" :
		// Alert to tell the user that there was an error because they didn't fill anything
			passwordField.isSecureTextEntry = false;
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15)
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15)
		case let(email, password) where email != "" && password == "" :
		// Alert user of empty password
			passwordField.isSecureTextEntry = false;
			passwordField.text = ("Input your password")
			passwordField.textColor = UIColor.red
			passwordField.shake(count: 1, for: 0.05, withTranslation: 15)
		case let(email, password) where email == "" && password != "" :
		// Alert user of empty email
			emailField.text = ("Input your email")
			emailField.textColor = UIColor.red
			emailField.shake(count: 1, for: 0.05, withTranslation: 15)
		default:
			//All okay - move forward to authentication
			
			// Preventing of creation additional pressing of Login button
			self.logIn.isEnabled = false;
			
			Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
				
				if user != nil /*&& (user?.isEmailVerified)!*/ {
					
					self.hintsLabel.text = ("You have succesfuly logged in")
					self.hintsLabel.textColor = UIColor.green
					let when = DispatchTime.now() + 0.5
					DispatchQueue.main.asyncAfter(deadline: when) {
						self.performSegue(withIdentifier: "showConversations", sender: self)
					}
						
				} else	{
					
					// Enabling button to allow making amends due to mistake
					
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

		if self.emailField.isEditing {
			self.emailField.endEditing(true)
		}
		if self.passwordField.isEditing {
			self.passwordField.endEditing(true)
		}
    }
    
   // MARK: UITextFieldDelegate
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
        }
   
    return true
        
    }

}

