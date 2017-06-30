//
//  LeftSingleConversationUITableViewCell.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 30.06.17.
//  ..refactored class created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class LeftCell: SingleConversationUITableViewCell, UITextViewDelegate {

    @IBOutlet weak var background: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setInitData()
    }

    private func setInitData() {
        
    }
}
