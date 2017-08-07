//
//  OptionsMainPageTableViewController.swift
//  EmoChat
//
//  Created by 3 on 09.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsMainPageTableViewController:  UITableViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameAndLastNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var currentUser: CurrentUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Singleton
        currentUser = CurrentUser.shared
        currentUser.updateInfoOnView = updateInfoOnView
        updateInfoOnView()
        
        currentUser.getCurrentUser()
    
    }
    
    func updateInfoOnView() {
        nameAndLastNameLabel.text = "\(currentUser.firstName ?? "") \(currentUser.secondName ?? "")"
        phoneNumberLabel.text = currentUser.phoneNumber
        usernameLabel.text = currentUser.username
        emailLabel.text = currentUser.email
        userImageView.image = currentUser.photo
    }
    
}
