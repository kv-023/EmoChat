//
//  UserInfoTableViewController.swift
//  EmoChat
//
//  Created by Vlad on 25.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UITableViewController {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var selectedUser: User!
    var selectedUserPhoto: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPic.image = selectedUserPhoto
        
        if let name = selectedUser.firstName, let second = selectedUser.secondName {
            nameLabel.text = name + " " + second
        } else {
            nameLabel.text = selectedUser.username
        }
        
        if let phone = selectedUser.phoneNumber {
            phoneNumber.text = phone
        } else {
            phoneNumber.text = NSLocalizedString("Unknown", comment: "")
            phoneNumber.textColor = .gray
        }
        if let name = selectedUser.firstName {
            navigationItem.title = name
        }
        
        usernameLabel.text = "@" + selectedUser.username

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
