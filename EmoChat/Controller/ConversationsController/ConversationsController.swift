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
    let conversationDataSource = ConversationsDataSource()
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = conversationDataSource
        conversationDataSource.tmp()
    }    
}


