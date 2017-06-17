//
//  ChatSettingsTableViewController.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 16.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ChatSettingsTableViewController: UITableViewController {
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let myimage1 = UIImage(named: "1.png")
        let myimage2 = UIImage(named: "2.png")
        let myimage3 = UIImage(named: "3.png")
        let myimage4 = UIImage(named: "4.png")
        let myimage5 = UIImage(named: "5.png")
        let myimage6 = UIImage(named: "6.png")
        let myimage7 = UIImage(named: "7.png")
        let myimage8 = UIImage(named: "8.png")
        let myimage9 = UIImage(named: "9.png")
        let myimage10 = UIImage(named: "10.png")
        
        var logoImages: Array<UIImage> = []
        
        logoImages.append(myimage1!)
        logoImages.append(myimage2!)
        logoImages.append(myimage3!)
        logoImages.append(myimage4!)
        logoImages.append(myimage5!)
        logoImages.append(myimage6!)
        logoImages.append(myimage7!)
        logoImages.append(myimage8!)
        logoImages.append(myimage9!)
        logoImages.append(myimage10!)
        
        var finalMixedImage = UIImage()
        
        if (logoImages.count == 1) {
            finalMixedImage = logoImages[0]
        } else if (logoImages.count == 2) {
            finalMixedImage = getMixed2Img(image1: logoImages[0], image2: logoImages[1])
        } else if (logoImages.count == 3) {
            finalMixedImage = getMixed3Img(image1: logoImages[0], image2: logoImages[1], image3: logoImages[2])
        } else if (logoImages.count == 4) {
            finalMixedImage = getMixed4Img(image1: logoImages[0], image2: logoImages[1], image3: logoImages[2], image4: logoImages[3])
        } else if (logoImages.count > 4) {
            var tempArray = logoImages
            
            let randomIndex1 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image1 = tempArray[randomIndex1]
            tempArray.remove(at: randomIndex1)
            let randomIndex2 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image2 = tempArray[randomIndex2]
            tempArray.remove(at: randomIndex2)
            let randomIndex3 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image3 = tempArray[randomIndex3]
            tempArray.remove(at: randomIndex3)
            let randomIndex4 = Int(arc4random_uniform(UInt32(tempArray.count)))
            let image4 = tempArray[randomIndex4]
            tempArray.remove(at: randomIndex4)
            finalMixedImage = getMixed4Img(image1: image1, image2: image2, image3: image3, image4: image4)
        }
        
        
    }

    
    func getMixed2Img(image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:image1.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:0, width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    func getMixed3Img(image1: UIImage, image2: UIImage, image3: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:(image2.size.height + image3.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:(size.height/4), width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        image3.draw(in: CGRect(x:image1.size.width, y:image2.size.height, width:image3.size.width, height:image3.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    
    func getMixed4Img(image1: UIImage, image2: UIImage, image3: UIImage, image4: UIImage) -> UIImage {
        
        let size = CGSize(width:(image1.size.width + image2.size.width), height:(image1.size.height + image3.size.height))
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x:0, y:0, width:image1.size.width, height:image1.size.height))
        image2.draw(in: CGRect(x:image1.size.width, y:0, width:image2.size.width, height:image2.size.height))
        image3.draw(in: CGRect(x:0, y:(size.height/2), width:image3.size.width, height:image3.size.height))
        image4.draw(in: CGRect(x:(size.height/2), y:(size.height/2), width:image4.size.width, height:image4.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
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
    
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoCell", for: indexPath) as! LogoTableViewCell
            
            let img = getMixed3Img(image1: UIImage.init(named: "1.png")!,
                                   image2: UIImage.init(named: "2.png")!,
                                   image3: UIImage.init(named: "3.png")!
            )
            
            cell.conversLogo.image = img
            
            return cell
            
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addUser", for: indexPath) as! AddUserTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "leaveChat", for: indexPath) as! LeaveChatTableViewCell
                return cell
            }
           
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! UserTableViewCell
            return cell
            
        }
    
    }

     // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case 1:
            return "CHAT SETTINGS"
            
        case 2:
            return "7 USERS IN CONVERSATION"
            
        default:
            return ""
        }
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
    
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       
        if indexPath.section == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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



