//
//  CustomTextView.swift
//  EmoChat
//
//  Created by Olga Saliy on 03.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    
       override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) && UIPasteboard.general.string != nil {
            UIMenuController.shared.menuItems = []
            return true
        }
        return false
    }
    
    override func paste(_ sender: Any?) {
        self.text? += UIPasteboard.general.string!
    }
}
