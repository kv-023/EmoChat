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
    @objc func saveInformation(sender: UIBarButtonItem) {
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        guard let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else { return }
        
        //Add image to view
        userPhotoView.image = chosenImage
        
        //Add to firebase and current user
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
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                let alertCameraError =
                    UIAlertController(title: NSLocalizedString("Camera Error", comment: ""),
                                      message: NSLocalizedString("Some promlems with camera, use the library", comment: ""),
                                      preferredStyle: UIAlertController.Style.alert)
                
                alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertCameraError, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            } else {
                let alertCameraError = UIAlertController(title: NSLocalizedString("Library error", comment: ""), message: NSLocalizedString("Something went wrong", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alertCameraError.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                self.present(alertCameraError, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.present(picker, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
