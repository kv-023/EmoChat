//
//  ConversationsDataSource.swift
//  EmoChat
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

typealias conversationTuple = (conversationId: String, timestamp: Date)

class ConversationsDataSource: NSObject, UITableViewDataSource {
    
    
    // MARK: - variables
    var tupleArray: [conversationTuple] = []
    var currentUser: User!
    
    // MARK: - constants
    var managerFirebase: ManagerFirebase!// = ManagerFirebase.shared
    
    // MARK: - tupleArray operations
    func tmp() {
        
        managerFirebase = ManagerFirebase.shared
        
        ManagerFirebase.shared.getCurrentUser { (result) in
            switch result {
            case let .successSingleUser(user):
                self.currentUser = user
                self.currentUser.userConversations = nil
                self.managerFirebase.getSortedConversations(of: self.currentUser, completionHandler: { (sortedConversations) in
                    self.tupleArray = sortedConversations
                    print(self.tupleArray)
                })
            default:
                print("SOMETHING WRONG")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        if let conversationCount = currentUser.userConversations?.count {
        //            return conversationCount
        //        } else {
        //            return 0
        //        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageConversationCell", for: indexPath) as! MessageConversationCell
        
        
        return cell
    }

}
