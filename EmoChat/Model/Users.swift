//
//  Users.swift
//  EmoChat
//
//  Created by Kirill on 5/30/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

class Users {

    var userId:String = Auxiliary.getEmpyUUID()
    var name: String? = "uknowned"
    var email:String? = "no e-mail"
    
    init(userId: String, name: String, email: String) {
        self.userId = userId
        self.name = name
        self.email = email
    }

    convenience init(name: String = "uknowned", email: String = "no e-mail") {
        self.init()

        self.userId = Auxiliary.getUUID()
        self.name = name
        self.email = email
    }

    //MARK:- func. for FireBase use
    func toAnyObjectInID() -> Any {
        return [
            "userId": userId
        ]
    }

    func toAnyObject() -> Any {
        return [
            userId: getDetails()
        ]
    }

    func getDetails() -> [String: Any] {
        return ["userId": userId,
                "name": name ?? "uknowned",
                "email":email ?? "no e-mail"]
    }

    class func toAnyObject(users usersInArray:[Users]) -> Any {
        var valueToReturn: [String: Any] = [:]

        for userInArr in usersInArray {
            valueToReturn.updateValue(userInArr.getDetails(), forKey: userInArr.userId)
        }

        return valueToReturn
    }
}


