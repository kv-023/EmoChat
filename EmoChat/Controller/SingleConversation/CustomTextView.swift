//
//  CustomTextView.swift
//  EmoChat
//
//  Created by Olga Saliy on 03.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    
    var shouldBlockMenuActions: Bool = false
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return !shouldBlockMenuActions && super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    
}
