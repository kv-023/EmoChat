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
    let conversationsInRequest = 15
    
    // MARK: - variables
    private var tupleArray: [conversationTuple] = []
    var currentUser: User!
    var managerFirebase: ManagerFirebase!
    weak var tableView: UITableView!
    
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
                    self?.observeAddingConversation()
                    self?.observeConversationTimeStamp()
                    self?.managerFirebase.getConversations(of: self!.currentUser,
                                        IDs: sortedConversationsIDs,
                                        withOffset: self?.currentUser.userConversations?.count ?? 0,
                                        count: self!.conversationsInRequest,
                                        completionHandler: { (result) in
                        switch result {
                        case let .successArrayOfConversations(conversations):
                            self?.currentUser.userConversations = conversations
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
    
    func getConversationsFromFirebase() {
        managerFirebase.getConversations(of: currentUser,
                                         IDs: tupleArray,
                                         withOffset: currentUser.userConversations?.count ?? 0,
                                         count: conversationsInRequest) { [weak self] (result) in
            switch result {
            case let .successArrayOfConversations(conversations):
                print(conversations.count)
                
                var newPaths: [IndexPath] = []
                
                let lowerBound = self?.currentUser.userConversations?.count ?? 0
                let upperBound = lowerBound + conversations.count
                let range = lowerBound..<upperBound
                
                for index in range {
                    newPaths.append(IndexPath(row: index, section: 0))
                }
                
                self?.currentUser.userConversations?.append(contentsOf: conversations)
                
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: newPaths, with: .none)
                self?.tableView.endUpdates()
                
                print("\(self!.currentUser.userConversations!.count)")
                
            case let .failure(errorString):
                print(errorString)
            default:
                return
            }
        }
    }

    // MARK: - SetObservers
    
    private func observeAddingConversation() {

        managerFirebase.conversationsRef?.child("users/\(self.currentUser.uid ?? "")/conversations").queryLimited(toLast: 1).observe(.childAdded, with: { [weak self] (snapshot) in
            
            guard self?.tupleArray.contains(where: { (tuple) -> Bool in
                return tuple.conversationId == snapshot.key
            }) == false else {
                return
            }
            
            let tuple = conversationTuple(conversationId: snapshot.key, timestamp: Date())
            
            self?.managerFirebase.getSingleConversation(of: self!.currentUser, tuple: tuple, completionHandler: { (result) in
                
                switch result {
                case let .successSingleConversation(conversation):
                    
                    let tuple = conversationTuple(conversationId: conversation.uuid,
                                                  timestamp: conversation.lastMessageTimeStamp!)
                    let insertIndex = self!.tupleArray.insertionIndexOf(elem: tuple, isOrderedBefore: { $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970 })
                    
                    self?.tupleArray.insert(tuple, at: insertIndex)
                    
                    self?.currentUser.userConversations?.insert(conversation, at: insertIndex)
                    self?.observeConversationTimeStamp()
                    
                    let insertIndexPath = IndexPath(row: insertIndex, section: 0)
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: [insertIndexPath], with: .top)
                    self?.tableView.endUpdates()
                    
                default:
                    return
                }
            })
 
            
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    private func observeConversationTimeStamp() {
        managerFirebase.observerTuplesRef?.removeAllObservers()
        for object in tupleArray {
            
            managerFirebase.observerTuplesRef?.child("conversations/\(object.conversationId)").observe(.childChanged, with: { [weak self] (conversationSnapshot) in
                
                //check if timeStamp has been changed
                if let timestamp = conversationSnapshot.value as? NSNumber {
                    
                    //find index of conversation id in tupleArray
                    if let oldIndex = self?.tupleArray.index(where: { (tuple) -> Bool in
                        tuple.conversationId == conversationSnapshot.ref.parent!.key
                    }) {
                        
                        //set new timeStamp
                        let newTimeStamp = Date(milliseconds: timestamp.doubleValue)
                        self?.tupleArray[oldIndex].timestamp = newTimeStamp
                        
                        //Change index in tupleArray
                        let changedTuple = self?.tupleArray[oldIndex]
                        self?.tupleArray.remove(at: oldIndex)
                        
                        let newIndex = self!.tupleArray.insertionIndexOf(elem: changedTuple!, isOrderedBefore: { $0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970 })
                        
                        self?.tupleArray.insert(changedTuple!, at: newIndex)
                        
                        //make changes in conversations array
                        if ((newIndex <= (self?.currentUser.userConversations?.count)! - 1) && (oldIndex <= (self?.currentUser.userConversations?.count)! - 1)) {
                            //swap cell from oldIndex to newIndex
                            //redraw TableView
                            self?.tableView(self!.tableView,
                                            moveRowAt: IndexPath(row: oldIndex, section: 0),
                                            to: IndexPath(row: newIndex , section: 0))
                        } else if newIndex < (self?.currentUser.userConversations?.count)! {
                            //insert this element to userConversations and delete the last one
                            //redraw TableView
                            
                            let deleteIndexPath = IndexPath(row: self!.currentUser.userConversations!.count - 1, section: 0)
                            self?.tableView(self!.tableView,
                                            commit: .delete,
                                            forRowAt: deleteIndexPath)
                            
                            let insertIndexPath = IndexPath(row: newIndex, section: 0)
                            self?.tableView(self!.tableView,
                                            commit: .insert,
                                            forRowAt: insertIndexPath)
                            
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
        cell.conversationTimeLabel.text = self.getFormattedDate(date: conversation.lastMessageTimeStamp!)

        if let lastMessageText = conversation.lastMessage?.content?.content {
            var lastMessageTextRepresent = lastMessageText
            lastMessageTextRepresent.shrinkUrlAddress()

            cell.lastMessageLabel.text = lastMessageTextRepresent

        } else {
            let defaultMessage = NSLocalizedString("No messages yet",
                                                   comment: "")
            let attributedString = NSAttributedString(string: defaultMessage,
                                            attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.italicSystemFont(ofSize: cell.lastMessageLabel.font.pointSize)]))
            cell.lastMessageLabel.attributedText = attributedString
        }
        
        if indexPath.row == self.currentUser.userConversations!.count - 1 {
            print("\(self.currentUser.userConversations!.count)")
            if self.currentUser.userConversations!.count < self.tupleArray.count {
                getConversationsFromFirebase()
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        //change index
        currentUser.userConversations?.rearrange(from: sourceIndexPath.row,
                                                 to: destinationIndexPath.row)
        //move row
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            //update last message
            let conversation = self.currentUser.userConversations![destinationIndexPath.row]
            self.managerFirebase.updateLastMessageOf(conversation) { [weak self] (result) in
                switch result {
                case let .successSingleMessage(message):
                    self?.currentUser.userConversations![destinationIndexPath.row].lastMessage = message
                    self?.currentUser.userConversations![destinationIndexPath.row].lastMessageTimeStamp = message.time
                    tableView.reloadRows(at: [destinationIndexPath], with: .none)
                default:
                    print("Error: message not received")
                }
            }
        }
        
        tableView.beginUpdates()
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        tableView.endUpdates()
        
        CATransaction.commit()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            currentUser.userConversations?.removeLast()
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        case .insert:
            managerFirebase.getSingleConversation(of: currentUser,
                                                  tuple: tupleArray[indexPath.row],
                                                  completionHandler: { [weak self] (result) in
                switch result {
                case let .successSingleConversation(conversation):
                    self?.currentUser.userConversations?.insert(conversation, at: indexPath.row)
                    self?.tableView.beginUpdates()
                    self?.tableView.insertRows(at: [indexPath], with: .none)
                    self?.tableView.endUpdates()
                default:
                    return
                }
            })
        case .none:
            print("none")
        }
        
    }
    
    // MARK: - help functions
    
    func getFormattedDate(date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return date.formatDate()
        } else if Calendar.current.isDateInYesterday(date){
            return NSLocalizedString("Yesterday", comment: "")
        } else {
            return date.dayFormatStyle()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
