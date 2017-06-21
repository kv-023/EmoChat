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
        
        manager = ManagerFirebase.shared
        
        manager.getUserPicFullResolution(from: "userPics/ihn570HNGkY600i6ZUICS6YrqkQ2/519124722475.jpg") {
            result in
            switch result {
            case .successUserPic (let image):
                print(image.description)
            case .failure(let error):
                print(error)
            default:
                break
            }
        }

        //        manager.ref?.child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
        //            let value = snapshot.value as? NSDictionary
        //            self.conversations = self.manager.getConversetionsFromSnapshot(value, accordingTo: ["77777"], currentUserEmail: "blabla@mail.ru")
        //
        //        })
        
        
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
            logoCell.conversLogo.contentMode = .scaleAspectFill
         //   logoCell.conversLogo.image = UIImage.init(named: "1.png")
            
            let arrray: [UIImage] = [UIImage.init(named: "1.png")!, UIImage.init(named: "1.png")!/*, UIImage.init(named: "111.jpg")!, UIImage.init(named: "111.jpg")!, UIImage.init(named: "5.png")!, UIImage.init(named: "6.png")!*/]
            
            //let convers = Conversation(conversationId: <#T##String#>, usersInConversation: <#T##[User]#>, messagesInConversation: <#T##[Message]?#>, lastMessage: <#T##Message?#>)
            var urlsArray = ["userPics/ihn570HNGkY600i6ZUICS6YrqkQ2/519124722475.jpg",
                             "userPics/17zGv3T6C4gzNZllnoDzkIxZxO42/519554976099.jpg"]//manager.getURLsFromConversation((self.conversations?.first!)!)
            
            
            let url = NSURL.fileURL(withPath: "userPics/ihn570HNGkY600i6ZUICS6YrqkQ2/519124722475.jpg")
            let loadedImageData = NSData(contentsOf: url)
           // let imgg = UIImage(data: loadedImageData! as Data)!
           // let ar = [imgg]
        
        //            for index in 0...1 {
        //                manager.getUserPicFullResolution(from: urlsArray[index], result: { (result) in
        //                    switch result {
        //                    case let .successUserPic(image):
        //                        arrray.append(image)
        //                        tableView.reloadData()
        //                    default:
        //                        print("error")
        //
        //                    }
        //
        //                })
        //            }
        
            if let imageData = userDefaults.value(forKey: kDefaultsCellLogo),
                let image = UIImage(data: imageData  as! Data) {
                
                logoCell.conversLogo.image = image
                
            } else {
            
                logoCell.conversLogo.image = UIImage.createFinalImg(logoImages: arrray)
            
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


/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


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
