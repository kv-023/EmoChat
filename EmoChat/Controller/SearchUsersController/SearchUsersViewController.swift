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
    let imageStore = ImageStore.shared
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true

        managerFirebase.getCurrentUser { [weak self] (result) in
            switch result {
            case let .successSingleUser(user):
                print(user.username)
                print(user.contacts)
                self?.currentUser = user
                self?.friends = user.contacts
                self?.tableView.reloadData()
            default:
                print("USER NOT FOUND")
            }
        }
        
        let createConversationButton = UIBarButtonItem(title: NSLocalizedString("Create Conversation", comment: ""),
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(createConversationAction(_:)))
        self.navigationItem.rightBarButtonItem = createConversationButton
        createConversationButton.isEnabled = false
        
        setUpSearchBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private functions 
    
    func setUpSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search users...", comment: "")
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue(NSLocalizedString("Done", comment: ""), forKey: "_cancelButtonText")
        let contactsScope = NSLocalizedString("Contacts", comment: "Contacts search section")
        let globalScope = NSLocalizedString("Global search", comment: "Global search section")
        searchController.searchBar.scopeButtonTitles = [contactsScope, globalScope]
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
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
            self.performSegue(withIdentifier: "showUserInfo", sender: self)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellIdentifier", for: indexPath) as! UserCell
        cell.userImageView.image = nil
        let user: User!
        
        if searchType == .contacts {
            user = (searchController.isActive) ? filteredFriends[indexPath.row] : friends[indexPath.row]
            cell.userNameLabel.text = "\(user.firstName ?? "") \(user.secondName ?? "")"
            cell.userUsernameLabel.text = user.username
            
            if checkmarkedFriends.contains(user) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            user = filteredUsers[indexPath.row]
            cell.userNameLabel.text = "\(user.firstName ?? "") \(user.secondName ?? "")"
            cell.userUsernameLabel.text = user.username
            cell.accessoryType = .disclosureIndicator
        }
        
        if let photoURL = user.photoURL, photoURL != "" {
            if let image = imageStore.image(forKey: photoURL) {
                cell.userImageView.image = image
            } else {
                cell.activityIndicator.startAnimating()
                managerFirebase.getUserPicFullResolution(from: photoURL, result: { [weak self] (result) in
                    switch result {
                    case let .successUserPic(userImage):
                        cell.userImageView.image = userImage
                        cell.activityIndicator.stopAnimating()
                        self?.imageStore.setImage(userImage, forKey: photoURL)
                    default:
                        return
                    }
                })
            }
        } else {
            cell.userImageView.image = #imageLiteral(resourceName: "male")
        }
        
        return cell
    }
    
    // MARK: - Searching
    func filterContent(for searchText: String) {
        switch searchType {
        case .contacts:
            filteredFriends = friends.filter({ (friend) -> Bool in
                return friend.username.lowercased().hasPrefix(searchText.lowercased())
            })
            if filteredFriends.count == friends.count && tableView.visibleCells.isEmpty {
                tableView.reloadData()
            }
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - Actions
    func createConversationAction(_ sender: UIBarButtonItem) {
        var usernames = ""
        
        for (index, user) in checkmarkedFriends.enumerated() {
            if index == checkmarkedFriends.count - 1 {
                usernames = "\(usernames) \(user.username!)"
            } else {
                usernames = "\(usernames) \(user.username!), "
            }
        }
        
        let title = NSLocalizedString("New Conversation",
                                      comment: "Create new conversation")
        let message =  NSLocalizedString("Create conversation with",
                                         comment: "Usernames") + " \(usernames) ?"
        let alertController = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { [weak self] (action) in

            let textField = alertController.textFields?.first!
            if textField?.text != "" {
                self?.checkmarkedFriends.append(self!.currentUser)
                self?.managerFirebase.createConversation(self!.checkmarkedFriends,
                                                         withName: textField?.text,
                                                         completion: { (result) in
                    switch result {
                    case .successSingleConversation(_):
                        print("success")

                    default:
                        print("Conversation was not created")
                    }
                })
                self?.checkmarkedFriends.removeLast()
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .destructive, handler: nil)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Enter conversation name",
                                                      comment: "")
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow

        switch segue.identifier {
        case "showUserInfo"?:
            //transfer self.selectedUser to the next viewController
            if searchType == .globalUsers {
                let userInfoVC: UserInfoTableViewController = segue.destination as! UserInfoTableViewController
                userInfoVC.selectedUser = self.selectedUser
                userInfoVC.currentUser = currentUser
                let backItem = UIBarButtonItem()
                backItem.title = NSLocalizedString("Back", comment: "Back button")
                navigationItem.backBarButtonItem = backItem
                
                let user: User!
                user = filteredUsers[(indexPath?.row)!]
                if let photoURL = user.photoURL, photoURL != "" {
                    if let image = imageStore.image(forKey: photoURL) {
                       userInfoVC.selectedUserPhoto = image
                    }
                } else {
                   userInfoVC.selectedUserPhoto = #imageLiteral(resourceName: "question_mark")
                }
   
            }
            print("showUserInfo")
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}

extension SearchUsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

    }
}

extension SearchUsersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.perform(#selector(self.filterContent(for:)),
                     with: searchText,
                     afterDelay: 0.5)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = SearchType(rawValue: selectedScope)!
        tableView.reloadData()
        filterContent(for: searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchType == .globalUsers && searchBar.text == "" || filteredUsers.isEmpty {
            searchType = .contacts
            searchBar.selectedScopeButtonIndex = searchType.rawValue
            filterContent(for: "")
        }
    }

}
