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
    var currentUserVC: User!
    var manager: ManagerFirebase!
    var currentUser: CurrentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Manager firebase
        manager = ManagerFirebase.shared
        
        //Current user
        currentUser = CurrentUser.shared
        
        //Temporaru login and get current user
        tempLogIn()
        tempGetCurrentUser()
        
        
        currentUser.phoneNumber = "+123475678765434567898765434567898765456789568"
        print(currentUser.phoneNumber!)
        
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
                self.addInfoOnView(user: user)
                
                
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
        
    }
    
    func addInfoOnView (user: User) {
        
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
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "showPhone":
                let destinationVC = segue.destination as! OptionsChangeNumberTableViewController
                destinationVC.currUser = currentUserVC
            case "showUsername":
                let destinationVC = segue.destination as! OptionsChangeUsernameTableViewController
                destinationVC.currentUser = currentUserVC
            case "showEmail":
                let destinationVC = segue.destination as! OptionsChangeEmailTableViewController
                destinationVC.currentUser = currentUserVC
            case "showPhotoAndName":
                let destinationVC = segue.destination as! OptionsChangePhotoNameSecondNameTableViewController
                destinationVC.currentUser = currentUserVC
            default:
                break
            }
        }
    }
}
