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
    var shouldIgnoreConversationMessageDidSetLink: Bool = false
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return !shouldBlockMenuActions && super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var text: String! {
        didSet {
            if !shouldIgnoreConversationMessageDidSetLink {
                ConversationMessage.sharedInstance.content = text
            }

            shouldIgnoreConversationMessageDidSetLink = false
        }
    }
}

extension CustomTextView: CustomTextViewProtocol {

    func setText(text: String) {
        shouldIgnoreConversationMessageDidSetLink = true //igrore recurse for onece
        self.text = text
    }

    func setEditingStyle(flag: Bool = true) {
        self.isEditable = flag
        self.isUserInteractionEnabled = flag
    }

}
