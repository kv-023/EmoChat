//
//  ManagerFirebase.swift
//  EmoChat
//
//  Created by Olga Saliy on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//



import Foundation
import Firebase


enum UserOperationResult
{
    case failure(String)
    case successSingleUser(User)
    case successArrayOfUsers([User])
    case successUserPic(UIImage)
    case success
}


enum ConversationOperationResult
{
    case failure(String)
    case successSingleConversation(Conversation)
    case successUpdate(Bool)
    case success
}

enum MessageOperationResult
{
    case failure(String)
    case successSingleMessage(Message)
    case successArrayOfMessages([Message])
    case success
}


class ManagerFirebase {
    
    let ref: DatabaseReference?
    let storageRef: StorageReference
    
    init () {
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
    }
    
    /*
        Function to get all(!!!!) messages in conversation. Need to pass conversation's id
     */
    func getListOfMessages (inConversation uid: String, result: @escaping (MessageOperationResult) -> Void){
            self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                var listOfMessages = [Message]()
                if let conversationMessagesId = ((value?["conversations"] as? NSDictionary)?["\(uid)"] as? NSDictionary)?["messagesInConversation"] as? NSDictionary
                {
                    let messages = value?["messages"] as? NSDictionary
                    for messageID in conversationMessagesId.allKeys {
                        let messsageDictionary = messages?["\(messageID)"] as! NSDictionary
                        listOfMessages.append(Message(data: messsageDictionary, uid: messageID as? String))
                    }
                }
                result(.successArrayOfMessages(listOfMessages))
            })
    }
    
    
    /*
        You can pass a closure which take the result as a string
     */
    func logIn (email: String, password: String, result: @escaping (UserOperationResult) -> Void) {
        Auth.auth().signIn(withEmail: email,
                           password: password,
                           completion: { (user, error) in
                            if user != nil && (user?.isEmailVerified)! {
                                result(.success)
                            } else {
                                if let err = error?.localizedDescription {
                                    result(.failure(err))
                                } else {
                                    result(.failure("Confirm your e-mail"))
                                }
                            }
        })
    }
    
    /*
        You can pass a closure which take the result as a string
     */
    func signUp (email: String, password: String, result: @escaping (UserOperationResult) -> Void) {
        Auth.auth().createUser(withEmail: email,
                               password: password,
                               completion: { (user, error) in
                                
                                if user != nil {
                                    user?.sendEmailVerification(completion: nil) // send verification email
                                    result(.success)
                                } else {
                                    if let err = error?.localizedDescription {
                                        result(.failure(err))
                                    } else {
                                        result(.failure("Confirm your e-mail"))
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
    func addInfoUser (username: String!, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?, result: @escaping (UserOperationResult) -> Void){
        if let user = Auth.auth().currentUser {
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
                result(.success)
        } else {
            result(.failure("User isn't authenticated"))
        }
    }
    
    /*
        Generate array of User from array of their ids
     */
    private func getUsersFromIDs (ids: NSDictionary, value: NSDictionary?) -> [User] {
        //dictionary of users's id
        let value = value?["users"] as? NSDictionary
        var users = [User]()
        for id in ids.allKeys {
            if let user = value?["\(id)"] as? NSDictionary{
                users.append(User(data: user))
            }
        }
        return users
    }
    
    
    
    
    private func getConversetionsFromSnapshot (_ value: NSDictionary?, accordingTo arrayID: [String], currentUserEmail email: String) -> [Conversation] {
        var conversations = [Conversation]()
        
        for eachConv in arrayID {
            //dictionary with specified conversation
            let conversationSnapshot = (value?["conversations"] as? NSDictionary)?[eachConv] as? NSDictionary
            
            var lastMessageDictionary: NSDictionary?
            var lastMessage: Message?
            
            //id of last message
            if let idLastMessage = conversationSnapshot?["lastMessage"] as? String {
                //dictionary of last message
                lastMessageDictionary = (value?["messages"] as? NSDictionary)?[idLastMessage] as? NSDictionary
                lastMessage = Message(data: lastMessageDictionary, uid: idLastMessage)
            }
            
            //members in conversation
            let users = self.getUsersFromIDs(ids: conversationSnapshot?["usersInConversation"] as! NSDictionary,value: value)
            
            let conversation = Conversation(conversationId: eachConv, usersInConversation: users, messagesInConversation: nil, lastMessage: lastMessage)
            
            //define the name of conversation
            var result = ""
            if let name = conversationSnapshot?["name"] as? String {
                result = name
            } else {
                let membersInConversation = users.filter { $0.email != email }
                for member in  membersInConversation{
                    result += "\(member.getNameOrUsername())"
                    if membersInConversation.count > 1 {
                        result += ", "
                    }
                }
            }
            conversation.name = result
            
            conversations.append(conversation)
            }
        return conversations
        
    }
    
    
    
    func addPhoto (_ image: UIImage, result: @escaping (UserOperationResult) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            guard let chosenImageData = UIImageJPEGRepresentation(image, 1) else {
                result(.failure("Something went wrong"))
                return
            }
            
            //create reference
            let imagePath = "userPics/\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            //add to firebase
            
            self.storageRef.child(imagePath).putData(chosenImageData, metadata: metaData) { (metaData, error) in
                
                if error != nil {
                    result(.failure((error?.localizedDescription)!))
                } else {
                    self.ref?.child("users/\(uid)/photo").setValue(imagePath)
                    result(.success)

                }
            }
        } else {
            result(.failure("User isn't authenticated"))
        }
    }
    
    func getUserPic (from userURL: String, result: @escaping (UserOperationResult?) -> Void) {
        let photoRef = storageRef.child(userURL)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        photoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                result(.failure(error.localizedDescription))
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                result(.successUserPic((UIImage(data: data!))!))
            }
        }
    }
    
    func sortListOfConversations (_ array: [Conversation]) -> [Conversation]{

        let sortedArray = array.sorted { (cv1, cv2) -> Bool in
            return ((cv1.lastMessage?.time.compare((cv2.lastMessage?.time)!)) != nil)
        }
        return sortedArray
    }
    
    /*
     Result is the current user with additional info and his conversations (but conversations without messages)
     
     Example how to set fetched info in UI
        m.getCurrentUser(){ user in
        if let u = user, let fN = u.firstName, let sN = u.secondName{
            self.hintsLabel.text = ("\(fN) \(sN)")
     
        }
     }
     */
    func getCurrentUser (getUser: @escaping (UserOperationResult) -> Void) {
        
        if let uid = Auth.auth().currentUser?.uid{
            self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                // .child("users").child(uid)
                
                
                let value = snapshot.value as? NSDictionary
                
                let userSnapshot = (value?["users"] as? NSDictionary)?["\(uid)"] as? NSDictionary
                
                let username = userSnapshot?["username"] as! String
                let firstname = userSnapshot?["firstName"] as! String?
                let secondname = userSnapshot?["secondName"] as! String?
                let email = userSnapshot?["email"] as! String
                let phonenumber = userSnapshot?["phoneNumber"] as! String?
                let photoURL = userSnapshot?["photoURL"] as! String?
                let conversationsID = userSnapshot?["conversations"] as? NSDictionary
                
                var user = User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL)
                
                if let conversationsArrayId = conversationsID?.allKeys {
                    user.userConversations = self.sortListOfConversations(self.getConversetionsFromSnapshot(value, accordingTo: conversationsArrayId as! [String], currentUserEmail: email))
                }
                
                getUser(.successSingleUser(user))
                // ...
            }) { (error) in
                getUser(.failure(error.localizedDescription))
            }
        } else {
            getUser(.failure("User isn't authenticated"))
        }
    }
    
    
    

    func changeUsersEmail(email: String, result: @escaping (UserOperationResult) -> Void) {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            self.ref?.child("users/\(uid)/email").setValue(user.email)
            user.updateEmail(to: email){ error in
                if error != nil {
                    result(.failure(("Something Went Wrong")))
                } else {
                    result(.success)
                }
            }
        } else {
            result(.failure("User isn't authenticated"))
        }
    }
    
    func checkUserNameUniqness(_ userName: String, result : @escaping (UserOperationResult)->Void) {
        
        //let usersRef = Database.database().reference().child("users")
        ref?.child("users").queryOrdered(byChild: "username").queryEqual(toValue: "\(userName)").observeSingleEvent(of: .value , with: {
            snapshot in
            if !snapshot.exists() {
                //print("It seems like this one is free")
                result(.success)
            }
            else {
                print("Taken")
                result(.failure("Username is taken"))
            }
        }) { error in
            result(.failure(error.localizedDescription))
            
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
       let text = text.lowercased()
        ref?.child("users").queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { snapshot in
            var users = [User]()
            for u in snapshot.children{
                users.append(User(data: (u as! DataSnapshot).value as? NSDictionary))
            }
            array(users)
        })
        
    }

    func changeUsersPassword(password: String, result: @escaping (UserOperationResult) -> Void) {
        let user = Auth.auth().currentUser
        let newPassword = password
        user?.updatePassword(to: newPassword) { error in
            if error != nil {
                result(.failure("An error occured."))
            } else {
                result(.success)
            }
        }
    }
    
    
    func getConversationIdFromUser(getId: @escaping ([String]) -> Void)
    {
       
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("users").child("\(uid)").child("conversations")
            ref.queryOrderedByKey().observe(.value, with: { (snapshot) in
                if snapshot.exists()
                {
                     var arrayOfConversationID = [String]()
                    if let conversationID = ((snapshot.value as AnyObject).allKeys)! as? [String]
                    {
                        for id in conversationID
                        {
                            arrayOfConversationID.append(id)
                        }
                    }
                    getId(arrayOfConversationID)
                   
                }
            })
        }
    }
    
    
    
    
    
    
    
    func getAllUsersInvolvedInPersonalConversation(result: @escaping (NSDictionary) -> Void) {
        var dictResult = [String: Bool]()
        var setOfUniqueUsersInvolvedInPersonalConversation = Set<String>()
        
        if let uid = Auth.auth().currentUser?.uid
        {
            
        
            self.getConversationIdFromUser() { arrayOfConversationID in
            for id in arrayOfConversationID {
                let ref = Database.database().reference().child("conversations").child("\(id)").child("usersInConversation")
                ref.queryOrderedByKey().observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                        if let usersInConversation = ((snapshot.value as AnyObject).allKeys)! as? [String]{
                            if usersInConversation.count == 2 // two users - means tet-a-tet (personal) conversation
                            {
                                for user in usersInConversation {
                                    if user != uid {
                                    let result = setOfUniqueUsersInvolvedInPersonalConversation.insert(user)
                                    if result.inserted {
                                        dictResult.updateValue(true, forKey: user)
                                    }
                                    }
                                }
                            }
                            result(dictResult as NSDictionary)
                        }
                    }
                })
            }
        }
    }
    }
    
    func getFriends (result: @escaping (UserOperationResult) -> Void) {
        self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.getAllUsersInvolvedInPersonalConversation() {
                res in
                result(.successArrayOfUsers(self.getUsersFromIDs(ids: res, value: value)))
            }
        
        })
        
        
    }
}


