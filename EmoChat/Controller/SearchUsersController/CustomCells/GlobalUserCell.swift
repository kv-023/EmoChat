//
//  GlobalUserCell.swift
//  EmoChat
//
//  Created by Admin on 08.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class GlobalUserCell: UITableViewCell {
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userUsernameLabel: UILabel!
    @IBOutlet var userNameSurnameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
