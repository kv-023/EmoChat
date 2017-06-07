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
    var sectionsArray: [[User]] = []
    var users: [User] = []
    
    var friends: [User] = []
    var filteredFriends: [User] = []
    
    let refUser = Database.database().reference(withPath: "User")
    
    // MARK: - IBOutlets
    @IBOutlet var searchBar: UISearchBar!

    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.showsCancelButton = false
        
        let user1 = User(userId: "FirstUser", name: "FirstUser", email: "FirstUser")
        let user2 = User(userId: "SecondUser", name: "SecondUser", email: "SecondUser")
        let user3 = User(userId: "ThirdUser", name: "ThirdUser", email: "ThirdUser")
        let user4 = User(userId: "Secvfour", name: "Secvfour", email: "Secvfour")
        let user5 = User(userId: "Sevfive", name: "Sevfive", email: "Sevfive")

        friends.append(contentsOf: [user1, user2, user3, user4, user5])
        
        refUser.observe(.value, with: { (snapshot) in
            var newUsers: [User] = []
            for user in snapshot.children {
                let newUser = User(snapshot: user as! DataSnapshot)
                if let us = newUser {
                    print(us)
                    newUsers.append(us)
                }
            }
            self.users = newUsers
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !friends.isEmpty {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !friends.isEmpty && section == 0 {
            if searchBar.isFirstResponder {
                return filteredFriends.count
            }
            return friends.count
        } else {
            return filteredFriends.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        if !friends.isEmpty && indexPath.section == 0 && searchBar.isFirstResponder {
            cell.textLabel?.text = filteredFriends[indexPath.row].uuid
        } else {
            cell.textLabel?.text = friends[indexPath.row].uuid
        }
        
        return cell
    }
    
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(#function)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function)

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(#function)

        self.filteredFriends = searchUsers(self.friends, withFilter: searchText)
        self.tableView.reloadData()
    }
    
    // MARK: - Searching
    func searchUsers(_ array: [User], withFilter filterString: String) -> [User] {
        var filtered: [User] = []
        for user in array {
            if (filterString.characters.count > 0 && !user.uuid.lowercased().hasPrefix(filterString.lowercased())) {
                continue
            }
            filtered.append(user)
        }
        return filtered
    }
    

}
