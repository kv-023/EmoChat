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
    
    @IBOutlet weak var userPhotoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.userPhotoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTaped))
        self.userPhotoView.addGestureRecognizer(tapGesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //add image to view
        
        userPhotoView.contentMode = .scaleAspectFill
        userPhotoView.clipsToBounds = true
        userPhotoView.layer.cornerRadius = userPhotoView.frame.width/2
        userPhotoView.image = chosenImage
        
        //add image to firebase
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        //create reference
        let tempimageRef = storageRef.child("images/tmpImage.jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //add image to base
        tempimageRef.putData(UIImageJPEGRepresentation(chosenImage, 0.8)!, metadata: metaData) { (data, error) in
            if error == nil {
                print("upload succesfull")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imageTaped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false

        
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

        
        
        
        
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            imagePicker.sourceType = .camera
//        } else {
//            imagePicker.sourceType = .photoLibrary
//            
//        }
        present(imagePicker, animated: true, completion: nil)
    }
    

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
