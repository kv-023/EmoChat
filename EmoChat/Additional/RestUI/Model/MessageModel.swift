//
//  ConversationModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModel: RegexCheckProtocol {

    var message:Message?
    var messageURLData: MessageURLDataType {
        didSet {
            for (key3, value3) in messageURLData {
                print("key: \(key3), value:\(String(describing: value3))")
            }
        }
    }


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

        DispatchQueue.global(qos: .userInitiated).async {

            var tempMessageURLData: MessageURLDataType = [:]
            let downloadGroup = DispatchGroup()

            let arrayOfLinks = self.getArrayOfRegexMatchesForURLInText(text: self.messageText)

            for urlLink in arrayOfLinks {
                downloadGroup.enter()
                RestUIStrategyManager.instance.getDataFromURL(dataType: .urlembed,
                                                              forUrl: urlLink)
                { (urlModel) in
                    tempMessageURLData.updateValue(urlModel,
                                                   forKey: urlLink)

                    downloadGroup.leave()
                }
            }

            downloadGroup.wait()

            DispatchQueue.main.async {
                self.messageURLData = tempMessageURLData
            }
            
        }
        
    }
    
}
