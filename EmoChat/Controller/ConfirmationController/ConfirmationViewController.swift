//
//  ConfirmationViewController.swift
//  EmoChat
//
//  Created by Andrii Tkachuk on 6/14/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    var manager: ManagerFirebase?
    var email: String?
    var password: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = ManagerFirebase()
        emailLabel.text = email
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okIsPressed(_ sender: UIButton) {
        if email != nil {
            manager?.logIn(email: email!, password: password!) {
                result in
                switch result {
                case .success:
                    self.performSegue(withIdentifier: "conversations", sender: self)
                default:
                    self.performSegue(withIdentifier: "login", sender: self)
                }
            }
        } else {
            performSegue(withIdentifier: "login", sender: self)
        }
    }
}
