//
//  ManagerFirebase.swift
//  EmoChat
//
//  Created by Olga Saliy on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//



import Foundation
import Firebase

class ManagerFirebase {
    
    let ref: DatabaseReference?
    
    init () {
        self.ref = Database.database().reference()
    }
    
    /*
        You can pass a closure which take the result as a string
     */
    func logIn (email: String, password: String, result: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email,
                           password: password,
                           completion: { (user, error) in
                            if user != nil && (user?.isEmailVerified)! {
                                result("Success")
                            } else {
                                if let myError = error?.localizedDescription {
                                    result(myError)
                                } else {
                                    result("Confirm your e-mail")
                                }
                            }
        })
    }
    
    /*
        You can pass a closure which take the result as a string
     */
    func signUp (email: String, password: String, result: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email,
                               password: password,
                               completion: { (user, error) in
                                
                                if user != nil {
                                    user?.sendEmailVerification(completion: nil) // send verification email
                                    result("Success")
                                } else {
                                    if let err = error?.localizedDescription {
                                        result(err)
                                    } else {
                                        result("Something went wrong")
                                    }
                                }
        })

    }
    
    //??????
    func updateUserProfilePhoto(_ photoUrl: String) {
        if let uid = Auth.auth().currentUser?.uid {
            self.ref?.child("users/\(uid)/photoURL").setValue(photoUrl)

        }
    }
    
    //Add email, uid, username and additional info to database. Call this method after succefull sign up.
    func addInfoUser (username: String!, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?){
        if let user = Auth.auth().currentUser, user.isEmailVerified == true {
            let uid = user.uid
            
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
            if let pURL = photoURL {
                self.ref?.child("users/\(uid)/photoURL").setValue(pURL)
            }
            
        }
    }
    
    
    /*
     Example how to set fetched info in UI
        m.getCurrentUser(){ user in
        if let u = user, let fN = u.firstName, let sN = u.secondName{
            self.hintsLabel.text = ("\(fN) \(sN)")
        }
     }
     */
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
                let photoURL = value?["photoURL"] as! String?
                
                
                user = User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL)
                getUser(user)
                // ...
            }) { (error) in
                print(error.localizedDescription)
                getUser(nil)
            }
        }
    }
    

    /*
     Function generates User from snapshot
     */
    func genarateUser (data:DataSnapshot) -> User {
        let value = data.value as? NSDictionary
        let username = value?["username"] as! String
        let firstname = value?["firstName"] as! String?
        let secondname = value?["secondName"] as! String?
        let email = value?["email"] as! String
        let phonenumber = value?["phoneNumber"] as! String?
        let photoURL = value?["photoURL"] as! String?
        
        return User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL)
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
    
    func checkUserNameUniqness(_ userName: String, result : @escaping (Bool)->Void) {
        
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "username").queryEqual(toValue: "\(userName)").observeSingleEvent(of: .value , with: {
            snapshot in
            if !snapshot.exists() {
                print("It seems like this one is free")
                result(true)
            }
            else {
                print("Taken")
                result(false)
            }
        }) { error in
            print(error.localizedDescription)
        }

    }
    /*
        Example for using
        m?.filterUsers(with: "olg"){array in
            for u in array {
                print(u.username)
            }
        }
     */
    func filterUsers (with text: String, array: @escaping ([User]) -> Void){
        ref?.child("users").queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { snapshot in
            var users = [User]()
            for u in snapshot.children{
                users.append(self.genarateUser(data: u as! DataSnapshot))
            }
            array(users)
        })
        
    }

    


}
    

