//
//  UserTableViewCell.swift
//  EmoChat
//
//  Created by Vlad on 16.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
