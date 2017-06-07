//
//  SignUpChooseYourPhotoViewController.swift
//  EmoChat
//
//  Created by 3 on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Firebase

class SignUpChooseYourPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate   {
    
    @IBAction func chooseYourPhotoButton(_ sender: Any) {
        print("button is pressed")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        print(chosenImage.description)
        
        
        //            imageView.image = chosenImage
        
        
        
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let tempimageRef = storageRef.child("images/tmpImage.jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        tempimageRef.putData(UIImageJPEGRepresentation(chosenImage, 0.8)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("upload succesfull")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
        dismiss(animated:true, completion: nil)
    }
}
