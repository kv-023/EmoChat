//
//  ConversationsController.swift
//  EmoChat
//
//  Created by Admin on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ConversationsController: UITableViewController {
        
    // MARK: - properties
    let conversationsDataSource = ConversationsDataSource()
    var selectedConversation: Conversation!
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 77
        
        tableView.dataSource = conversationsDataSource
        conversationsDataSource.tableView = tableView
        
        conversationsDataSource.updateTableView(self.tableView) { 
            print(self.conversationsDataSource.currentUser.userConversations!.count)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //download conversations ???
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //change conversations size to 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedConversation = conversationsDataSource.currentUser.userConversations![indexPath.row]
        
        self.performSegue(withIdentifier: "showSingleConversation", sender: self)
    }
    
    // MARK: - UITableViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSingleConversation" {
            let vc = segue.destination as! SingleConversationViewController
            vc.currentConversation = self.selectedConversation
            vc.currentUser = conversationsDataSource.currentUser
          /*  let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem*/
        }
        
    }
}


