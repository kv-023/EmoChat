//
//  ConversationModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class MessageModel: MessageModelGeneric {

    var dataForRestUIInfoView: DataForRestUIInfoView?
    var messageURLData: MessageURLDataType = [:]
    var containsUrlLinks: Bool {
        return messageURLData.count > 0
    }

    var messageURLDataIsReady:Bool = false

    override init() {
        super.init()

    }

    deinit {

        messageURLData = [:]
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
