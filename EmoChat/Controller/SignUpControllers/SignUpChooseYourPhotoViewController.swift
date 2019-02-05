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
	
	@IBOutlet weak var backgroundAnimated: UIImageView!
    @IBOutlet weak var userPhotoView: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var storageRef: StorageReference!
    var username: String?
    var email: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var manager: ManagerFirebase?
    var image: UIImage?
    var edited = false
	let backgroundManager = SwiftyGifManager.defaultManager
	let backgroundGif = UIImage(gifName: "giphy.gif", levelOfIntegrity: 1.0)
	
    var userImage: UIImage?
    var warning: UIAlertController?
    
    override func viewWillAppear(_ animated: Bool) {
        userPhotoView.clipsToBounds = true
		userPhotoView.layer.cornerRadius = 7
		userPhotoView.layer.borderWidth = 1
		userPhotoView.layer.borderColor = UIColor.black.cgColor
        activityIndicator.isHidden = true
        if let picture = image {
            userImage = picture
            userPhotoView.image = picture
        }
    }
    
    override func viewDidLoad() {
		
		super.viewDidLoad()
		self.backgroundAnimated.setGifImage(backgroundGif, manager: backgroundManager)

        let storage = Storage.storage()
        storageRef = storage.reference()
        
        self.userPhotoView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTaped))
        self.userPhotoView.addGestureRecognizer(tapGesture)
        manager = ManagerFirebase.shared
        warning = UIAlertController(title: "Warning", message: nil, preferredStyle: .alert)
        warning?.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func imageTaped() {
        
        //create image picker
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        //handling image picker sourse type
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: "") , style: .default, handler: {
            action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                let alertCameraError = UIAlertController(title: NSLocalizedString("Camera Error", comment: ""), message: NSLocalizedString("Some promlems with camera, use the library", comment: "") , preferredStyle: UIAlertController.Style.alert)
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
                let alertCameraError = UIAlertController(title: "Library error", message: "Something went wrong", preferredStyle: UIAlertController.Style.alert)
                alertCameraError.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertCameraError, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "") , style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        guard let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else { return }
        edited = true
        // resize image
        let rectValue:CGFloat = 50
        if (chosenImage.size.height > rectValue || chosenImage.size.width > rectValue) == true {
            userImage = chosenImage.resizeImageWith(newSize:
                CGSize(width: rectValue, height: rectValue))
        }
        //add image to view
        userPhotoView.contentMode = .scaleAspectFill
        userPhotoView.clipsToBounds = true
        userPhotoView.layer.cornerRadius = userPhotoView.frame.width/2
        userPhotoView.image = chosenImage
        self.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func signUpIsPressed(_ sender: UIButton) {
        //add image to firebase
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if let image = userImage {
            if edited {
                manager?.addPhoto(image, previous: nil) {
                    result in
                    switch result {
                    case .success:
                        self.performSegue(withIdentifier: "confirmation", sender: self)
                    case .failure(let error):
                        self.warning?.message = error
                        self.present(self.warning!, animated: true)
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                    default:
                        break
                    }
                }
            } else {
                performSegue(withIdentifier: "confirmation", sender: self)
            }
        } else {
            performSegue(withIdentifier: "confirmation", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmation" {
            let destination: ConfirmationViewController = segue.destination as! ConfirmationViewController
            destination.username = username
            destination.email = email
            destination.password = password
            destination.firstName = firstName
            destination.lastName = lastName
            destination.phoneNumber = phoneNumber
            destination.image = userImage
        }
        if segue.identifier == "additional" {
            let destination: AdditionalViewController = segue.destination as! AdditionalViewController
            destination.username = username
            destination.email = email
            destination.password = password
            destination.firstName = firstName
            destination.lastName = lastName
            destination.phoneNumber = phoneNumber
            destination.image = userImage
        }
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
