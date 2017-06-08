//
//  Conversation.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//


class Conversation {

    var uuid: String
    var usersInConversation: [User] = []
    var messagesInConversation: [Message]? = []
    var lastMessage: Message?

    
    init?(conversationId: String, usersInConversation: [User], messagesInConversation: [Message]?, lastMessage: Message?) {
        
        guard (usersInConversation.count) > 1
        else {
            return nil
        }
        
        self.lastMessage = lastMessage
        self.uuid = conversationId
        self.usersInConversation = usersInConversation
        self.messagesInConversation = messagesInConversation
        
    }
}
