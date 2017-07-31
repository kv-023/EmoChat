//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SpecialTextView: UITextView, UITextViewDelegate {
    var formatedTextForCell: String!

    override var text: String! {
        didSet{
            formatedTextForCell = text
            formatedTextForCell.shrinkUrlAddress()
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
