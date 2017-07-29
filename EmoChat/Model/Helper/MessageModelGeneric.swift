//
//  MessageModelGeneric.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 29.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModelGeneric: RegexCheckProtocol, Hashable {
    weak var message: Message?

    //get data from model
    var senderId: String {
        return message?.senderId ?? ""
    }
    var uid: String? {
        return message?.uid
    }
    var time: Date? {
        return message?.time
    }
    var content:MessageContentDataType? {
        return message?.content
    }
    var messageText: String {
        return content?.content ?? ""
    }

    //MARK: class functions
    init() {

    }

    deinit {
        message = nil
    }

    convenience init(message: Message) {
        self.init()
        self.message = message
    }

    //MARK: hashable protocol
    var hashValue: Int {
        return self.uid?.hashValue ?? 0
    }

    static func ==(lhs: MessageModelGeneric, rhs: MessageModelGeneric) -> Bool {
        return lhs.uid == rhs.uid
    }
}
