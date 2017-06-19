//
//  User.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    var uid: String!
    var firstName: String?
    var secondName: String?
    var phoneNumber: String?
    var email:String!
    var username:String!
    var photoURL: String?
    var userConversations: [Conversation]?
    var contacts: [User] = []
    
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.uid, forKey: "uid")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.secondName, forKey: "secondName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phoneNumber, forKey: "phoneNumber")
        aCoder.encode(self.username, forKey: "username")
        aCoder.encode(self.photoURL, forKey: "photoURL")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let uid = aDecoder.decodeObject(forKey: "uid") as! String
        let email = aDecoder.decodeObject(forKey: "email") as! String
        let username = aDecoder.decodeObject(forKey: "username") as! String
        let firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        let secondName = aDecoder.decodeObject(forKey: "secondName") as? String
        let phoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as? String
        let photoURL = aDecoder.decodeObject(forKey: "photoURL") as? String
        
        self.init(email: email, username: username, phoneNumber: phoneNumber, firstName: firstName, secondName: secondName, photoURL: photoURL, uid: uid)
    }
    
    init (email: String, username: String, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?) {
        self.email = email
        self.username = username
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.secondName = secondName
        self.photoURL = photoURL
    }
    
    init (email: String, username: String, phoneNumber: String?, firstName: String?, secondName: String?, photoURL: String?, uid: String!) {
        self.email = email
        self.username = username
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.secondName = secondName
        self.photoURL = photoURL
        self.uid = uid
    }
    
    /*
     Function generates User from snapshot
     */
    init (data: NSDictionary?, uid: String?) {
        
        self.username = data?["username"] as! String
        self.firstName = data?["firstName"] as! String?
        self.secondName = data?["secondName"] as! String?
        self.email = data?["email"] as! String
        self.phoneNumber = data?["phoneNumber"] as! String?
        self.photoURL = data?["photoURL"] as! String?
        self.uid = uid
    }
    
    func getNameOrUsername () -> String {
        var result = ""
        if let firstName = self.firstName {
            result += firstName
            if let secondName = self.secondName {
                result += " \(secondName)"
            }
        } else {
            result += self.username
        }
        return result
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
