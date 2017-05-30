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

        ref = FIRDatabase.database().reference()

        let tempUser:Users = Users(userId: "3", name: "srg", email: "srdg")


        ref?.child("Users").childByAutoId().setValue(tempUser.userId)

        let tempConversation:Conversation = Conversation(conversationId: "123", usersInConversations: [tempUser])

        ref?.child("Conversation").childByAutoId().setValue(tempConversation.conversationId)


        let tempMessage:Messages = Messages(messageId: "4567432",
                                         sender: tempUser.name, conversation: tempConversation.conversationId)
        ref?.child("Message").childByAutoId().setValue(tempMessage.messageId)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

