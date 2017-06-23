//
//  ConversationsDataSource.swift
//  EmoChat
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Foundation

typealias conversationTuple = (conversationId: String, timestamp: Date)

class ConversationsDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - constants
    let basicConversationsCount = 10
    
    // MARK: - variables
    private var tupleArray: [conversationTuple] = []
    var currentUser: User!
    var managerFirebase: ManagerFirebase!
    
    // MARK: - tupleArray operations
    func updateTableView(_ tableView: UITableView,
                         completionHandler: @escaping() -> Void) {
        managerFirebase = ManagerFirebase.shared

        ManagerFirebase.shared.getCurrentUser { [weak self] (result) in
            switch result {
            case let .successSingleUser(user):
                self?.currentUser = user
                self?.currentUser.userConversations = []
                self?.managerFirebase.getSortedConversationsIDs(of: user,
                                                                completionHandler: { (sortedConversationsIDs) in
                    self?.tupleArray = sortedConversationsIDs
                    self?.observeConversationTimeStamp(tableView: tableView)
                    self?.managerFirebase.getConversations(of: self!.currentUser,
                                                           IDs: sortedConversationsIDs,
                                                           count: self!.basicConversationsCount,
                                                           completionHandler: { (result) in
                        switch result {
                        case let .successArrayOfConversations(conversations):
                            self?.currentUser.userConversations = conversations
                            for conv in (self?.currentUser.userConversations)! {
                                print("\(conv.name ?? "NONAME") \(conv.uuid) \(conv.lastMessageTimeStamp!)")
                            }
                            completionHandler()
                        default:
                            print("NONONONO")
                        }
                    })
                    
                })
            default:
                print("SOMETHING WRONG")
            }
        }

    }
    
    // MARK: - SetObservers
    
    private func observeConversationTimeStamp(tableView: UITableView) {
        
        for object in tupleArray {
            
            managerFirebase.ref?.child("conversations/\(object.conversationId)").observe(.childChanged, with: { [weak self] (conversationSnapshot) in
                
                //check if timeStamp has been changed
                if let timestamp = conversationSnapshot.value as? NSNumber {
                    
                    //find index of conversation id in tupleArray
                    if let oldIndex = self?.tupleArray.index(where: { (tuple) -> Bool in
                        tuple.conversationId == conversationSnapshot.ref.parent!.key
                    }) {
                        
                        //set new timeStamp
                        let newTimeStamp = Date(milliseconds: timestamp.intValue)
                        self?.tupleArray[oldIndex].timestamp = newTimeStamp
                        
                        //Change index
                        let changedTuple = self?.tupleArray[oldIndex]
                        self?.tupleArray.remove(at: oldIndex)
                        
                        let newIndex = self!.tupleArray.insertionIndexOf(elem: changedTuple!, isOrderedBefore: { $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970 })
                        //self?.tupleArray.rearrange(from: oldIndex, to: newIndex)
                        self?.tupleArray.insert(changedTuple!, at: newIndex)
                        //make changes in conversations array
                        
                        if ((newIndex <= (self?.currentUser.userConversations?.count)! - 1) && (oldIndex <= (self?.currentUser.userConversations?.count)! - 1)) {
                            //swap cell from oldIndex to newIndex
                            //redraw TableView
                            
                            for conv in (self?.currentUser.userConversations)! {
                                print("\(conv.name ?? "NONAME") \(conv.uuid) \(conv.lastMessageTimeStamp!)")
                            }
                            
                            self?.currentUser.userConversations?.rearrange(from: oldIndex, to: newIndex)
                            
                            for conv in (self?.currentUser.userConversations)! {
                                print("\(conv.name ?? "NONAME") \(conv.uuid) \(conv.lastMessageTimeStamp!)")
                            }
                            
                            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0),
                                              to: IndexPath(row: newIndex , section: 0))
                            
                        } else if newIndex < (self?.currentUser.userConversations?.count)! {
                            
                            //insert this element to userConversations
                            //redraw TableView
                            print("userConversations insert this element")
                            
                        } else if oldIndex < (self!.currentUser.userConversations?.count)! {
                            //userConversations delete this element
                            //userConversations append element from tuple [20] (userConversations.count)
                            print("userConversations delete this element")
                            
                        }
                    }
                }
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let user = currentUser, let count = user.userConversations?.count {
            return count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCellIdentifier", for: indexPath) as! MessageConversationCell
        
        let conversation = currentUser.userConversations![indexPath.row]
        
        cell.conversationNameLabel.text = conversation.name
        cell.lastMessageLabel.text = conversation.lastMessage?.content.content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
}
