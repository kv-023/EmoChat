//
//  OptionsChangePhotoNameSecondNameTableViewController.swift
//  EmoChat
//
//  Created by 3 on 13.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class OptionsChangePhotoNameSecondNameTableViewController: UITableViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, RegexCheckProtocol {
    
    @IBOutlet weak var userPhotoView: UIImageView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNaneTexField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var manager: ManagerFirebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create a right save button and add it to vc
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveInformation))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        manager = ManagerFirebase()
        
        
        
        
        
        //Temporary logIn
        manager?.logIn(email: "zellensky@gmail.com", password: "qwerty") {
            result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("\(error) fail login")
            default:
                break
            }
            
        }
    }
    
    func saveInformation(sender: UIBarButtonItem) {
        
        print ("nihao chiba information")
        
        //Back to previous vc
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    //MARK: - Image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        //Add image to view
        userPhotoView.contentMode = .scaleAspectFill
        userPhotoView.clipsToBounds = true
        userPhotoView.layer.cornerRadius = userPhotoView.frame.width/2
        userPhotoView.image = chosenImage
        
        //Add image to firebase
        
        
        manager?.addPhoto(chosenImage) {
            result in
            switch result {
            case .success:
                print("photo save normal")
                break
            case .failure(let error):
                print("\(error) fail saving photo")
            default:
                break
            }
            
        }

        //Dissmiss image picker
        self.dismiss(animated:true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func firstNameChanged(_ sender: UITextField) {
        let currentNameIsValid = nameIsValid(uname: sender.text)
        
        if currentNameIsValid {
            infoLabel.text = NSLocalizedString("First Name", comment: "First Name")
            infoLabel.textColor = UIColor.white
        } else {
            infoLabel.printError(errorText: "Enter valid name")
        }
    }
    
    
    @IBAction func lastNameChanged(_ sender: UITextField) {
        let currentLastNameIsValid = lastNameIsValid(uname: sender.text)
        
        if currentLastNameIsValid {
            infoLabel.text = NSLocalizedString("Last Name", comment: "Last Name")
            infoLabel.textColor = UIColor.white
        } else {
            infoLabel.printError(errorText: "Enter valid last name")
        }
    }
    
    @IBAction func setUserPhotoButton(_ sender: Any) {
        
        //Create image picker
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        //Handling image picker sourse type
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
