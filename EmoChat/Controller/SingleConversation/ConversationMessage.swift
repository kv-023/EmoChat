//
//  SingleConversationCurrentMessage.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 26.07.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

protocol CustomTextViewProtocol: class {
    func setText(text: String)
}

class ConversationMessage {

    static var sharedInstance = ConversationMessage()

    weak var linkedTextViewDelegate: CustomTextViewProtocol?

    var content: String {
        didSet {
            linkedTextViewDelegate?.setText(text: content)
        }
    }

    var type: MessageContentType

    init() {
        content = ""
        type = .text
    }

    private func setInitData() {
        content = ""
        type = .text
    }

    func setData(content: String,
                 type: MessageContentType) {
        self.content = content
        self.type = type
    }

    func eraseAllData() {
        setInitData()
    }
}
