//
//  ConversationsDataSource.swift
//  EmoChat
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ConversationsDataSource: NSObject, UITableViewDataSource {
    
    typealias conversationTuple = (conversationId: String, timestamp: Date)
    
    // MARK: - variables
    var tupleArray: [conversationTuple] = []
    var currentUser: User!
    
    
    // MARK: - tupleArray operations
    
    func tmp() {
        ManagerFirebase.shared.getCurrentUser { (result) in
            switch result {
            case let .successSingleUser(user):
                self.currentUser = user
                self.currentUser.userConversations = nil
                self.createTupleArray()
            default:
                print("SOMETHING WRONG")
            }
        }
    }
    // completion: @escaping ([conversationTuple]) -> Void
    func createTupleArray() {
        ManagerFirebase.shared.ref?.child("users/\(self.currentUser.uid!)/conversations").observeSingleEvent(of: .value, with: { (conversationIDs) in
            
            let conversationsDict = conversationIDs.value as? [String : AnyObject] ?? [:]
            for key in conversationsDict {
                ManagerFirebase.shared.ref?.child("conversations/\(key.key)").observe(.childChanged, with: { (conversationSnapshot) in
                    print(conversationSnapshot.ref.parent?.key)
                    print(conversationSnapshot.value)
                    print(conversationSnapshot.key)
                    let timestamp = conversationSnapshot.value as! TimeInterval
                    self.tupleArray.append(conversationTuple(key.key, Date(milliseconds: Int(timestamp))))
                })
            }
        })
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
