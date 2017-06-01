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

    var ref: FIRDatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func testFirebase(_ sender: Any) {

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

        ref = FIRDatabase.database().reference()

        let tempUser:Users = Users(userId: "userID123", name: "Galja", email: "galja@ukr.net")
        let tempUser2:Users = Users(userId: "userID009", name: "Petja", email: "petja@gmail.com")

        let usersInArray = [tempUser,tempUser2];
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


        let tempConversation:Conversation = Conversation(conversationId: "conversationId-456", usersInConversation: usersInArray)

//        ref?.child("Conversation").childByAutoId().setValue(tempConversation.conversationId)
 //       ref?.child("Conversation").setValue(tempConversation.toAnyObject())


        let tempMessage:Messages = Messages(messageId: "messageId-789",
                                            sender: tempUser, conversation: tempConversation.uuid)
        ref?.child("Message").setValue(tempMessage.toAnyObject())

//        tempUser.appendConversation(tempConversation)
//        tempUser2.appendConversation(tempConversation)
        if let notNullUsersInConversation = tempConversation.usersInConversation {
            for itemUserConversation in notNullUsersInConversation {
                if let itemUserConversation = itemUserConversation {
                    itemUserConversation.appendConversation(tempConversation)
                }
            }
        }

        ref?.child("Users").setValue(Users.toAnyObject(users: usersInArray))
        
        tempConversation.appendMessage(tempMessage)
        ref?.child("Conversation").setValue(tempConversation.toAnyObject())


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //
    }
    ////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////LOGIN//////////////////////////////////////////
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBAction func buttonSignUp(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            if segmentControl.selectedSegmentIndex == 0 {    // login
                FIRAuth.auth()?.signIn(withEmail: emailTextField.text!,
                                       password: passwordTextField.text!,
                                       completion: { (user, error) in
                if user != nil {
                  print ("success")
                } else {
                    if let myError = error?.localizedDescription {
                        print(myError)
                    } else {
                        print ("Something went wrong")
                    }
                    
                }
                                        
                })
                
            } else {    // sign up
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!,
                                           password: passwordTextField.text!,
                                           completion: { (user, error) in
                
                                            if user != nil {
                                                print ("success")
                                            } else {
                                                if let myError = error?.localizedDescription {
                                                    print(myError)
                                                } else {
                                                    print ("Something went wrong")
                                                }
                                            }
                })
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////LOGIN END//////////////////////////////////////




















