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
    @IBOutlet weak var nameAndLastNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var manager: ManagerFirebase!
    
    var currentUserVC: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		manager = ManagerFirebase.shared
        
        tempLogIn()
        tempGetCurrentUser()
        
        
        
        
        
        
        
    }
    
    func tempLogIn() {
		
        manager.logIn(email: "idemche@gmail.com", password: "123456") {
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
    
    func tempGetCurrentUser() {
        manager.getCurrentUser {
            result in
            switch result {
            case .successSingleUser(let user):
                print("success getUser")
                
                self.tempTemp(user: user)
                
                
                break
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
        
    }
    
    
    func tempTemp (user: User) {
        
        
        

        
            
        

        
        nameAndLastNameLabel.text = user.firstName
        usernameLabel.text = user.username
        phoneNumberLabel.text = user.phoneNumber
        emailLabel.text = user.phoneNumber
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhone" {
            let destinationVC = segue.destination as! OptionsChangeNumberTableViewController
            destinationVC.currentUser = currentUserVC
            
        }
    }
    
    
}
