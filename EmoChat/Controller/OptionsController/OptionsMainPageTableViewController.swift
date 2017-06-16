//
//  OptionsMainPageTableViewController.swift
//  EmoChat
//
//  Created by 3 on 09.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsMainPageTableViewController:  UITableViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, RegexCheckProtocol  {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameAndLastNameLabe: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var manager: ManagerFirebase!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = ManagerFirebase()
        
        tempLogIn()
        
        //Get current user
        manager.getCurrentUser {
            result in
            switch result {
            case .successSingleUser(let user):
                print("success getUser")
                
                self.nameAndLastNameLabe.text = user.firstName! + " " + (user.secondName)!
                self.phoneNumberLabel.text = user.phoneNumber
                self.emailLabel.text = user.email
                self.usernameLabel.text = user.username
                break
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
    }
    
    func tempLogIn() {
        manager.logIn(email: "zellensky@gmail.com", password: "qwerty") {
            result in
            switch result {
            case .success:
                print("success login")
                break
            case .failure(let error):
                print(error)
                print("error login")
            default:
                break
            }
        }
    }
    
    
    
}
