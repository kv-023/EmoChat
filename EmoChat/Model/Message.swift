//
//  Message.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

class Message: FireBaseEmoChat {
    var uuid: String = Auxiliary.getEmpyUUID()
    var sender: User?
    var conversation: String? = ""
    var messageText: String? = "" {
        didSet {
            sender?.appendMessage(self)
        }
    }

    init(messageId: String, sender: User?, conversation: String?) {
        self.uuid  = messageId
        self.sender = sender
        self.conversation = conversation
    }

    init () {
//        sender = "uknowned"
        conversation = "empty"
    }

    convenience init(sender: User?, conversation: String?) {

        self.init()

        self.uuid  = Auxiliary.getUUID()
        self.sender = sender
        self.conversation = conversation
    }

    //MARK:- func. for FireBase use
    func toAnyObject() -> Any {
        return [
            uuid: [
                "messageId": uuid,
                "senderId": sender?.uuid,
                "conversation": conversation]
        ]
    }
}

