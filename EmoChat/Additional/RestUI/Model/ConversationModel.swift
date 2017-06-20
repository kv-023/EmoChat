//
//  ConversationModel.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

struct MessageModel {
    var message:Message

    //get data from model
    var senderId: String {
        return message.senderId
    }
    var uid: String? {
        return message.uid
    }
    var time: Date {
        return message.time
    }
    var content:MessageContentDataType {
        return message.content
    }

    //prepare data for conversation cell
    func getParseDataFromResource() {

        RestUIStrategyManager.instance.showData(dataForParse: RestUIStrategy)
    }

}
