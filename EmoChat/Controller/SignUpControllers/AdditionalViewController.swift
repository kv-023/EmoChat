//
//  AdditionalViewController.swift
//  EmoChat
//
//  Created by Vlad on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class AdditionalViewController: UIViewController, UITextFieldDelegate, RegexCheckProtocol {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    

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
       
        if nameIsValid(uname: sender.text) {
            firstNameLabel.text = "First Name"
            firstNameLabel.textColor = UIColor.white
            firstNameField.whiteBorder()
            
        } else {
            firstNameLabel.printError(errorText: "Enter valid name")
            firstNameField.redBorder()
        }
       
    }

    @IBAction func lastNameChanged(_ sender: UITextField) {

        if nameIsValid(uname: sender.text) {
            lastNameLabel.text = "Last Name"
            lastNameLabel.textColor = UIColor.white
            lastNameField.whiteBorder()
            
        } else {
            lastNameLabel.printError(errorText: "Enter valid last name")
            lastNameField.redBorder()
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
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            lastNameField.resignFirstResponder()
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
}
