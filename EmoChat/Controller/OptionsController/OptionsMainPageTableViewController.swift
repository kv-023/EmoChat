//
//  OptionsMainPageTableViewController.swift
//  EmoChat
//
//  Created by 3 on 09.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsMainPageTableViewController: UITableViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameAndSecondNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let alertCameraError = UIAlertController(title: "Help", message: "Help, help, help!", preferredStyle: UIAlertControllerStyle.alert)
//        alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alertCameraError, animated: true, completion: nil)
     
        
        
        
        
        
        phoneNumberLabel.text = "095 1111111"
        userNameLabel.text = "@alexsmth"
        emailLabel.text = "vitya@i.ua"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func helpMe() {
        print("nihao chiba help")
        
        let alertCameraError = UIAlertController(title: "Help", message: "Help, help, help!", preferredStyle: UIAlertControllerStyle.alert)
        alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertCameraError, animated: true, completion: nil)
    }
    
}
