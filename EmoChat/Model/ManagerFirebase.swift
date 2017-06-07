//
//  ManagerFirebase.swift
//  EmoChat
//
//  Created by Olga Saliy on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

//sign up, login in

import Foundation
import Firebase

class ManagerFirebase {
    
    let ref: DatabaseReference?
    
    init () {
        self.ref = Database.database().reference()
    }
    
    func updateUserProfilePhoto(_ photoUrl: String) {  // UPDATE NAME AND USERPIC
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = URL(string: photoUrl)
            changeRequest.commitChanges { error in
                if error != nil {
                    print("Something Went Wrong")
                } else {
                    print("Profile successfully updated")
                }
            }
        }
    }
    
    //Add email, uid, username and additional info to database. Call this method after succefull sign up.
    func addInfoUser (username: String!, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?){
        if let user = Auth.auth().currentUser, user.isEmailVerified == true {
            let uid = user.uid
            if let pURL = photoURL {
                self.updateUserProfilePhoto(pURL)
            }
            self.ref?.child("users/\(uid)/username").setValue(username)
            self.ref?.child("users/\(uid)/email").setValue(user.email)
            if let pN = phoneNumber{
                self.ref?.child("users/\(uid)/phoneNumber").setValue(pN)
            }
            if let fN = firstName{
                self.ref?.child("users/\(uid)/firstName").setValue(fN)
            }
            if let sN = secondName{
                self.ref?.child("users/\(uid)/secondName").setValue(sN)
            }
            
        }
    }
    
    func getCurrentUser (getUser: @escaping (User?) -> Void) {
        
        
        if let uid = Auth.auth().currentUser?.uid{
            self.ref?.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                
                var user:User? = nil

                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as! String
                let firstname = value?["firstName"] as! String?
                let secondname = value?["secondName"] as! String?
                let email = value?["email"] as! String
                let phonenumber = value?["phoneNumber"] as! String?
                
                let photoURL: String? = Auth.auth().currentUser?.photoURL?.path
                
                user = User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL)
                getUser(user)
                // ...
            }) { (error) in
                print(error.localizedDescription)
                getUser(nil)
            }
        }
    }
    
    func changeUsersEmail(email: String) {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            self.ref?.child("users/\(uid)/email").setValue(user.email)
            user.updateEmail(to: email)
            { error in
                if error != nil {
                    print("Something Went Wrong")
                } else {
                    print("Email successfully updated")
                }
            }
        }
    }
    
}
