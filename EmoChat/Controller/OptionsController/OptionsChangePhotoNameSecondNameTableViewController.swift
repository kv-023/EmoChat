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
    var currentUser: CurrentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Singleton
        currentUser = CurrentUser.shared
        
        //Add rigth button item
        let rightButtonItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveInformation))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        //Hide keybord on tap
        self.hideKeyboard()
        
        //Add info in view controller
        firstNameTextField.text = currentUser.firstName
        lastNaneTexField.text = currentUser.secondName
        
        //Add photo
        userPhotoView.contentMode = .scaleAspectFill
        userPhotoView.clipsToBounds = true
        userPhotoView.layer.cornerRadius = userPhotoView.frame.width/2
        userPhotoView.image = currentUser.photo
    }

    //MARK: - Save information method after tap on "save" button
    func saveInformation(sender: UIBarButtonItem) {
        if nameIsValid(uname: firstNameTextField.text!) &&
            lastNameIsValid(uname: lastNaneTexField.text!) {
            currentUser.changeInfo(phoneNumber: nil,
                                   firstName: firstNameTextField.text,
                                   secondName: lastNaneTexField.text)
        }
        //Back to previous vc
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    //MARK: - Image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard var chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        //TODO: add 2 photos to storage - fullsize and compressed
        
        //Resize image (compress)
        let rectValue:CGFloat = 100
        if (chosenImage.size.height > rectValue || chosenImage.size.width > rectValue) == true {
            chosenImage = chosenImage.resizeImageWith(newSize:
                CGSize(width: rectValue, height: rectValue))
        }
        
        //Add image to view
        userPhotoView.image = chosenImage
        
        //Add to firebase and current user
        //TODO: Delete previous photo. Add url of old photo instead of passing nil (in addPhoto method)
        currentUser.addPhoto(chosenImage: chosenImage)
        
        //Dissmiss image picker
        self.dismiss(animated:true, completion: nil)
    }
    
    // MARK: - Actions with editing information
    @IBAction func firstNameChanged(_ sender: UITextField) {
        if nameIsValid(uname: sender.text) {
            infoLabel.text = NSLocalizedString("First Name", comment: "First Name")
            infoLabel.textColor = UIColor.white
        } else {
            infoLabel.printError(errorText: "Enter valid name")
        }
    }
    
    
    @IBAction func lastNameChanged(_ sender: UITextField) {
        if lastNameIsValid(uname: sender.text) {
            infoLabel.text = NSLocalizedString("Last Name", comment: "Last Name")
            infoLabel.textColor = UIColor.white
        } else {
            infoLabel.printError(errorText: "Enter valid last name")
        }
    }
    // MARK: - Set User Photo Button and handling sourses

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
