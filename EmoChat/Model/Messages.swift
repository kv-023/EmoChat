//
//  Messages.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

class Mssages {
    var messageId: String = "00000000-0000-0000-0000-000000000000"
    var sender: String? = ""
    var conversation: String? = ""
    
    init(messageId: String, sender: String?, conversation: String?) {
        self.messageId  = messageId
        self.sender = sender
        self.conversation = conversation
        
    }
}

