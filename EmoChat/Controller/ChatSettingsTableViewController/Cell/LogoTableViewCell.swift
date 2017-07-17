//
//  LogoTableViewCell.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 21.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class LogoTableViewCell: UITableViewCell {

    @IBOutlet var conversTitle: UILabel!
    @IBOutlet var conversLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
