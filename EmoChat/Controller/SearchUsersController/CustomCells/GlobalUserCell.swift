//
//  GlobalUserCell.swift
//  EmoChat
//
//  Created by Admin on 08.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class GlobalUserCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userUsernameLabel: UILabel!
    @IBOutlet weak var userNameSurnameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
