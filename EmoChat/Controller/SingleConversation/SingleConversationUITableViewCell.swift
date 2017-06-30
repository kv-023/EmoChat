//
//  SingleConversationUITableViewCell.swift
//  EmoChat
//
//  Created by Nikolay Dementiev on 29.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit

class SingleConversationUITableViewCell: UITableViewCell {

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: SpecialTextView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var heightOfPreviewContainer: NSLayoutConstraint!

    var messageModel: MessageModel?

    var messageEntity: Message? {
        didSet {
            message.text = messageEntity?.content?.content

            parseDataFromMessageText()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setInitData()
    }

    private func setInitData() {
        //superClass's initial data


        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)

        heightOfPreviewContainer.constant = 0 // hide when show first time
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func handler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            sender.view!.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.setTargetRect(message.frame, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }


    //MARK: REST-UI parser
    private func parseDataFromMessageText() {
        if let notNullMessage = messageEntity {
            messageModel = nil

            let newModel = MessageModel(message: notNullMessage)
            newModel.getParseDataFromResource { (allDone) in
                if allDone {
                    self.messageModel = newModel

                    DispatchQueue.main.async {
                        //self.updateUI()
                    }
                }
            }
        }
    }

}
