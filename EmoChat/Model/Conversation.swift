//
//  Conversation.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//


class Conversation {

    var uuid: String
    var usersInConversation: [User] = []
    var mesagesInConversation: [Message]? = []

    
    init(conversationId: String, usersInConversation: [User], messagesInConversation: [Message]?) {
        
        guard (usersInConversation.count) > 1
        else { return }
        
        self.uuid = conversationId
        self.usersInConversation = usersInConversation
        self.mesagesInConversation = messagesInConversation
        
    }
}

//    init(usersInConversation: [User?]?) {
//
//        self.uuid = Auxiliary.getEmpyUUID()
//        
//        guard let notNullUsersInConversation = usersInConversation else {
//            return
//        }
//
//        self.usersInConversation = notNullUsersInConversation
//    }
//
//    func appendMessage(_ newElement: Message) {
//        mesagesInConversation?.append(newElement)
//    }

//    //MARK:- func. for FireBase use
//    func toAnyObject() -> Any {
//
////        var tempUsersInConversation = linkedTableType()
////        var tempMesagesInConversation = linkedTableType()
////
////        //add table of users
////        if let notNullUsersInConversation = usersInConversation {
////            for itemInArray in notNullUsersInConversation {
////                if let notNullItemInArray = itemInArray {
////                     tempUsersInConversation.updateValue(true,
////                                                         forKey: notNullItemInArray.uuid)
////                }
////            }
////        }
////
////        //add table of convmessages
////        if let notNullMessagesInConversation = mesagesInConversation {
////            for itemInArray in notNullMessagesInConversation {
////                if let notNullItemInArray = itemInArray {
////                    tempMesagesInConversation.updateValue(true,
////                                                        forKey: notNullItemInArray.uuid)
////                }
////            }
////        }
//
////        let tempUsersInConversation = collectDataFromModelInstance(usersInConversation)
////        let tempMesagesInConversation = collectDataFromModelInstance(mesagesInConversation)
//
//
//        return [
//            uuid: ["conversationId": uuid,
//                "usersInConversation": collectDataFromModelInstance(usersInConversation),
//                "mesagesInConversation": collectDataFromModelInstance(mesagesInConversation)]
//
//        ]
//    }

//    private func collectDataFromModelInstance (_ dataInArray: [FireBaseEmoChat?]?) -> linkedTableType {
//        var tempArrayData = linkedTableType()
//
//        if let notNullDataInInstance = dataInArray {
//            for itemInArray in notNullDataInInstance {
//                if let notNullDataInInstance = itemInArray {
//                    tempArrayData.updateValue(true,
//                                              forKey: notNullDataInInstance.uuid)
//                }
//            }
//        }
//        return tempArrayData
//
//    }
    
}

