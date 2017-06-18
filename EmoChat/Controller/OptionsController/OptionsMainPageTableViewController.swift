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
        
        manager = ManagerFirebase()
        
//         tempLogIn()
//         tempGetCurrentUser()
        
        
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
    
    func tempGetCurrentUser() {
        manager.getCurrentUser {
            result in
            switch result {
            case .successSingleUser(let user):
                print("success getUser")
                
                self.currentUserVC = user
                
                self.nameAndLastNameLabel.text = user.firstName
                self.usernameLabel.text = user.username
                self.phoneNumberLabel.text = user.phoneNumber
                self.emailLabel.text = user.phoneNumber
                
                break
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhone" {
                let destinationVC = segue.destination as! OptionsChangeNumberTableViewController
                destinationVC.currentUser = currentUserVC
            
        }
    }
    
    
}
/*
 let url = URL(string:(user.photoURL)!)
 let data = try? Data(contentsOf: url!)
 self.userImageView.image = UIImage(data: data!)
 */
