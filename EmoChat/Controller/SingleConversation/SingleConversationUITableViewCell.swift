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
    var temporaryCellHeight:CGFloat = 0
    var extraCellHeiht:CGFloat {
        return heightOfPreviewContainer.constant
    }

    weak var messageModel: MessageModel? //be careful! - don't set observers like "willSet" & "didSet" ,... !

    var messageEntity: Message? {
        didSet {
            message.text = messageEntity?.content?.content

            setNullableDataInPreviewContainer()
            parseDataFromMessageText(delaySeconds: 1)
            //heightOfPreviewContainer.constant = 50 // for test only!
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

        previewContainer.backgroundColor = UIColor.clear
        setNullableHeightOfPreviewContainer()
    }

    func setNullableDataInPreviewContainer() {
        messageModel = nil
        removeRestUIInfoViewFromView(view: previewContainer)
        setNullableHeightOfPreviewContainer()
    }

    func setNullableHeightOfPreviewContainer() {
        heightOfPreviewContainer.constant = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        self.contentView.layoutIfNeeded()
//        self.layoutIfNeeded()
//        self.previewContainer.layoutIfNeeded()
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
