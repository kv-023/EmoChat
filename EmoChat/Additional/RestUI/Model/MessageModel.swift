//
//  ConversationModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModel: RegexCheckProtocol {
    typealias MessageURLDataType = [String:UrlembedModel?]

    var message:Message?
    var messageURLData: MessageURLDataType

    //    fileprivate let concurrentMessageQueue =
    //        DispatchQueue(
    //            label: "com.softserve.EmoChat.messageModelQueue",
    //            attributes: .concurrent)

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

    init() {
        messageURLData = [:]
    }

    convenience init(message: Message) {
        self.init()
        self.message = message
    }


    //prepare data for conversation cell
    func getParseDataFromResource() {
        let queue = DispatchQueue(label: "com.softserve.EmoChat.messageModelQueue",attributes: .concurrent)

        queue.sync {
            var tempMessageURLData: MessageURLDataType = [:]
            let arrayOfLinks = self.getArrayOfRegexMatchesForURLInText(text: self.messageText)

            for urlLink in arrayOfLinks {

                RestUIStrategyManager.instance.getDataFromURL(dataType: .urlembed,
                                                              forUrl: urlLink)
                { (urlModel) in
                    tempMessageURLData.updateValue(urlModel,
                                                    forKey: urlLink)
                }
            }

            DispatchQueue.main.async {
                self.messageURLData = tempMessageURLData
            }
        } //queue.sync
        
    }
    
}
