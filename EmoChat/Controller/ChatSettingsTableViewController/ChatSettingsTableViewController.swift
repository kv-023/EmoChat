//
//  ChatSettingsTableViewController.swift
//  EmoChat
//
//  Created by Vlad on 18.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ChatSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var logoCell = UITableViewCell()
    var addUserCell = UITableViewCell()
    var leaveChatCell = UITableViewCell()
    var userCell = UITableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            logoCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            logoCell.textLabel?.text = "Conversation title"
            
            
            //let img = UIImage.getMixed3Img(image1: UIImage.init(named: "1.png"), image2: UIImage.init(named: "1.png"), image3: UIImage.init(named: "1.png"))
            let img = UIImage.getMi
            logoCell.imageView?.layer.cornerRadius = 30
            logoCell.imageView?.image = UIImage.init(named: "1.png")
            //let img = UIImage.getMixed3Img()
            
            //logoCell.imageView?.image = UIImage.getMixed2Img(UIImage.init(named: "1.png"))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadNewLogo))
            logoCell.imageView?.isUserInteractionEnabled = true
            logoCell.imageView?.addGestureRecognizer(tapGestureRecognizer)
            
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
    
/*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "Users"
        default:
            return ""
        }
    }*/
  
    
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
            return 70
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
        
        //Add image
        
        logoCell.imageView?.contentMode = .scaleAspectFill
        logoCell.imageView?.clipsToBounds = true
        logoCell.imageView?.layer.cornerRadius = 30
        logoCell.imageView?.image = chosenImage
        
        //add image to firebase
        
        
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        /*
         guard let chosenImageData = UIImageJPEGRepresentation(chosenImage, 1) else { return }
         
         //create reference
         
         let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
         
         let metaData = StorageMetadata()
         metaData.contentType = "image/jpeg"
         
         //add to firebase
         
         self.storageRef.child(imagePath).putData(chosenImageData, metadata: metaData) { (metaData, error) in
         
         if let error = error {
         print("Error uploading: \(error)")
         return
         }
         
         
         
         //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         
         
         
         //            dissmiss image picker
         */
        self.dismiss(animated:true, completion: nil)
    }

    
    //MARK: - Mix Photos 
    
        
}
