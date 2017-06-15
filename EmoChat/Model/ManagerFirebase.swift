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
    public static let shared = ManagerFirebase()
    
    private init () {
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
    }
    
    
    func getURLsFromConversation(_ conversation: Conversation) -> [String] {
        var arrayOfURLs = [String]()
        for member in conversation.usersInConversation {
            if let url = member.photoURL {
                arrayOfURLs.append(url)
            }
        }
        return arrayOfURLs
    }
    
    //MARK: Delete account
    func deleteAccount (result: @escaping (UserOperationResult)-> Void) {
        if let user = Auth.auth().currentUser {
            user.delete() {
                (error) in
                if let err = error?.localizedDescription {
                    result(.failure(err))
                } else {
                    result(.success)
                }
            }
        }
    }
    
    // MARK: Log In
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
                                    result(.failure(NSLocalizedString("Confirm your e-mail", comment: "Email isn't confirmed")))
                                }
                            }
        })
    }
    
    // MARK: Sign Up
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
                                        result(.failure(NSLocalizedString("Something went wrong", comment: "Undefined error")))
                                    }
                                }
        })

    }
    

    // MARK: - Add additional info
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
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }
    
    
    
    //MARK: Generate name of conversation from array of users
    func generateNameOfConversation (_currentUsersEmail email: String, usersInConversation: [User]) -> String {
        var result = ""
        let membersInConversation = usersInConversation.filter { $0.email != email }
        for member in  membersInConversation{
            result += "\(member.getNameOrUsername())"
            if membersInConversation.count > 1 {
                result += ", "
            }
        }
        return result
    }
    
    //MARK: - Getting the full object of the current user
    /*
     Get authentificated user. Result is the User with additional info and his conversations (but conversations without messages)
     
     Example how to set fetched info in UI
        m?.getCurrentUser(){ op in
            switch op {
            case let .successSingleUser (user):
                if let fN = user.firstName, let sN = user.secondName{
                    self.hintsLabel.text = ("\(fN) \(sN)")
                }
            default :
                break
            }
        }
     */
    func getCurrentUser (getUser: @escaping (UserOperationResult) -> Void) {
        
        if let uid = Auth.auth().currentUser?.uid{
            self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                // .child("users").child(uid)
                
                let value = snapshot.value as? NSDictionary
                
                let userSnapshot = snapshot.childSnapshot(forPath: "users/\(uid)").value as? NSDictionary

                //getting additional info
                let username = userSnapshot?["username"] as! String
                let firstname = userSnapshot?["firstName"] as! String?
                let secondname = userSnapshot?["secondName"] as! String?
                let email = userSnapshot?["email"] as! String
                let phonenumber = userSnapshot?["phoneNumber"] as! String?
                let photoURL = userSnapshot?["photoURL"] as! String?
                //getting array of conversation ids
                let conversationsID = userSnapshot?["conversations"] as? NSDictionary
                
                //create user without conversations and contacts
                let user = User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL)
                
                //generate array of conversations
                if let conversationsArrayId = conversationsID?.allKeys {
                    user.userConversations = self.sortListOfConversations(self.getConversetionsFromSnapshot(value, accordingTo: conversationsArrayId as! [String], currentUserEmail: email))
                    //getting array of contacts
                    user.contacts = self.getContacts(from: user.userConversations)
                }
                
                
                //return result
                getUser(.successSingleUser(user))
            }) { (error) in
                getUser(.failure(error.localizedDescription))
            }
        } else {
            getUser(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
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
                users.append(User(data: user, uid: (id as! String)))
                
            }
        }
        return users
    }
    
    /*
     Generate array of conversation without messages from snapshot
     */
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
                lastMessageDictionary = (conversationSnapshot?["messagesInConversation"] as? NSDictionary)?[idLastMessage] as? NSDictionary
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
                result = self.generateNameOfConversation(_currentUsersEmail: email, usersInConversation: users)
            }
            conversation.name = result
            
            conversations.append(conversation)
        }
        return conversations
        
    }
    
    //to sort list of conversation
    private func sortListOfConversations (_ array: [Conversation]) -> [Conversation]{
        let sortedArray = array.sorted { (cv1, cv2) -> Bool in
            return ((cv1.lastMessage?.time.compare((cv2.lastMessage?.time)!)) != nil)
        }
        return sortedArray
    }
    
    
    
    //MARK: - UserPic
    //Add photo of user's profile to storage and database
    func addPhoto (_ image: UIImage, previous url: String?, result: @escaping (UserOperationResult) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            guard let chosenImageData = UIImageJPEGRepresentation(image, 1) else {
                result(.failure(NSLocalizedString("Something went wrong", comment: "Undefined error")))
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
                    if let previousURL = url {
                        self.storageRef.child(previousURL).delete { error in
                            if error != nil {
                                result(.failure(NSLocalizedString("Previous photo wasn't deleted", comment: "") ))
                            }
                        }
                    }
                    self.ref?.child("users/\(uid)/photoURL").setValue(imagePath)
                    result(.success)

                }
            }
        } else {
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }
    
    
    //MARK: Return userPic
    func getUserPic (from userURL: String, result: @escaping (UserOperationResult?) -> Void) {
        let photoRef = storageRef.child(userURL)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        photoRef.getData(maxSize: 1 * 200 * 200) { data, error in
            if let error = error {
                result(.failure(error.localizedDescription))
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                result(.successUserPic((UIImage(data: data!))!))
            }
        }
    }
    
    //Return full resolution photo
    func getUserPicFullResolution (from userURL: String, result: @escaping (UserOperationResult?) -> Void) {
        let photoRef = storageRef.child(userURL)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        photoRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                result(.failure(error.localizedDescription))
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                result(.successUserPic((UIImage(data: data!))!))
            }
        }
    }
    
    

    
    
    //MARK: Update profile
    func changeInfo (phoneNumber: String?, firstName: String?, secondName: String?, result: @escaping (UserOperationResult) -> Void) {
        if let uid = Auth.auth().currentUser?.uid{
            var childUpdates = [String: String] ()
            
            if let phone = phoneNumber {
                childUpdates.updateValue(phone, forKey: "/users/\(uid)/phoneNumber")
            }
            if let firstName = firstName {
                childUpdates.updateValue(firstName, forKey: "/users/\(uid)/firstName")
            }
            if let secondName = secondName {
                childUpdates.updateValue(secondName, forKey: "/users/\(uid)/secondName")
            }
            
            self.ref?.updateChildValues(childUpdates)
            result(.success)
            //have to set new name to currentUser
        } else {
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }

    
    private func setUsername (username: String, uid: String) {
        let childUpdates = ["/users/\(uid)/username": username]
        self.ref?.updateChildValues(childUpdates)
    }
    
    func changeUsername (newUsername: String, result: @escaping (UserOperationResult) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            self.checkUserNameUniqness(newUsername) { param in
                switch param {
                case .success:
                    self.setUsername(username: newUsername, uid: uid)
                    result(.success)
                case let .failure(fail):
                    result(.failure(fail))
                default :
                    break
                }
            }
        } else {
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }
    
    func changeUsersEmail(email: String, result: @escaping (UserOperationResult) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updateEmail(to: email){ error in
                if let error = error?.localizedDescription {
                    result(.failure(error))
                } else {
                    self.ref?.child("users/\(user.uid)/email").setValue(user.email)
                    result(.success)
                }
            }
        } else {
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }
    
    func changeUsersPassword(password: String, result: @escaping (UserOperationResult) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updatePassword(to: password) { error in
                if let error = error?.localizedDescription {
                    result(.failure(error))
                } else {
                    result(.success)
                }
            }
        }
    }
    

