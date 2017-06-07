//
//  AdditionalViewController.swift
//  EmoChat
//
//  Created by Vlad on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

extension UITextField {
    
    func redBorder() {
        self.layer.cornerRadius = 7.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.masksToBounds = true
    }
    
    func whiteBorder() {
        self.layer.cornerRadius = 7.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
    }

    
}

class AdditionalViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    private let characterset = CharacterSet(charactersIn:
        "'-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func firstNameChanged(_ sender: UITextField) {
       
        if Regex.isMatchInString(for: "[a-zA-Z]", in:firstNameField.text!) {
            firstNameLabel.text = "Enter valid name"
            firstNameLabel.textColor = UIColor.red
            firstNameField.redBorder()
        } else {
            firstNameLabel.text = "First Name"
            firstNameLabel.textColor = UIColor.white
            firstNameField.whiteBorder()
        }
        /*
        if firstNameField.text!.rangeOfCharacter(from: characterset) != nil {
            firstNameLabel.text = "Enter valid name"
            firstNameLabel.textColor = UIColor.red
            firstNameField.redBorder()
            }
        else {
            firstNameLabel.text = "First Name"
            firstNameLabel.textColor = UIColor.white
            firstNameField.whiteBorder()
            }*/
    }

    @IBAction func lastNameChanged(_ sender: UITextField) {

        if lastNameField.text!.rangeOfCharacter(from: characterset) != nil {
            lastNameLabel.text = "Enter valid last name"
            lastNameLabel.textColor = UIColor.red
            firstNameField.redBorder()

        }
        else {
            lastNameLabel.text = "Last Name"
            lastNameLabel.textColor = UIColor.white
            firstNameField.whiteBorder()

        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
}
