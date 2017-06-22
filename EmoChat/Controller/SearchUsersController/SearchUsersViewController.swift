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
import Foundation

enum SearchType: Int {
    case contacts
    case globalUsers
}

class SearchUsersViewController: UITableViewController {
    
    // MARK: - properties
    var currentUser: User!
    var managerFirebase = ManagerFirebase.shared
    var friends: [User] = []
    var filteredFriends: [User] = []
    var checkmarkedFriends: [User] = [] {
        didSet {
            if checkmarkedFriends.count > 1 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    var filteredUsers: [User] = []
    var searchController: UISearchController!
    var searchType = SearchType.contacts
    var selectedUser: User!
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        managerFirebase.getCurrentUser { (result) in
            switch result {
            case let .successSingleUser(user):
                print(user.username)
                print(user.contacts)
                self.currentUser = user
                self.friends = user.contacts
            default:
                print("NONONO")
            }
        }
        
        let createConversationButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(createConversationAction(_:)))
        
        self.navigationItem.rightBarButtonItem = createConversationButton
        createConversationButton.isEnabled = false
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search users...", comment: "")
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeBarBackgroundImage = UIImage(color: UIColor.white)
        searchController.searchBar.setValue(NSLocalizedString("Done", comment: ""), forKey: "_cancelButtonText")
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch searchType {
        case .contacts:
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                let user = (searchController.isActive) ? filteredFriends[indexPath.row] : friends[indexPath.row]
                checkmarkedFriends = checkmarkedFriends.filter { $0 !== user }
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                let user = (searchController.isActive) ? filteredFriends[indexPath.row] : friends[indexPath.row]
                checkmarkedFriends.append(user)
            }
        case .globalUsers:
            selectedUser = filteredUsers[indexPath.row]
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchType {
        case .contacts:
            if searchController.isActive {
                return filteredFriends.count
            } else {
                return friends.count
            }
        case .globalUsers:
            return filteredUsers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch searchType {
        case .contacts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentifier", for: indexPath) as! ContactCell
            let user = (searchController.isActive) ? filteredFriends[indexPath.row] : friends[indexPath.row]
            cell.contactNameLabel.text = "\(user.firstName ?? "") \(user.secondName ?? "")"
            cell.contactUsernameLabel.text = user.username
            
            if checkmarkedFriends.contains(user) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        case .globalUsers:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellIdentifier", for: indexPath) as! GlobalUserCell
            let user = filteredUsers[indexPath.row]
            cell.userNameSurnameLabel.text = "\(user.firstName ?? "") \(user.secondName ?? "")"
            cell.userUsernameLabel.text = user.username
            
            return cell
        }
    }
    
    // MARK: - Searching
    func filterContent(for searchText: String, scope: SearchType) {
        switch scope {
        case .contacts:
            filteredFriends = friends.filter({ (friend) -> Bool in
                return friend.username.lowercased().hasPrefix(searchText.lowercased())
            })
            tableView.reloadData()
        case .globalUsers:
            if searchText != "" {
                managerFirebase.filterUsers(with: searchText,
                                            result: { (result) in
                                                switch result {
                                                case let .successArrayOfUsers(users):
                                                    self.filteredUsers = users
                                                    self.tableView.reloadData()
                                                default:
                                                    return
                                                }
                })
            } else {
                filteredUsers.removeAll()
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    func createConversationAction(_ sender: UIBarButtonItem) {
        var usernames = ""
        
        for u in checkmarkedFriends {
            usernames = "\(usernames) \(u.username!), "
        }
        
        let title = NSLocalizedString("New Conversation", comment: "Create new conversation")
        let message =  NSLocalizedString("Create conversation with \(usernames) ?", comment: "Usernames")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
        }
        let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showUserInfo"?:
            //transfer self.selectedUser to the next viewController
            print("showUserInfo")
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}

extension SearchUsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText, scope: searchType)
        }
    }
}

extension SearchUsersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = SearchType(rawValue: selectedScope)!
        tableView.reloadData()
        filterContent(for: searchBar.text!, scope: searchType)
        print(self.currentUser.contacts)
        print(self.friends)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchType == .globalUsers && searchBar.text == "" || filteredUsers.isEmpty {
            searchType = .contacts
            searchBar.selectedScopeButtonIndex = searchType.rawValue
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let contactsScope = NSLocalizedString("Contacts", comment: "Contacts search section")
        let globalScope = NSLocalizedString("Global search", comment: "Global search section")
        searchController.searchBar.scopeButtonTitles = [contactsScope, globalScope]
        
        return true
    }
}
