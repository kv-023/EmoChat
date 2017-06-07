//
//  SearchUsersViewController.swift
//  EmoChat
//
//  Created by Admin on 06.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit
import Firebase
import CoreFoundation

class SearchUsersViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - properties
    var filteredUsers: [User] = []
    var users: [User] = []
    let refUser = Database.database().reference(withPath: "User")
    var searchActive = false
    
    // MARK: - IBOutlets
    @IBOutlet var searchBar: UISearchBar!

    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.showsCancelButton = false
    
        refUser.observe(.value, with: { (snapshot) in
            var newUsers: [User] = []
            for user in snapshot.children {
                
                let newUser = User(snapshot: user as! DataSnapshot)
                if let us = newUser {
                    print(us)
                    newUsers.append(us)
                }
            }
            print(newUsers)
            
            self.users = newUsers
            self.tableView.reloadData()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredUsers.count
        }
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        if searchActive {
            cell.textLabel?.text = filteredUsers[indexPath.row].uuid
        } else {
            cell.textLabel?.text = users[indexPath.row].uuid
        }

        return cell
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = users.filter({ (user) -> Bool in
            let tmpText = user.uuid
            let range = tmpText.range(of: searchText,
                                           options: NSString.CompareOptions.caseInsensitive,
                                           range: nil,
                                           locale: nil)
            return range != nil
        })
        if filteredUsers.count == 0 {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
}
