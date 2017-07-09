//
//  ConversationModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModel: RegexCheckProtocol {

    weak var message: Message?
    var messageURLData: MessageURLDataType {
        didSet {
//            for (key3, value3) in messageURLData {
//                print("key: \(key3), value:\(String(describing: value3))")
//            }
        }
    }

    var messageURLDataIsReady:Bool = false

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

    deinit {
        messageURLData = [:]
        message = nil
    }

    convenience init(message: Message) {
        self.init()
        self.message = message
    }


    //prepare data for conversation's cell
    func getParseDataFromResource(delaySeconds delay: Int = 0,
                                  completion: @escaping(_ allDone: Bool) -> Void) {
        self.messageURLDataIsReady = false

        //https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + .seconds(delay), execute: {[unowned self] in

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
                self.messageURLDataIsReady = true

                completion(true)
            }
        })
    }
}

//MARK:- MessageModel Hashable

extension MessageModel: Hashable {
    var hashValue: Int {
        return self.uid?.hashValue ?? 0
    }
}

func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
    return lhs.uid == rhs.uid
}
