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
    case successArrayOfConversations([Conversation])
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
    let conversationsRef: DatabaseReference?
    let observerTuplesRef: DatabaseReference?
    let newRef: DatabaseReference?
    public static let shared = ManagerFirebase()
    
    private init () {
        self.ref = Database.database().reference()
        self.storageRef = Storage.storage().reference()
        self.conversationsRef = Database.database().reference()
        self.observerTuplesRef = Database.database().reference()
        self.newRef = Database.database().reference()
    }
    
    //MARK: - Return URLs of members photos
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
    
    
    //MARK: Sign out
    func singOut () -> UserOperationResult {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            return .failure(signOutError.description)
        }
        return .success
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
                //let conversationsID = userSnapshot?["conversations"] as? NSDictionary
                
                //create user without conversations and contacts
                
                let user = User(email: email, username: username, phoneNumber: phonenumber, firstName: firstname, secondName: secondname, photoURL: photoURL, uid: uid)
                
                //get contacts
                let contactsIDs = userSnapshot?["contacts"] as? NSDictionary
                if contactsIDs != nil {
                    user.contacts = self.getUsersFromIDs(ids: contactsIDs!, value: value)
                }
                
                //generate array of conversations
//                if let conversationsArrayId = conversationsID?.allKeys {
//                    user.userConversations = self.sortListOfConversations(self.getConversetionsFromSnapshot(value, accordingTo: conversationsArrayId as! [String], currentUserEmail: email))
//                }
                
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
    func getConversetionsFromSnapshot (_ value: NSDictionary?, accordingTo arrayID: [String], currentUserEmail email: String) -> [Conversation] {
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
            
            let time = conversationSnapshot?["lastMessage"] as? TimeInterval
            let date = (Date(timeIntervalSince1970: time!/1000))
            let conversation = Conversation(conversationId: eachConv,
                                            usersInConversation: [],
                                            messagesInConversation: nil,
                                            lastMessage: lastMessage,
                                            lastMessageTimeStamp: date,
                                            name: "")
            
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
        /*let sortedArray = array.sorted { (cv1, cv2) -> Bool in
            return ((cv1.lastMessage?.time.compare((cv2.lastMessage?.time)!)) != nil)
        }*/
        let sortedArray = array.sorted { (cv1, cv2) -> Bool in
            return ((cv1.lastMessageTimeStamp?.compare(cv2.lastMessageTimeStamp!)) != nil)
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
    func getUserPic (from userURL: String, result: @escaping (UserOperationResult) -> Void) {
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
    
    //Return full resolution photo
    func getUserPicFullResolution (from userURL: String, result: @escaping (UserOperationResult) -> Void) {
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
    

        
    //MARK: - Conversation logo
    func createLogo (selectedUsers: [User], conversationID: String) -> String {
            var array = [UIImage]()
        
            //create reference
            let imagePath = "conversLogos/\(conversationID)/logo.jpg"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
        
            for user in selectedUsers {
                self.getUserPic(from: user.photoURL!, result: { (result) in
                    switch result {
                    case let .successUserPic(img):
                        array.append(img)
                    default: print("Error")
                    }
                })
            }
    
            let finalImage = UIImage.createFinalImg(logoImages: array)
            let imageData = UIImageJPEGRepresentation(finalImage, 1)
 
            self.storageRef.child(imagePath).putData(imageData!, metadata: metaData)
            self.ref?.child("conversations/\(conversationID)/logoURL").setValue(imagePath)
        
            return imagePath
        }
    
    
    func loadLogo (_ image: UIImage, conversationID: String, result: @escaping (UserOperationResult) -> Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            guard let chosenImageData = UIImageJPEGRepresentation(image, 1) else {
                result(.failure(NSLocalizedString("Something went wrong", comment: "Undefined error")))
                return
            }
            
            //create reference
            let imagePath = "conversLogos/\(conversationID)/logo.jpg"
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            //add to firebase
            
            self.storageRef.child(imagePath).putData(chosenImageData, metadata: metaData) { (metaData, error) in
                
                if error != nil {
                    result(.failure((error?.localizedDescription)!))
                } else {
                    self.ref?.child("conversations/\(conversationID)/logoURL").setValue(imagePath)
                    result(.success)
                    
                }
            }
        } else {
            result(.failure(NSLocalizedString("User isn't authenticated", comment: "")))
        }
    }
    
    //MARK: - Update profile
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
        ref?.child("users").queryOrdered(byChild: "username")
            .queryStarting(atValue: text)
            .queryEnding(atValue: text+"\u{f8ff}")
            .observeSingleEvent(of: .value, with: { snapshot in
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
    
    // MARK: - Conversations
    func createConversation(_ members: [User], withName name: String? = nil, completion: @escaping (ConversationOperationResult) -> Void) {
        
        let timeStamp = NSNumber(value:Date().timeIntervalSince1970 * 1000.0)
        let key = ref?.child("conversations").childByAutoId().key
        
        let conversation = Conversation(conversationId: key!,
                                        usersInConversation: members,
                                        messagesInConversation: nil,
                                        lastMessage: nil,
                                        lastMessageTimeStamp: Date(timeIntervalSince1970: TimeInterval(timeStamp.intValue / 1000)),
                                        name: name)
        
        if let refConv = ref?.child("conversations/\(conversation.uuid)") {
            
            var childUpdates = [String : Any] ()
            childUpdates.updateValue(timeStamp.doubleValue, forKey: "lastMessage")
            if members.count > 2 {
                childUpdates.updateValue(conversation.name!, forKey: "name")
            }
            refConv.updateChildValues(childUpdates)
            
            for member in members {
                refConv.child("usersInConversation/\(member.uid!)").setValue(true)
                
                ref?.child("users/\(member.uid!)/conversations/\(conversation.uuid)").setValue(true)
            }
            completion(.successSingleConversation(conversation))
        } else {
            completion(.failure(NSLocalizedString("Conversation was not created", comment: "")))
        }
        
    }
    
    // MARK: - Messages
    func createMessage(conversation: Conversation, sender: User, content:(type: MessageContentType, content: String)) -> MessageOperationResult {
        
        let timeStamp = NSNumber(value:Date().timeIntervalSince1970 * 1000.0)
        let key = ref?.child("conversations/").childByAutoId().key
        
        let message = Message(uid: key!,
            senderId: sender.uid,
            time: Date(timeIntervalSince1970: TimeInterval(timeStamp.intValue / 1000)),
            content: (type: content.type, content: content.content))
        
        if let messageRef = ref?.child("conversations/\(conversation.uuid)/messagesInConversation/\(message.uid!)") {
            
            var childUpdates = [String: Any] ()
            childUpdates.updateValue(message.senderId!, forKey: "senderId")
            childUpdates.updateValue(timeStamp.doubleValue, forKey: "time")
            childUpdates.updateValue(message.content.content, forKey: "content/\((message.content?.type)!)")

            messageRef.updateChildValues(childUpdates)

            ref?.child("conversations/\(conversation.uuid)/lastMessage").setValue(timeStamp.doubleValue)
            return .successSingleMessage(message)
        } else {
            return .failure(NSLocalizedString("Something went wrong", comment: ""))
        }
    }
    
    //MARK: - test
    //some uesr's info was changed
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
            self.ref?.child("conversations/\(eachConv.uuid)/messagesInConversation").queryLimited(toLast: 5).observe(.childAdded, with: {(snapshot) in
                let uidMessage = snapshot.key
                let messageSnapshot = snapshot.value as? NSDictionary
                let message = Message(data: messageSnapshot, uid: uidMessage)
                result(eachConv, message)
            })
        }
    }
    
    func getBunchOfMessages (in conversation: Conversation, startingFrom uid: String, count: Int, result: @escaping ([Message]) -> Void) {
        let newRef = self.ref?.child("conversations/\(conversation.uuid)/messagesInConversation")
            newRef?.queryEnding(atValue: uid).queryLimited(toLast: UInt(count)).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            //let value = snapshot.value as? [String : AnyObject]
                var messages = [Message]()
                for each in snapshot.children {
                    
                    let messageDict = (each as! DataSnapshot).value as? NSDictionary
                    let message = Message(data: messageDict, uid: (each as AnyObject).key)
                    
                    guard message.uid! != uid else{
                        continue
                    }
                    messages.append(message)
                }
                
     //       print(uid)
            result(messages)
        })
        
    }
    
    func isConversationEmpty(_ conversation: Conversation, result: @escaping (Bool) -> Void) {
        let newRef = self.ref?.child("conversations/\(conversation.uuid)/messagesInConversation")
        newRef?.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.childrenCount == 0 {
                result(true)
            } else {
                result(false)
            }})
    }
    
    func isMessageFromCurrentUser (_ message: Message) -> Bool {
        var result = false
        if let uid = Auth.auth().currentUser?.uid {
            result = message.senderId == uid
        }
        return result
    }
    
    //MARK: - tuple array
    
    private func getConversationsIDs(conversatinsIDs: [String : AnyObject],
                                     completionHandler: @escaping ([conversationTuple]) -> Void) {
        
        var conversationsIDs: [conversationTuple] = []
        
        ManagerFirebase.shared.ref?.child("conversations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for key in conversatinsIDs {
                let conversationSnapshot = snapshot.childSnapshot(forPath: "\(key.key)")
                let conversationDict = conversationSnapshot.value as? [String : AnyObject]
                if let timeStamp = conversationDict?["lastMessage"] as? NSNumber {
                    let convTuple = conversationTuple(conversationId: "\(conversationSnapshot.key)",
                                                            timestamp: Date(milliseconds: timeStamp.doubleValue))
                    conversationsIDs.append(convTuple)
                }
            }
            completionHandler(conversationsIDs)
        })
    }
   
    func getSortedConversationsIDs(of user: User, completionHandler: @escaping ([conversationTuple]) ->  Void) {
        
        var sortedConversationsArray: [conversationTuple] = []

        ref?.child("users/\(user.uid!)/conversations").observeSingleEvent(of: .value, with: { [weak self] (conversationIDs) in
            
            let conversationsDict = conversationIDs.value as? [String : AnyObject] ?? [:]
            
            self?.getConversationsIDs(conversatinsIDs: conversationsDict) { (conversationsIDs) in
                sortedConversationsArray = conversationsIDs.sorted(by: { $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970 })
                completionHandler(sortedConversationsArray)
            }
        })
    }
    
    private func getConversation(from conversationDict:[String : AnyObject],
                                 conversationID: String,
                                 withLastMessage message: Message?,
                                 owner user: User) -> Conversation {
        //create conversation's fields
        let timeStamp = conversationDict["lastMessage"] as! NSNumber
        let date = Date(milliseconds: timeStamp.doubleValue)
        
        //define the name of conversation
        var conversationName = ""
        if let name = conversationDict["name"] as? String {
            conversationName = name
        } else {
            let contactsIDs = conversationDict["usersInConversation"] as? [String : AnyObject] ?? [:]
            for user in user.contacts {
                if contactsIDs.keys.contains(user.uid) {
                    if let name = user.firstName, let secondName = user.secondName{
                        conversationName = "\(name) \(secondName)"
                    } else {
                        conversationName = "\(user.username)"
                    }
                }
            }
        }
        
        //create conversation
        return Conversation(conversationId: conversationID,
                            usersInConversation: [],
                            messagesInConversation: nil,
                            lastMessage: message,
                            lastMessageTimeStamp: date,
                            name: conversationName)
    }
    
    
    func getUsersInConversation(conversation: Conversation,completion: @escaping ([User]) -> Void)  {
        
        self.ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let conversationSnapshot = (value?["conversations"] as? NSDictionary)?[conversation.uuid] as? NSDictionary
            let users = self.getUsersFromIDs(ids: conversationSnapshot?["usersInConversation"] as! NSDictionary, value: value)
            completion(users)
            
        })
        
    }
    
    func getConversations(of user: User ,
                          IDs: [conversationTuple],
                          withOffset offset: Int,
                          count: Int,
                          completionHandler: @escaping (ConversationOperationResult) -> Void) {
        
        var conversations: [Conversation] = []
        
        let conversationsDispatchGroup = DispatchGroup()

        ref?.child("conversations").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            
            let upperBound: Int!
            
            if (count + offset) < IDs.count {
                upperBound = count + offset
            } else {
                upperBound = IDs.count
            }
            
            let range = offset..<upperBound
            for conversationTuple in IDs[range] {
                
                if snapshot.childSnapshot(forPath: "\(conversationTuple.conversationId)/messagesInConversation").exists() {
                    
                    conversationsDispatchGroup.enter()
                    
                    let conversationDict = snapshot.childSnapshot(forPath: "\(conversationTuple.conversationId)").value as? [String : AnyObject] ?? [:]
                    
                    if let conversation = self?.getConversation(
                        from: conversationDict,
                        conversationID: conversationTuple.conversationId,
                        withLastMessage: nil,
                        owner: user) {
                        conversations.append(conversation)
                    }

                    self?.getLastMessageOf(conversationID: conversationTuple.conversationId,
                                           from: snapshot,
                                           completionHandler: { (result) in
                        switch result {
                        case let .successSingleMessage(message):
                            
                            let index = conversations.index(where: { (conversation) -> Bool in
                                conversation.uuid == conversationTuple.conversationId
                            })
                            
                            conversations[index!].lastMessage = message
                            
                            conversationsDispatchGroup.leave()
                        default:
                            return
                        }
                    })
                } else {
                    let conversationDict = snapshot.childSnapshot(forPath: "\(conversationTuple.conversationId)").value as? [String : AnyObject] ?? [:]
                    
                    if let conversation = self?.getConversation(
                        from: conversationDict,
                        conversationID: conversationTuple.conversationId,
                        withLastMessage: nil,
                        owner: user) {
                        conversations.append(conversation)
                    }
                }
            }
            conversationsDispatchGroup.notify(queue: DispatchQueue.main, execute: {
                completionHandler(.successArrayOfConversations(conversations))
            })
        }, withCancel: { (error) in
            completionHandler(.failure(error.localizedDescription))
        })
    }
    
    func getSingleConversation(of user: User,
                               tuple: conversationTuple,
                                completionHandler: @escaping (ConversationOperationResult) -> Void){
        
        ref?.child("conversations/\(tuple.conversationId)").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            print(tuple.conversationId)
            
            if snapshot.childSnapshot(forPath: "messagesInConversation").exists() {
                
                self?.getLastMessageOf(conversationID: tuple.conversationId, from: nil, conversationSnapshot: snapshot, completionHandler: { (result) in
                    
                    switch result {
                    case let .successSingleMessage(message):
                        let conversationDict = snapshot.value as? [String : AnyObject] ?? [:]
                        if let conversation = self?.getConversation(from: conversationDict,
                                                                    conversationID: tuple.conversationId,
                                                                    withLastMessage: message,
                                                                    owner: user) {
                            completionHandler(.successSingleConversation(conversation))
                        }
                    default:
                        return
                    }
                })
            } else {
                
                let conversationDict = snapshot.value as? [String : AnyObject] ?? [:]
                if let conversation = self?.getConversation(from: conversationDict,
                                                         conversationID: tuple.conversationId,
                                                         withLastMessage: nil,
                                                         owner: user) {
                    completionHandler(.successSingleConversation(conversation))
                }
            }
        }, withCancel: { (error) in
            completionHandler(.failure(error.localizedDescription))
        })
    }
    
    private func getLastMessageOf(conversationID: String,
                                  from snapshot: DataSnapshot? = nil,
                                  conversationSnapshot: DataSnapshot? = nil,
                                  completionHandler: @escaping (MessageOperationResult) -> Void) {

        let messageRef: DatabaseReference!
        
        if conversationSnapshot != nil {
            messageRef = conversationSnapshot?.childSnapshot(forPath: "messagesInConversation").ref
        } else if snapshot != nil {
            messageRef = snapshot!.childSnapshot(forPath: "\(conversationID)/messagesInConversation").ref
        } else {
            messageRef = ref?.child("conversations/\(conversationID)/messagesInConversation")
        }
        
        messageRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (messagesSnapshot) in
            
            guard messagesSnapshot.exists() else { return }
            //get last message snapshot
            let messageSnapshot = messagesSnapshot.children.allObjects[0] as! DataSnapshot
            
            let messageDict = messageSnapshot.value as? [String : AnyObject] ?? [:]
            
            //time
            let timestamp = messageDict["time"] as! NSNumber
            let date = Date(milliseconds: timestamp.doubleValue)
            //sender
            let senderId = messageDict["senderId"] as? String
            //content
            let contentDict = messageDict["content"] as! [String : String]
            let type = MessageContentType(rawValue: contentDict.first!.key) //(contentDict.first?.key)
            let content = contentDict["text"]
            
            let message = Message(uid: messageSnapshot.key,
                                  senderId: senderId!,
                                  time: date,
                                  content: (type: type!, content: content!))
            
            completionHandler(.successSingleMessage(message))
            
        }, withCancel: { (error) in
            completionHandler(.failure(error.localizedDescription))
        })
    }
    
    func changeLastMessageInConversation (conversation: Conversation) {
        self.getLastMessageOf (conversationID: conversation.uuid) { (result) in
            switch result {
            case .successSingleMessage(let message):
                self.ref?.child("conversations/\(conversation.uuid)/lastMessage").setValue(message.time.timeIntervalSince1970)
            default:
                break
            }
        }
    }
    
    func updateLastMessageOf(_ conversation: Conversation,
                             completionHandler: @escaping (MessageOperationResult) -> Void) {
        self.getLastMessageOf(conversationID: conversation.uuid, from: nil) { (result) in
            switch result {
            case let .successSingleMessage(message):
                completionHandler(.successSingleMessage(message))
            case .failure(let error):
                print(error)
            default:
                print("message not received")
            }
        }
    }
    
    func deleteMessage (_ uid: String, from conversation: Conversation) {
        self.ref?.child("conversations/\(conversation.uuid)/messagesInConversation/\(uid)").removeValue()
        self.changeLastMessageInConversation(conversation: conversation)
    }
    
    func observeDeletionOfMessages (in conversation: Conversation, result: @escaping (String) -> Void) {
        let newRef = self.ref?.child("conversations/\(conversation.uuid)/messagesInConversation")
        newRef?.observe(.childRemoved, with: { (snapshot) in
            result(snapshot.key)
        })
    }
    


    
    func handleAudioSendWith(url: URL, result: @escaping (URL) -> Void) {
  //      if let uid = Auth.auth().currentUser?.uid {
            let fileUrl = url
            let fileName = NSUUID().uuidString + ".m4a"
        
        self.storageRef.storage.reference().child("message_voice").child(fileName).putFile(from: fileUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            if let downloadUrl = metadata?.downloadURL() {
                result(downloadUrl)
                }
            }
     //   }
    }
    
    
    
    
    
    
    
    
    
}


