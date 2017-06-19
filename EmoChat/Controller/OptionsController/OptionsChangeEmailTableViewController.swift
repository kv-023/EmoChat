//
//  OptionsChangeEmailTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeEmailTableViewController: UITableViewController, RegexCheckProtocol {
    
    @IBOutlet weak var changeEmailTextField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var manager: ManagerFirebase?
    
    
    var emailValid = false {
        didSet {
            if !emailValid {
                infoLabel.printError(errorText: NSLocalizedString("Enter valid email", comment: "Valid email warning"))
            } else {
                infoLabel.printOK(okText: NSLocalizedString("Email", comment: "Email without warning"))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = ManagerFirebase()
        
        
        //create a right save button and add it to vc
        
        
    }
    
    func saveEmail(sender: UIBarButtonItem) {
        
        //ad some action
        
        
        //back to previous vc
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func changeEmailAction(_ sender: Any) {
        print ("nihao chiba email")
        
        
        
        
        
        
        
        
        var success = true, unique = true
        
        if changeEmailTextField.text == "" {
            infoLabel.printError(errorText: NSLocalizedString("Enter email", comment: "Empty email"))
            changeEmailTextField.redBorder()
            success = false
        }
        if success
            && emailValid {
            
            
            print("Vdalo vdalo vdalo")
            
//            manager?.changeUsersEmail(email: changeEmailTextField.text!){
//                result in
//                switch result {
//                case .success:
//                    print("Vdalo")
//                case .failure(let error):
//                    self.infoLabel.text = error
//                default:
//                    break
//            }
            
        }
        
        
            
            
            
            
    }
    
    

}









