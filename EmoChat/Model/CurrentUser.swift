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
    var currentUser: User?
    var manager: ManagerFirebase!
    
    private init(){}
    
    // MARK: -  Temporary functions
    func tempLogIn() {
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
    
    func tempGetCurrentUser() {
        manager = ManagerFirebase.shared
        manager.getCurrentUser {
            result in
            switch result {
            case .successSingleUser(let user):
                print("success getUser")
                self.currentUser = user
            case .failure(let error):
                print("\(error) fail with getUser")
            default:
                break
            }
        }
    }
    
    // MARK: - Add additional info
    func changePhoneNumber(phoneNumber: String?){
        manager = ManagerFirebase.shared
        manager?.changeInfo(phoneNumber: phoneNumber,
                            firstName: nil,
                            secondName: nil) {
                                result in
                                switch result {
                                case .success:
                                    print("success change phone number in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.currentUser?.phoneNumber = phoneNumber
                                    print("success change phone number in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    func changeFirstName(firstName: String?){
        manager = ManagerFirebase.shared
        manager?.changeInfo(phoneNumber: nil,
                            firstName: firstName,
                            secondName: nil) {
                                result in
                                switch result {
                                case .success:
                                    print("success change first name in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.currentUser?.firstName = firstName
                                    print("success change first name in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
    func changeSecondName(secondName: String?){
        manager = ManagerFirebase.shared
        manager?.changeInfo(phoneNumber: nil,
                            firstName: nil,
                            secondName: secondName) {
                                result in
                                switch result {
                                case .success:
                                    print("success change second name in firebabe")
                                    
                                    //Change phone number singleton current user
                                    self.currentUser?.secondName = secondName
                                    print("success change second name in singleton currentUser")
                                    
                                case .failure(let error):
                                    print(error)
                                default:
                                    break
                                }
        }
    }
    
//    getUserPicFullResolution
    
    
    // MARK: - Change username
    func changeUsername(newUsername: String) {
        manager = ManagerFirebase.shared
        manager.changeUsername(newUsername: newUsername) {
            result in
            switch result {
            case .success:
                print ("success change username in firebase")
                
                //Save new username to singleton current user
                self.currentUser?.username = newUsername
                print("success change username in singleton current user")
                
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
                self.currentUser?.email = newEmail
                print("success change username to singleton current user")
                
            case .failure(let error):
                print(error)
            default:
                break
            }
        }
    }

    





}
