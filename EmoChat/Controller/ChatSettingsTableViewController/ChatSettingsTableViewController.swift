//
//  ChatSettingsTableViewController.swift
//  EmoChat
//
//  Created by Vlad on 18.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Firebase


class ChatSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var logoCell = LogoTableViewCell()
    var addUserCell = UITableViewCell()
    var leaveChatCell = UITableViewCell()
    var userCell = UITableViewCell()
    
    
    var storageRef: StorageReference!
    var manager: ManagerFirebase!
    var conversations: [Conversation]?
    
    let userDefaults = UserDefaults.standard
    let kDefaultsCellLogo = "conversationLogo"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 5
        }
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            logoCell = tableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as! LogoTableViewCell
            
            logoCell.conversTitle.text = "Conversation title"
            logoCell.conversLogo.clipsToBounds = true
            logoCell.conversLogo.layer.cornerRadius =  logoCell.conversLogo.frame.size.height / 2
            logoCell.conversLogo.contentMode = .scaleAspectFit
            
            if let imageData = userDefaults.value(forKey: kDefaultsCellLogo),
                let image = UIImage(data: imageData  as! Data) {
                
                logoCell.conversLogo.image = image
                
            } else {
            
              //  logoCell.conversLogo.image =
            
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadNewLogo))
            logoCell.conversLogo.isUserInteractionEnabled = true
            logoCell.conversLogo.addGestureRecognizer(tapGestureRecognizer)
        
        return logoCell
        
        case 1:
            if indexPath.row == 0 {
                addUserCell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath)
                return addUserCell
            } else {
                leaveChatCell = tableView.dequeueReusableCell(withIdentifier: "leave", for: indexPath)
                return leaveChatCell
            }
            
        default:
            userCell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
            userCell.imageView?.image = UIImage.init(named: "male.png")
            userCell.textLabel?.text = "Name LastName"
            return userCell
        }
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
        if section == 1 {
            return 20
        } else {
            return 0
        }
    
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        switch section {
        case 0:
            return 5
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        switch indexPath.section {
        case 0:
            return 75
        case 1:
            return 40
        default:
            return 50
        }
    
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
        if indexPath.section == 0 {
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    // MARK: Loading New Photo
    func loadNewLogo(tapGestureRecognizer: UITapGestureRecognizer) {
    
        let imagePicker = UIImagePickerController()
    
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    
        let alert = UIAlertController(title: "Image Source", message: "Choose new conversation logo", preferredStyle: .actionSheet)
    
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            }
        }
            )
        )
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        self.present(alert, animated: true, completion: nil)
        self.present(imagePicker, animated: true, completion: nil)
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        guard let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
    
        logoCell.conversLogo.clipsToBounds = true
        logoCell.conversLogo.image = chosenImage
        
        let imgData = UIImageJPEGRepresentation(chosenImage, 1)
        
        userDefaults.set(imgData, forKey: kDefaultsCellLogo)
        self.dismiss(animated:true, completion: nil)
    }



}
