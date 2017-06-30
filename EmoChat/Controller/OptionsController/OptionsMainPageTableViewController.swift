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
        
        
        //Temp login and get current user
        currentUser.tempLogIn()
        currentUser.tempGetCurrentUser()


        let nameAndSecondName = "\(currentUser.currentUser?.firstName ?? "Name") \(currentUser.currentUser?.secondName ?? "Lastname")"
        nameAndLastNameLabel.text = nameAndSecondName
        phoneNumberLabel.text = currentUser.currentUser?.phoneNumber
        nameAndLastNameLabel.text = nameAndSecondName
        usernameLabel.text = currentUser.currentUser?.username
        emailLabel.text = currentUser.currentUser?.email

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
        emailLabel.text = user.email
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let segueIdentifier = segue.identifier {
//            switch segueIdentifier {
//            case "showPhotoAndName":
//                let destinationVC = segue.destination as! OptionsChangePhotoNameSecondNameTableViewController
//                destinationVC.currentUser = currentUserVC
//            default:
//                break
//            }
//        }
//    }
}
