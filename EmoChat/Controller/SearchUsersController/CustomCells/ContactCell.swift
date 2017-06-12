//
//  ContactCell.swift
//  EmoChat
//
//  Created by Admin on 08.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet var contactPhoto: UIImageView!
    @IBOutlet var contactNameLabel: UILabel!
    @IBOutlet var contactUsernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
