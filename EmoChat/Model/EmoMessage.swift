//
//  EmoMessage.swift
//  EmoChat
//
//  Created by Dmytro Holubovs'kyi on 7/25/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class EmoMessage: Message {
    
    var emoRecorded = false
    
    init(uid: String, senderId: String, time: Date, content: MessageContentDataType, emoRecorded: Bool) {
        super.init(uid: uid, senderId: senderId, time: time, content: content)
        self.emoRecorded = emoRecorded
    }
    
    override init(data: NSDictionary?, uid: String?) {
        super.init(data: data, uid: uid)
        self.emoRecorded = false
    }
}
