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
    weak var clearButton: UIButton?
    
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

    func getClearButton() -> UIButton {
        let kClearButtonWidth: Int = 15
        let kClearButtonHeight: Int = kClearButtonWidth
        let curClearButton = UIButton(frame: CGRect(x: 0, y: 0, width: kClearButtonWidth, height: kClearButtonWidth))
        curClearButton.setImage(UIImage(named: "clearButtonUnpressed.png")!, for: .normal)
        curClearButton.setImage(UIImage(named: "clearButtonPressed.png")!, for: .highlighted)

        curClearButton.center = CGPoint(x: self.frame.size.width - CGFloat(kClearButtonWidth),
                                     y: CGFloat(kClearButtonHeight))

        curClearButton.addTarget(self, action: #selector(clearTextView), for: .touchUpInside)
        self.addSubview(curClearButton)

        return curClearButton
    }

    @objc func clearTextView() {
        ConversationMessage.sharedInstance.eraseAllData()
        removeDeintButton()

        self.becomeFirstResponder()
    }

    deinit {
        removeDeintButton()
    }

    func removeDeintButton() {
        clearButton?.removeFromSuperview()
        clearButton = nil
    }
}

extension CustomTextView: CustomTextViewProtocol {

    func setText(text: String) {
        shouldIgnoreConversationMessageDidSetLink = true //igrore recurse for onece
        self.text = text
    }

    func setEditingStyle(flag: Bool = true) {
        self.isEditable = flag

        if !flag {
            clearButton = clearButton ?? getClearButton()
        }
    }


}
