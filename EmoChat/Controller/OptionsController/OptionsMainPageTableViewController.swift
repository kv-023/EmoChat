//
//  OptionsMainPageTableViewController.swift
//  EmoChat
//
//  Created by 3 on 09.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsMainPageTableViewController:  UITableViewController  {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameAndSecondNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var manager: ManagerFirebase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Temporary logIn
        manager.logIn(email: "zellensky@gmail.com", password: "qwerty") {
            result in
            switch result {
            case .success:
                print("succ!!!!!!!!!!!!!!!!!!!!!!!ess")
            case .failure(let error):
                print("\(error) fail fail fail")
            default:
                print("!@#$^&^%$#EVVFDCDEDD")
                break
            }
        }
        
        
        
//        manager?.getCurrentUser {
//            getUser in
//            switch getUser {
//            case .success:
//                print("SSSSSSS")
//            case .failure(let error):
//                print(error)
//            default:
//                print("def")
//                break
//            }
//        }
        
        
        
        
        
        self.phoneNumberLabel.text = "095 1111111"
        self.userNameLabel.text = "@alexsmth"
        self.emailLabel.text = "vitya@i.ua"
        
        
        
        
    }
    func helpMe() {
        print("nihao chiba help")
        
        let alertCameraError = UIAlertController(title: "Help", message: "Help, help, help!", preferredStyle: UIAlertControllerStyle.alert)
        alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertCameraError, animated: true, completion: nil)
    }
    
}
