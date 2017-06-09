//
//  User.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class User {

//    var userId:String = Auxiliary.getEmpyUUID()
   // var uuid: String = Auxiliary.getEmpyUUID()
    var firstName: String? = nil
    var secondName: String? = nil
    var phoneNumber: String? = nil
    var email:String!
    var username:String!
    var photoURL: String?
    var userConversations: [Conversation]? = []



    
    init (email: String, username: String, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?) {
        self.email = email
        self.username = username
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.secondName = secondName
        self.photoURL = photoURL
    }
    
    
//    init(userId: String, name: String, email: String) {
//        self.uuid = userId
//        self.name = name
//        self.email = email
//        
//    }
//
//    convenience init(name: String = "uknowned", email: String = "no e-mail") {
//        self.init()
//
//        self.uuid = Auxiliary.getUUID()
//        self.name = name
//        self.email = email
//    }

//    func appendConversation(_ newElement: Conversation) {
//        userConversations?.append(newElement)
//    }

//    func appendMessage(_ newElement: Message) {
//        userMessages?.append(newElement)
//    }

//    //MARK:- func. for FireBase use
//    func toAnyObjectInID() -> Any {
//        return [
//            "userId": uuid
//        ]
//    }
//
//    func toAnyObject() -> Any {
//        return [
//            uuid: getDetails()
//        ]
//    }
//
//    func getDetails() -> [String: Any] {
//
//        return ["userId": uuid,
//                "name": name ?? "uknowned",
//                "email":email ?? "no e-mail",
//                "userConversations": collectDataFromModelInstance(userConversations),
//                "userMessages": collectDataFromModelInstance(userMessages)
//        ]
//    }
//
//    class func toAnyObject(users usersInArray:[User]) -> Any {
//        var valueToReturn: [String: Any] = [:]
//
//        for userInArr in usersInArray {
//            valueToReturn.updateValue(userInArr.getDetails(), forKey: userInArr.uuid)
//        }
//
//        return valueToReturn
//    }
}


