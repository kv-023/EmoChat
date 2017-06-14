//
//  OptionsChangePhotoNameSecondNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangePhotoNameSecondNameTableViewController: UITableViewController {
    
    @IBOutlet weak var userPhotoView: UIImageView!

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var secondNameTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a right save button and add it to vc
        
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveInformation))
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    func saveInformation(sender: UIBarButtonItem) {
        
        //ad some action
        
        print ("nihao chiba number photo")
        
        //back to previous vc
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}
