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
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = conversationsDataSource
        
        conversationsDataSource.updateTableView(self.tableView) { 
            print(self.conversationsDataSource.currentUser.userConversations?.count)
            self.tableView.reloadData()
        }
        /*conversationsDataSource.updateTableView {

        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //download conversations ???
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //change conversations size to 20
    }
}


