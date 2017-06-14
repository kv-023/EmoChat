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
    @IBOutlet weak var warningLabel: UILabel!
    var storageRef: StorageReference!
    var username: String?
    var email: String?
    var password: String?
    var manager: ManagerFirebase?
    var success: Bool = true
    var userImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        self.userPhotoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTaped))
        self.userPhotoView.addGestureRecognizer(tapGesture)
        manager = ManagerFirebase()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTaped() {
        
        //create image picker
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        //handling image picker sourse type
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                let alertCameraError = UIAlertController(title: "Camera Error", message: "Some promlems with camera, use the library", preferredStyle: UIAlertControllerStyle.alert)
                alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertCameraError, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            } else {
                let alertCameraError = UIAlertController(title: "Library error", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.alert)
                alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertCameraError, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        userImage = chosenImage
        
        //add image to view
        userPhotoView.contentMode = .scaleAspectFill
        userPhotoView.clipsToBounds = true
        userPhotoView.layer.cornerRadius = userPhotoView.frame.width/2
        userPhotoView.image = chosenImage
    }
    
    @IBAction func signUpIsPressed(_ sender: UIButton) {
        //add image to firebase
        
        if let image = userImage {
            manager?.addPhoto(image) {
                result in
                self.dismiss(animated:true, completion: nil)
                switch result {
                case .failure(let error):
                    self.warningLabel.text = error
                    self.success = false
                default:
                    break
                }
            }
        }
        if success {
            performSegue(withIdentifier: "confirmation", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmation" {
            let destination: ConfirmationViewController = segue.destination as! ConfirmationViewController
            destination.email = email
            destination.password = password
        }
    }
}
