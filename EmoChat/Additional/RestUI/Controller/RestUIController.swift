//
//  RestUIController.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 19.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

struct RestUIController: RegexCheckProtocol {

    static let sharedInstance = RestUIController()

    func testDataFirst() {
        let textDataForTest = "bla-bla bla https://9gag.com/gag/aRjwVVG bla-bla bla"


        let testFireBaseMessage = Message(uid: "0099887766545433",
                                          senderId: "id2222222Id",
                                          time: Date(),
                                          content: (type: MessageContentType.text, content: textDataForTest))
        let newModel = MessageModel(message: testFireBaseMessage)
        newModel.getParseDataFromResource { (allDone) in
            if allDone {
                print ("all tasks were ended!!")
            }
        }
    }
}
