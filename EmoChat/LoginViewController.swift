//
//  ViewController.swift
//  Test
//
//  Created by Vladyslav Tsykhmystro on 31.05.17.
//  Copyright © 2017 Vladyslav Tsykhmystro. All rights reserved.
//

import UIKit

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

    @IBOutlet weak var logIn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
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
        
        //custom text field
        emailField.useUnderline()
        passwordField.useUnderline()
        
        emailField.bounds = logIn.bounds
        passwordField.bounds = logIn.bounds

     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAction(_ sender: UIButton) {
        
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

