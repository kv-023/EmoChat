//
//  Message.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

enum MessageContentType {
    case photo
    case video
    case text
}

class Message {
    let uid: String!
    let senderId: String!
    let conversation: String!
    let time: String!
    var content: (type: MessageContentType, content: String)!


    init (uid: String, senderId: String, conversation: String, time: String, content: (type: MessageContentType, content: String))
    {
        self.uid = uid
        self.senderId = senderId
        self.conversation = conversation
        self.time = time
        self.content = content
    }
}
