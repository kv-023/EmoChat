//
//  ViewController.swift
//  EmoChat
//
//  Created by Igor Demchenko on 5/29/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    
    
    
    //var ref: DatabaseReference?
    var m: ManagerFirebase?
    @IBOutlet weak var label: UILabel!
    
    @IBAction func regexTestButtoPressed(_ sender: UIButton) {
        regexTest()
    }
    
    // var user: User!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        m = ManagerFirebase.shared
        
        m?.getCurrentUser(){ (result) in
            switch result {
            case let .successSingleUser(user):
                //self.user = user
                print(user.username)
                print(user.userConversations!)
                self.m?.getMessageFromConversation(user.userConversations!, result: {
                    (conv, message) in
                    print("Message \(message.content) from  \(conv.name!)")
                })
                //                for conv in user.userConversations! {
                //                    self.m?.ref?.child("conversations/\(conv.uuid)/messagesInConversation").observe(.childAdded, with: { (snapshot) in
                //                        print("CHILD ADDED")
                //                    })
            //                }
            default:
                print("NONONO")
            }
        }
        
        //        m?.valueChanged() {
        //            newValue in
        //            self.label.text = newValue
        //        }
        
        //        m?.changeContentOfMessage()
        
        //        m?.updateConversations() {
        //            newConv in
        //                self.label.text = newConv.uuid
        //            print(newConv)
        //        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    @IBAction func hello(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    
    
    
    
    @IBAction func testFirebase(_ sender: Any) {
        //  print((m?.emailIsVerified())!)
        
        
        
        
        
        
        //        m?.changeInfo(phoneNumber: "0940332299", firstName: "bodya", secondName: nil) {op in
        //            switch op {
        //            case let .success:
        //                print("success")
        //
        //            default :
        //                break
        //            }
        //        }
        //
        //
        //        m?.filterUsers(with: "olg"){array in
        //            for u in array {
        //                print(u.username)
        //            }
        //        }
        //        m?.filterUsers(with: "b"){array in
        //            for u in array {
        //                print(u.username)
        //            }
        //        }
        //        m?.filterUsers(with: "b", from: 5, withCount: 5)
        
        //        ref = FIRDatabase.database().reference()
        //
        //        let tempUser:Users = Users(userId: "3", name: "srg", email: "srdg")
        //
        //
        //        ref?.child("Users").childByAutoId().setValue(tempUser.userId)
        //
        //        let tempConversation:Conversation = Conversation(conversationId: "123", usersInConversations: [tempUser])
        //
        //        ref?.child("Conversation").childByAutoId().setValue(tempConversation.conversationId)
        //
        //
        //        let tempMessage:Messages = Messages(messageId: "4567432",
        //                                         sender: tempUser.name, conversation: tempConversation.conversationId)
        //        ref?.child("Message").childByAutoId().setValue(tempMessage.messageId)
        
        //        ref = Database.database().reference()
        //
        //        let tempUser:User = User(userId: "userID123", name: "Galja", email: "galja@ukr.net")
        //        let tempUser2:User = User(userId: "userID009", name: "Petja", email: "petja@gmail.com")
        //
        //        let usersInArray = [tempUser,tempUser2];
        //        var arrayData:[Any] = []
        //        for item in usersInArray {
        //            arrayData.append(item.toAnyObject())
        //        }
        //
        ////        ref?.child("Users").setValue(tempUser.toAnyObject())
        ////        ref?.child("Users").setValue(tempUser2.toAnyObject())
        //        ref?.child("Users").setValue(arrayData)
        
        
        //ref?.child("Users").setValue(tempUser.toAnyObject())
        //        ref?.child("Users").setValue(Users.toAnyObject(users: usersInArray))
        
        //        let ref2: FIRDatabaseReference?// for test only
        //        ref2 = FIRDatabase.database().reference() // for test only
        //        ref2?.child("Users").setValue(tempUser2.toAnyObject())// for test only
        
        
        // let tempConversation:Conversation = Conversation(conversationId: "conversationId-456", usersInConversation: usersInArray)
        
        //        ref?.child("Conversation").childByAutoId().setValue(tempConversation.conversationId)
        //       ref?.child("Conversation").setValue(tempConversation.toAnyObject())
        
        
        //        let tempMessage:Message = Message(messageId: "messageId-789",
        //                                            sender: tempUser, conversation: tempConversation.uuid)
        //        tempMessage.messageText = "hello world!"
        //
        //        ref?.child("Message").setValue(tempMessage.toAnyObject())
        //
        //        tempUser.appendConversation(tempConversation)
        //        tempUser2.appendConversation(tempConversation)
        //        if let notNullUsersInConversation = tempConversation.usersInConversation {
        //            for itemUserConversation in notNullUsersInConversation {
        //                if let itemUserConversation = itemUserConversation {
        //                    itemUserConversation.appendConversation(tempConversation)
        //                }
        //            }
        //        }
        //
        //
        //
        //
        //        ref?.child("User").setValue(User.toAnyObject(users: usersInArray))
        //
        //        tempConversation.appendMessage(tempMessage)
        //        ref?.child("Conversation").setValue(tempConversation.toAnyObject())
        //
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //
    }
    //check manager
    @IBAction func touchCheck(_ sender: Any) {
        
        //        m?.addInfoUser(username: "olgasaliy", phoneNumber: "39999999", firstName: "Olga", secondName: "Saliy", photoURL: nil)
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////LOGIN//////////////////////////////////////////
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var hintsLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func DADADA(_ sender: Any) {
        
        
        /*
         self.m?.addInfoUser(username: "golubovskiy", phoneNumber: "0", firstName: "Dtima", secondName: "Gol", photoURL: nil, result: { (updResult) in
         switch updResult {
         case .success:
         print("Success")
         default:
         return
         }
         
         })
         */
        /*
         let user = User(email: "dadada", username: "dadada", phoneNumber: nil, firstName: nil, secondName: nil, photoURL: nil, uid: "userUID")
         let user1 = User(email: "netnet", username: "netnet", phoneNumber: nil, firstName: nil, secondName: nil, photoURL: nil, uid: "user1UID")
         let user2 = User(email: "user2", username: "user2", phoneNumber: nil, firstName: nil, secondName: nil, photoURL: nil, uid: "user2UID")
         
         
         //m?.createConversation([user, user1, user2], withName: "firstConversation")
         
         //m?.createConversation([user1, user2])
         var conv: Conversation!
         
         switch m!.createConversation([user, user1, user2], withName: "firstConversation") {
         case let .successSingleConversation(conversation):
         conv = conversation
         m?.createMessage(conversation: conversation, sender: conversation.usersInConversation[0], content: (type: .text, content: "Hello dadada"))
         default:
         return
         }
         
         
         
         m?.createMessage(conversation: conv, sender: conv.usersInConversation[1], content: (type: .text, content: "New message"))
         */
        /*
         m?.getCurrentUser(getUser: { (result) in
         switch result {
         case let .successSingleUser(user):
         for conv in user.userConversations! {
         print(conv.uuid)
         self.m?.ref?.child("conversations/\(conv.uuid)/messagesInConversation").observe(.childAdded, with: { (snapshot) in
         print("CHILD ADDED")
         })
         }
         default:
         print("NONONO")
         }
         })
         */
        
        
        
        
    }
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBAction func buttonSignUp(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            if segmentControl.selectedSegmentIndex == 0 {    // login
                
                Auth.auth().signIn(withEmail: emailTextField.text!,
                                   password: passwordTextField.text!,
                                   completion: { (user, error) in
                                    if user != nil && (user?.isEmailVerified)! {
                                        self.hintsLabel.text = ("success! you are in")
                                                ManagerFirebase.shared.getCurrentUser { result in
                                                    switch (result) {
                                                    case .successSingleUser(let user):
                                                        ArchiverManager.shared.saveData(user: user)
                                                    case .failure(let error):
                                                        print(error)
                                                        break
                                                    default:
                                                        break
                                                    }
                                                }
                                        
                                    } else {
                                        if let myError = error?.localizedDescription {
                                            self.hintsLabel.text = myError
                                        } else {
                                            self.hintsLabel.text = ("confirm your e-mail")
                                        }
                                    }
                })
                
            } else {    // sign up
                Auth.auth().createUser(withEmail: emailTextField.text!,
                                       password: passwordTextField.text!,
                                       completion: { (user, error) in
                                        
                                        if user != nil {
                                            user?.sendEmailVerification(completion: nil) // send verification email
                                            self.hintsLabel.text = ("success")
                                        } else {
                                            if let myError = error?.localizedDescription {
                                                self.hintsLabel.text = myError
                                            } else {
                                                self.hintsLabel.text = ("Something went wrong")
                                            }
                                        }
                })
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////LOGIN END//////////////////////////////////////
    
    //MARK:- Regex expression
    
    func regexTest() {
        
        let arrayOfTestedData = ["BlaBlaBla", "Bla_Bla%Bla"]
        let regexLoginPattern = "^[a-zA-Z0-9-]*$"
        
        for itemInArray in arrayOfTestedData {
            let strinIsMatched = Regex.isMatchInString(for: regexLoginPattern, in: itemInArray)
            print ("string is matched: \(strinIsMatched)")
            
        }
        
        
        
    }
    
}




















