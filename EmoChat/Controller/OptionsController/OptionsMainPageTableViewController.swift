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
        
        //Init mamager firebase
        manager = ManagerFirebase.shared
        
        //Temp login and get current user
        tempLogIn()
        tempGetCurrentUser()
        
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
                
                self.tempTemp(user: user)
                
                
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
        
    }
    
    
    func tempTemp (user: User) {
        
        
        manager.getUserPicFullResolution(from: user.photoURL!) {
            result in
            switch result {
            case .successUserPic(let image):
                self.userImageView.image = image
            case . failure(let error):
                print(error)
            default:
                break
            }
        }
        
        let nameAndSecondName = "\(user.firstName ?? "Name") \(user.secondName ?? "Lastname")"
        
        nameAndLastNameLabel.text = nameAndSecondName
        usernameLabel.text = user.username
        phoneNumberLabel.text = user.phoneNumber
        emailLabel.text = user.email
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPhone" {
            let destinationVC = segue.destination as! OptionsChangeNumberTableViewController
            destinationVC.currentUser = currentUserVC
        }
        
        if segue.identifier == "showUsername" {
            let destinationVC = segue.destination as! OptionsChangeUsernameTableViewController
            destinationVC.currentUser = currentUserVC
        }
    }
    
    
}
