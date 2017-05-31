//
//  Conversation.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//


class Conversation {
    var conversationId: String = "00000000-0000-0000-0000-000000000000"
    var usersInConversations: [Users?]? = []
    
    init(conversationId: String, usersInConversations: [Users?]?) {
        self.conversationId = conversationId
        if usersInConversations != nil {
            self.usersInConversations = usersInConversations
        }
    }
}
