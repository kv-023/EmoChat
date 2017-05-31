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

        guard let notNullUsersInConversations = usersInConversations else {
            return
        }

        self.usersInConversations = notNullUsersInConversations
    }

    init(usersInConversations: [Users?]?) {

        self.conversationId = Auxiliary.getUUID()

        guard let notNullUsersInConversations = usersInConversations else {
            return
        }

        self.usersInConversations = notNullUsersInConversations
    }

    func toAnyObject() -> Any {
        var usersInConversations_23 = [String: Bool]()

        if let notNullUsersInConversations = usersInConversations {
            for itemInArray in notNullUsersInConversations {
                if let notNullItemInArray = itemInArray {
                     usersInConversations_23.updateValue(true,
                                                         forKey: notNullItemInArray.userId)
                }
            }
        }

        return [
            conversationId: ["conversationId": conversationId,
                "usersInConversations": usersInConversations_23]
        ]
    }
    
}
