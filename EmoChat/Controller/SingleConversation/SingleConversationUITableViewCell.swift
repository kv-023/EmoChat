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

    weak var singleConversationControllerDelegate: SingleConversationControllerProtocol?

    var messageModel: MessageModel? //be careful! - don't set observers like "willSet" & "didSet" ,... !

    var messageEntity: Message? {
        didSet {
            message.text = messageEntity?.content?.content

            parseDataFromMessageText()
        }
    }

    deinit {

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setInitDataForUI()
    }

    private func setInitDataForUI() {
        addRecognizerForMessage()

        heightOfPreviewContainer.constant = 0
    }

    private func addRecognizerForMessage() {

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
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

}
