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
    
    var currentUser: CurrentUser!
    
    override func viewWillAppear(_ animated: Bool) {

        nameAndLastNameLabel.text = "\(currentUser.firstName ?? "Name") \(currentUser.secondName ?? "Lastname")"
        phoneNumberLabel.text = currentUser.phoneNumber
        usernameLabel.text = currentUser.username
        emailLabel.text = currentUser.email
        userImageView.image = currentUser.photo
        
//        if currentUser.photoURL 
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = CurrentUser.shared
        
        //Temp login and get current user
        currentUser.tempLogIn()
        currentUser.tempGetCurrentUser()
    }
}
