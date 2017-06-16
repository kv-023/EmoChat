//
//  ChatSettingsTableViewController.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 16.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ChatSettingsTableViewController: UITableViewController {

    //var users: Int = 0 = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3 
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
            
            case 0: return 1
            
            case 1: return 2
            
            default: return 7
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        var cell2 = LogoTableViewCell()
        
        if indexPath.section == 0 {
            
            cell2 = tableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as! LogoTableViewCell
            cell2.conversLogo.image = UIImage.init(named: "1.png")
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            
                cell = tableView.dequeueReusableCell(withIdentifier: "addUser", for: indexPath)
            
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "leaveChat", for: indexPath)
            
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "users", for: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1:
            return 43
            
        default:
            return 60
        }
        
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Chat Settings"
        } else if section == 2 {
                return "111 users in conversation"
            }
         return ""
        }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
  

}



