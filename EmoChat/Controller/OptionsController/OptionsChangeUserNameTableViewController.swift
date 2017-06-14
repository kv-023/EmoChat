//
//  OptionsChangeUserNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangeUserNameTableViewController: UITableViewController {
    
    @IBOutlet weak var changeUserNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a right save button and add it to vc
        
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveUserName))
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    func saveUserName(sender: UIBarButtonItem) {
        
        //ad some action
        
        print ("nihao chiba username")
        
        //back to previous vc
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}