//    func updateUserProfilePhoto(_ photoUrl: String) {
//        if let uid = Auth.auth().currentUser?.uid {
//            self.ref?.child("users/\(uid)/photoURL").setValue(photoUrl)
//        }
//    }
    
    
    //MARK: To check if username is unique
    func checkUserNameUniqness(_ userName: String, result : @escaping (UserOperationResult)->Void) {
        ref?.child("users").queryOrdered(byChild: "username").queryEqual(toValue: "\(userName)").observeSingleEvent(of: .value , with: {
            snapshot in
            if !snapshot.exists() {
                result(.success)
            }
            else {
                result(.failure(NSLocalizedString("Username is taken", comment: "Username isn't unique") ))
            }
        }) { error in
            result(.failure(error.localizedDescription))
            
        }

    }

    //MARK: To search users with a prefix specified. Return array of User
    /*
        Example for using
        m?.filterUsers(with: "olg"){array in
            for u in array {
                print(u.username)
            }
        }
     */
    func filterUsers (with text: String, result: @escaping (UserOperationResult) -> Void){
       let text = text.lowercased()
        ref?.child("users").queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { snapshot in
            var users = [User]()
            for u in snapshot.children{
                users.append(User(data: (u as! DataSnapshot).value as? NSDictionary, uid: snapshot.key))
            }
            result(.successArrayOfUsers(users))
        })
        
    }

    
    //MARK: Return array of friends (contacts)
    func getContacts(from conversations: [Conversation]) -> [User] {
        var result: [User] = []
        for eachConv in conversations {
            if eachConv.usersInConversation.count == 2 {
                if let companion = eachConv.usersInConversation.filter({$0.email != Auth.auth().currentUser?.email}).first {
                    result.append(companion)
                }
                
            }
        }
        return result
    }
    
    
    
    
    func createConversation(_ members: [User], withName name: String? = nil) -> ConversationOperationResult {
        
        let refConv = ref?.child("conversations").childByAutoId()
        let uid: String = (refConv?.key)!
        
        for member in members {
            ref?.child("conversations/\(uid)/usersInConversation/\(member.uid!)").setValue(true)
        }
        if members.count > 2 {
            ref?.child("conversations/\(uid)/name").setValue(name)
        }
        
        if refConv != nil {
            return .success
        } else {
            return .failure(NSLocalizedString("Something went wrong", comment: "Undefined error"))
        }
        
    }
    
    //MARK: - test
    func valueChanged (action: @escaping (String) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            let namePath = self.ref?.child("users/\(uid)")
            namePath?.observe(.childChanged, with: { (snapshot) in
                action((snapshot.value as? String)!)
                
            })
        }
    }
    
    func updateConversations (getNewConversation: @escaping (Conversation) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            
            let namePath = self.ref?.child("users/\(uid)/conversations")
            namePath?.observe(.childAdded, with: { (snapshot) in
                let idConv = snapshot.key
                self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
                    let users = snapshot.childSnapshot(forPath: "users").value as? NSDictionary
                    let conversation = snapshot.childSnapshot(forPath: "conversations/\(idConv)").value as! NSDictionary
                    
                    let newConv = Conversation(conversationId: idConv, usersInConversation: self.getUsersFromIDs(ids: conversation["usersInConversation"] as! NSDictionary, value: users), messagesInConversation: nil, lastMessage: nil)
                    
                    getNewConversation(newConv)
                })
                //action((snapshot.value as? String)!)
             
                
            })
            
        }
    }
    
    func getMessageFromConversation (_ allConversations: [Conversation], result: @escaping (Conversation, Message) -> Void) {
        for eachConv in allConversations{
            self.ref?.child("conversations/\(eachConv.uuid)/conversations/messagesInConversation").observe(.childAdded, with: {(snapshot) in
                let uidMessage = snapshot.key
                let messageSnapshot = snapshot.value as? NSDictionary
                let message = Message(data: messageSnapshot, uid: uidMessage)
                result(eachConv, message)
            })
        }
        
//            let namePath = self.ref?.child("users/\(uid)/conversations")
//            namePath?.observe(.childAdded, with: { (snapshot) in
//                let idConv = snapshot.key
//                self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
//                    //let users = snapshot.childSnapshot(forPath: "users").value as? NSDictionary
//                    let conversation = snapshot.childSnapshot(forPath: "conversations/\(idConv)").value as! NSDictionary
//                    
//                })
//                //action((snapshot.value as? String)!)
//                
//                
//            })
            
        

        
//        let namePath = self.ref?.child("conversations/conversationId-456")
//        namePath?.observe(.childChanged, with: { (snapshot) in
//            let changedSnap = snapshot.value
//            
//        })
    }
    
    
}


