//
//  LogoTableViewCell.swift
//  EmoChat
//
//  Created by Vladyslav Tsykhmystro on 16.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class LogoTableViewCell: UITableViewCell {

    @IBOutlet weak var conversationTitle: UILabel!
    @IBOutlet var conversLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadNewLogo))
        conversLogo.isUserInteractionEnabled = true
        conversLogo.addGestureRecognizer(tapGestureRecognizer)
       // conversLogo.layer.cornerRadius = conversLogo.frame.height/2

        
    }

    
    func loadNewLogo(tapGestureRecognizer: UITapGestureRecognizer) {
        print("111111")
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
