//
//  CurrentUser.swift
//  EmoChat
//
//  Created by 3 on 21.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import Firebase

class CurrentUser {
    static let shared = CurrentUser()
    
    var uid: String!
    var firstName: String?
    var secondName: String?
    var phoneNumber: String?
    var email:String!
    var username:String!
    var photoURL: String?
    var userConversations: [Conversation]?
    var contacts: [User] = []
    
    
}
