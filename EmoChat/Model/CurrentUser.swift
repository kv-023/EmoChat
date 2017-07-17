//
//  CurrentUser.swift
//  EmoChat
//
//  Created by 3 on 21.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import Firebase

class CurrentUser {
    
    static let shared = CurrentUser()
    var manager: ManagerFirebase!
    
    var uid: String!
    
    var firstName: String? {
        didSet {updateInfoOnView?()
        }
    }
    
    var secondName: String? {
        didSet {
            updateInfoOnView?()
        }
    }
    
    var phoneNumber: String? {
        didSet {
            updateInfoOnView?()
        }
    }
    
    var email:String!{
        didSet {
            updateInfoOnView?()
        }
    }
    
    var username:String! {
        didSet {
            updateInfoOnView?()
        }
    }
    
    var photoURL: String?
    
    var photo: UIImage? {
        didSet {
            updateInfoOnView?()
        }
    }
    var userConversations: [Conversation]?
    var contacts: [User] = []
    
    var updateInfoOnView: (() -> Void)?
    
    
    
    
    private init() {}
    
    // MARK: -  Login
    func logIn() {
        manager = ManagerFirebase.shared
        manager.logIn(email: "zellensky@gmail.com", password: "qwerty") {
            result in
            switch result {
            case .success:
                print("success login")
                break
            case .failure(let error):
                print("error login \(error)")
            default:
                break
            }
        }
    }
    
    // MARK: -  Get user
    func getCurrentUser() {
        manager.getCurrentUser {
            result in
            switch result {
            case .successSingleUser(let user):
                print("success getUser")
                self.uid = user.uid
                self.firstName = user.firstName
                self.secondName = user.secondName
                self.phoneNumber = user.phoneNumber
                self.email = user.email
                self.photoURL = user.photoURL
                self.username = user.username
                self.userConversations = user.userConversations
                self.contacts = user.contacts
                
                if let optPhotoURL = user.photoURL {
                    self.getUserPicFullResolution(photoURL: optPhotoURL)
                }
                
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
        
    }
    
    // MARK: - Add additional info
    func changeInfo(phoneNumber: String?,
                    firstName: String?,
                    secondName: String?){
        manager?.changeInfo(phoneNumber: phoneNumber,
                            firstName: firstName,
                            secondName: secondName) {
                                result in
                                switch result {
                                case .success:
                                    print("success change name and secondname in firebabe")
                                    
                                    //Change hange name and secondname singleton current user
                                    self.firstName = firstName
                                    self.secondName = secondName
                                    print("success change name and secondname in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    func changePhoneNumber(phoneNumber: String?){
        manager?.changeInfo(phoneNumber: phoneNumber,
                            firstName: nil,
                            secondName: nil) {
                                result in
                                switch result {
                                case .success:
                                    print("success change phone number in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.phoneNumber = phoneNumber
                                    print("success change phone number in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    func changeFirstName(firstName: String?){
        manager?.changeInfo(phoneNumber: nil,
                            firstName: firstName,
                            secondName: nil) {
                                result in
                                switch result {
                                case .success:
                                    print("success change first name in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.firstName = firstName
                                    print("success change first name in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    func changeSecondName(secondName: String?){
        manager?.changeInfo(phoneNumber: nil,
                            firstName: nil,
                            secondName: secondName) {
                                result in
                                switch result {
                                case .success:
                                    print("success change second name in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.secondName = secondName
                                    print("success change second name in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    
    // MARK: - Change email
    func changeEmail(newEmail: String) {
        manager.changeUsersEmail(email: newEmail) {
            result in
            switch result {
            case .success:
                print ("success change email in firebase")
                
                //Save new email to singleton current user
                self.email = newEmail
                print("success change username to singleton current user")
                
            case .failure(let error):
                print(error)
            default:
                break
            }
        }
    }
    
    
    // MARK: - Change username
    func changeUsername(newUsername: String) {
        manager.changeUsername(newUsername: newUsername) {
            result in
            switch result {
            case .success:
                print ("success change username to firebase")
                
                //Save username to singleton current user
                self.username = newUsername
                print("success change username to singleton current user")
                
            case .failure(let error):
                print(error)
            default:
                break
            }
        }
    }
    
    //MARK: - Add user photo
    func addPhoto(chosenImage: UIImage) {
        manager?.addPhoto(chosenImage, previous: nil) {
            result in
            switch result {
            case .success:
                print("success saving photo")
                
                //Save photo to singleton currebt user
                self.photo = chosenImage
                print("success saving photo to singleton current user")
                
            case .failure(let error):
                print("\(error) fail saving photo")
            default:
                break
            }
        }
    }
    
    //MARK: - Get user picture
    func getUserPicFullResolution(photoURL: String) {
        manager.getUserPicFullResolution(from: photoURL) {
            result in
            switch result {
            case .successUserPic(let image):
                print("method \(image)")
                self.photo = image
                
            case . failure(let error):
                print(error)
            default:
                break
            }
        }
    }
    
    
    //MARK: - Sign up
    
    func signUp (email: String, password: String) {
        manager.signUp(email: email, password: password) {
            result in
            switch result {
            case .success:
                print("sign up ok")
            case .failure(let error):
                print("\(error) fail sign up")
            default:
                break
            }
        }
    }
    
    
    
    
}

















