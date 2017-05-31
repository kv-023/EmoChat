//
//  ViewController.swift
//  EmoChat
//
//  Created by Igor Demchenko on 5/29/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import FirebaseDatabase

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


        ref?.child("Users").setValue(tempUser.toAnyObject())

//        let ref2: FIRDatabaseReference?// for test only
//        ref2 = FIRDatabase.database().reference() // for test only
//        ref2?.child("Users").setValue(tempUser2.toAnyObject())// for test only


        let tempConversation:Conversation = Conversation(conversationId: "conversationId-456", usersInConversations: usersInArray)

//        ref?.child("Conversation").childByAutoId().setValue(tempConversation.conversationId)
        ref?.child("Conversation").setValue(tempConversation.toAnyObject())


        let tempMessage:Messages = Messages(messageId: "messageId-789",
                                            sender: tempUser.name, conversation: tempConversation.conversationId)
        ref?.child("Message").setValue(tempMessage.toAnyObject())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //
    }
    
    
}

