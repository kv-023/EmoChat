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
    
    func useUnderline() {
        
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets

    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var hintsLabel: UILabel!
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegate
        emailField.delegate = self
        passwordField.delegate = self
        
        //circular Get Started Button
        logIn.layer.cornerRadius = 15
        logIn.layer.masksToBounds = true
        
        logIn.layer.borderWidth = 2
        logIn.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func viewDidLayoutSubviews() {
        
        emailField.useUnderline()
        passwordField.useUnderline()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAction(_ sender: UIButton) {
        if emailField.text != "" && passwordField.text != "" {
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                                    if user != nil && (user?.isEmailVerified)! {
                                        self.hintsLabel.text = ("success! you are in")
                                    } else {
                                        if let myError = error?.localizedDescription {
                                            self.hintsLabel.text = myError
                                        } else {
                                            self.hintsLabel.text = ("confirm your e-mail")
                                        }
                                    }
            });
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

