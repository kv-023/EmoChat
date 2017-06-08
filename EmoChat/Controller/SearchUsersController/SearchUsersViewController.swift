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
    var m = ManagerFirebase()
    
    var friends: [User] = []
    var filteredFriends: [User] = []
    var checkmarkedFriends: [User] = []
    
    //var refUser: DatabaseReference?
    
    // MARK: - IBOutlets
    @IBOutlet var searchBar: UISearchBar!

    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refUser = Database.database().reference(withPath: "User")
        
        searchBar.showsCancelButton = false
        
        let user1 = User(email: "FirstUser", username: "FirstUser", phoneNumber: nil, firstName: nil, secondName: "secondName", photoURL: nil)
        let user2 = User(email: "SecondUser", username: "SecondUser", phoneNumber: nil, firstName: nil, secondName: nil, photoURL: nil)
        let user3 = User(email: "ThirdUser", username: "ThirdUser", phoneNumber: nil, firstName: "firstName", secondName: "secondName", photoURL: nil)
        let user4 = User(email: "Secvfour", username: "Secvfour", phoneNumber: nil, firstName: nil, secondName: nil, photoURL: nil)
        let user5 = User(email: "Sevfive", username: "Sevfive", phoneNumber: nil, firstName: "firstName", secondName: nil, photoURL: nil)

        friends.append(contentsOf: [user1, user2, user3, user4, user5])
        
        m.filterUsers(with: "olg") { (array) in
            for u in array {
                print(u.username)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            
            if let text = searchBar.text, text.characters.count > 0 || searchBar.isFirstResponder {
                let user = filteredFriends[indexPath.row]
                checkmarkedFriends = checkmarkedFriends.filter {$0 !== user}
            } else {
                let user = friends[indexPath.row]
                checkmarkedFriends = checkmarkedFriends.filter {$0 !== user}
            }

        } else {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            
            if let text = searchBar.text, text.characters.count > 0 || searchBar.isFirstResponder {
                let user = filteredFriends[indexPath.row]
                self.checkmarkedFriends.append(user)
            } else {
                let user = friends[indexPath.row]
                self.checkmarkedFriends.append(user)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
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
        
        var user: User?
        
        if !friends.isEmpty && indexPath.section == 0 && searchBar.isFirstResponder {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifier", for: indexPath) as! ContactCell

            user = filteredFriends[indexPath.row]
            cell.contactUsernameLabel.text = user?.username
            cell.contactNameLabel.text = "\(user?.firstName ?? "") \(user?.secondName ?? "")"
            
            if checkmarkedFriends.contains(user!) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
            
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifier", for: indexPath) as! ContactCell
            
            user = friends[indexPath.row]
            cell.contactUsernameLabel.text = user?.username
            cell.contactNameLabel.text = "\(user?.firstName ?? "") \(user?.secondName ?? "")"

            if checkmarkedFriends.contains(user!) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
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
            if (filterString.characters.count > 0 && !user.username.lowercased().hasPrefix(filterString.lowercased())) {
                continue
            }
            filtered.append(user)
        }
        return filtered
    }
    

}
