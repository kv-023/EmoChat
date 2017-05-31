//
//  Messages.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

class Messages {
    var messageId: String = "00000000-0000-0000-0000-000000000000"
    var sender: String? = ""
    var conversation: String? = ""
    
    init(messageId: String, sender: String?, conversation: String?) {
        self.messageId  = messageId
        self.sender = sender
        self.conversation = conversation
    }

    init () {

    }

    convenience init(sender: String?, conversation: String?) {

        self.init()

        self.messageId  = Auxiliary.getUUID()
        self.sender = sender
        self.conversation = conversation
    }

    //MARK:- func. for FireBase use
    func toAnyObject() -> Any {
        return [
            messageId: [
                "messageId": messageId,
                "sender": sender,
                "conversation": conversation]
        ]
    }
}

