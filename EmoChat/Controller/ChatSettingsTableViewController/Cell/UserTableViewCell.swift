//
//  UserTableViewCell.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 26.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import Foundation
import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet var userPic: UIImageView!
    @IBOutlet var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
