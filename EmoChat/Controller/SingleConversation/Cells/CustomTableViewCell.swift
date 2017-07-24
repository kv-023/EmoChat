//
//  CustomTableViewCell.swift
//  EmoChat
//
//  Created by Olga Saliy on 20.06.17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import UIKit


class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var message: SpecialTextView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var heightOfPreviewContainer: NSLayoutConstraint!
    
    weak var delegate: CellDelegate!
    weak var singleConversationControllerDelegate: SingleConversationControllerProtocol?
    
    var temporaryCellHeight:CGFloat = 0
    var extraCellHeiht:CGFloat {
        return heightOfPreviewContainer.constant
    }

    weak var messageModel: MessageModel? {
        didSet {
            if let notNullMessageModel = messageModel {

                if notNullMessageModel.containsUrlLinks {
                    updateUIForMessageModel()
                } else {
                    setNullableDataInPreviewContainer()
                }
            } else {
                let arrayOfLinks = self.getArrayOfRegexMatchesForURLInText(text: self.message.text)
                if arrayOfLinks.count > 0 {
                    //lets show spinner animation
                    showViewForRestUIContent()
                    parseDataFromMessageTextForCell()
                } else {
                    setNullableDataInPreviewContainer()
                }

            }
        }
    }
    
    //SHOULD BE OVERRIDDEN IN SUBCLASSES FOR DIFFERENT CONTENT TYPE
    var messageEntity: Message? {
        didSet {
            setNullableDataInPreviewContainer()
        }
    }

    func parseDataFromMessageTextForCell() {
        parseDataFromMessageText(delaySeconds: 1)
    }

    //CAN BE OVERRIDDEN
    var contentRect: CGRect {
        get {
            return self.background.frame
        }
    }
    
    func handler(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate.cellDelegate(self, didHandle: .longPress)
        }
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
        removeRestUIInfoViewFromView(view: previewContainer)
        setNullableHeightOfPreviewContainer()
    }
    
    func setNullableHeightOfPreviewContainer() {
        heightOfPreviewContainer.constant = 0
    }
   
    //SHOULD BE OVERRIDDEN TO CHANGE SOURCE FOR TAP RECOGNIZER
    func addRecognizerForMessage() {        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handler))
        message.addGestureRecognizer(recognizer)
    }
}

// MARK: - Actions

enum Action {
    case longPress
    // Other actions
}

protocol CellDelegate: class {
    func cellDelegate(_ sender: UITableViewCell, didHandle action: Action)
}


